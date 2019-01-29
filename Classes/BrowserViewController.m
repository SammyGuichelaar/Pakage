
@implementation BrowserViewController
@synthesize navigationController, url;

- (void) loadView
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	self.view = [[UIView alloc] initWithFrame:bounds];
	
	webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f - 112.0f)];
	webView.delegate = self;
	[self.view addSubview:webView];
	
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[activityIndicator sizeToFit];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	loadingView.target = self;
	self.navigationItem.rightBarButtonItem = loadingView;	
}

- (void) viewDidLoad 
{
    [super viewDidLoad];
	[webView loadRequest:url];	
}

- (void) viewDidUnload
{	
	[super viewDidUnload];
}

- (void) dealloc 
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[activityIndicator stopAnimating];
	[activityIndicator release];
	
	[loadingView release];
	
	webView.delegate = nil;
	[webView release];
	
    [super dealloc];
}

- (BOOL) webView:(UIWebView *) webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType
{
	if(navigationType == UIWebViewNavigationTypeLinkClicked && ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"]))
	{
		BrowserViewController *browser = [[BrowserViewController alloc] init];
		browser.url = request;
		UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
		[[self navigationItem] setBackBarButtonItem:newBackButton];
		[newBackButton release];
		browser.title = self.title;
		[self.navigationController pushViewController:browser animated:YES];
		[browser release];
		return NO;
	}
	
	return YES;
}

- (void) webViewDidStartLoad:(UIWebView *) theWebView
{	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[activityIndicator startAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *) theWebView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[activityIndicator stopAnimating];
}

@end
