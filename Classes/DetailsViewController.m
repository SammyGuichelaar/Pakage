
@implementation DetailsViewController
@synthesize navigationController, package;

- (DetailsViewController *) initWithPackage:(Package *) pkg
{
	if((self = [super init]))
	{
		package = [pkg retain];
		return self;
	}
	
	return nil;
}

- (void) loadView
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	self.view = [[UIView alloc] initWithFrame:bounds];
	
	webView = [[UIWebView alloc] initWithFrame:CGRectZero];
	webView.delegate = self;
	webView.dataDetectorTypes = UIDataDetectorTypeNone;
	
	detailsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f - 112.0f) style:UITableViewStyleGrouped];
	detailsTableView.delegate = self;
	detailsTableView.dataSource = self;
	[self.view addSubview:detailsTableView];
	
	headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
	[headerView addSubview:webView];
	[webView release];
		
	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(77, 0, 250, 50)];
	titleLabel.shadowColor = [UIColor whiteColor];
	titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
	titleLabel.textColor = [UIColor colorWithRed:(76.0/255.0) green:(86.0/255.0) blue:(108.0/255.0) alpha:1.0f];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
	[headerView addSubview:titleLabel];
	[titleLabel release];
	
	detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(77, 25, 250, 50)];
	detailLabel.shadowColor = [UIColor whiteColor];
	detailLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
	detailLabel.textColor = [UIColor colorWithRed:(76.0/255.0) green:(86.0/255.0) blue:(108.0/255.0) alpha:1.0f];
	detailLabel.backgroundColor = [UIColor clearColor];
	detailLabel.font = [UIFont systemFontOfSize:15.0f];
	[headerView addSubview:detailLabel];
	[detailLabel release];
	
	iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 57, 57)];
	iconView.image = [UIImage imageNamed:@"default_icon.png"];
	[headerView addSubview:iconView];
	[iconView release];
	
	detailsTableView.tableHeaderView = headerView;
	[headerView release];
	
	installButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(installClicked:)];
	
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[activityIndicator sizeToFit];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	loadingView.target = self;
}

- (void) viewDidLoad 
{
    [super viewDidLoad];
	self.title = package.name;
	depictionLoaded = NO;
	
	if(package.depiction && ![package.depiction isEqualToString:@""])
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:package.depiction]]];	
		
	titleLabel.text = package.name;
	detailLabel.text = [NSString stringWithFormat:@"v%@ - %@", package.version, package.section];
	
	NSString *title;
	int idx = [self getTitle]; 
	if(idx == 1)
		title = @"Install";
	else if(idx == 2)
		title = @"Remove";
	else
		title = @"Upgrade";
	installButton.title = title;
	
	if(package.depiction && ![package.depiction isEqualToString:@""])
		self.navigationItem.rightBarButtonItem = loadingView;
	else
		self.navigationItem.rightBarButtonItem = installButton;		
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
	
	[webView stopLoading];
	webView.delegate = nil;
	[webView release];
	
	[package release];
    [super dealloc];
}


- (int) getTitle
{
	if(package.installed && ![package.version isEqualToString:package.installedVersion])
		return 3;
	else if(package.installed)
		return 2;
	else
		return 1;
}

- (void) installClicked:(UIBarButtonItem *) item
{
	UIActionSheet *actionView;
	int idx = [self getTitle];
	NSString *prompt;
	switch(idx)
	{
		case 1:
			prompt = @"Are are you sure you want to install this package?";
			actionView = [[UIActionSheet alloc] initWithTitle:prompt delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Install" otherButtonTitles:nil];
			break;
		case 2:
			prompt = @"Are are you sure you want to uninstall this package?";
			actionView = [[UIActionSheet alloc] initWithTitle:prompt delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:@"Reinstall", nil];
			break;
		default:
			prompt = @"Are are you sure you want to upgrade this package?";
			actionView = [[UIActionSheet alloc] initWithTitle:prompt delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Upgrade" otherButtonTitles:@"Remove", @"Reinstall", nil];
			break;
	}

	[actionView showInView:self.view.window];
	[actionView release];
}

- (void) actionSheet:(UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	int idx = [self getTitle];
	if(idx == 1)
	{
		if(buttonIndex == 0)
			[[InstallQueue queue] addPackage:package];
		else
			return;
	}
	else if(idx == 2)
	{
		if(buttonIndex == 0)
			[[InstallQueue queue] addPackageToRemove:package];
		else if(buttonIndex == 1)
			[[InstallQueue queue] addPackage:package];
		else
			return;
	}
	else
	{
		if(buttonIndex == 0)
			[[InstallQueue queue] addPackage:package];
		else if(buttonIndex == 1)
			[[InstallQueue queue] addPackageToRemove:package];
		else if(buttonIndex == 2)
			[[InstallQueue queue] addPackage:package];
		else
			return;
	}
	
	if(buttonIndex != idx)
	{
		// Determine the animation's path.
		CGPoint startPoint = CGPointMake(280, 20); //CGPointMake(buttonFrame.origin.x + buttonFrame.size.width / 2, buttonFrame.origin.y + buttonFrame.size.height / 2);
		CGPoint curvePoint1 = CGPointMake(startPoint.x - 130, startPoint.y - 10);
		CGPoint endPoint = CGPointMake(260, 500); //CGPointMake(CGRectGetMidX(cellFrame), CGRectGetMidY(cellFrame));
		CGPoint curvePoint2 = CGPointMake(startPoint.x - 140, endPoint.y - 40);
		
		// Create the animation's path.
		CGPathRef path = NULL;
		CGMutablePathRef mutablepath = CGPathCreateMutable();
		CGPathMoveToPoint(mutablepath,  NULL, 
						  startPoint.x, startPoint.y);
		
		CGPathAddCurveToPoint(mutablepath,   NULL, 
							  curvePoint1.x, curvePoint1.y,
							  curvePoint2.x, curvePoint2.y,
							  endPoint.x,    endPoint.y);
		
		path = CGPathCreateCopy(mutablepath);
		CGPathRelease(mutablepath);
		
		// Create animated icon view.
		
		UIImageView* animatedLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"packagesm.png"]];
		animatedLabel.tag = 12345;
		[[((PakageAppDelegate *) [UIApplication sharedApplication]) window] addSubview:animatedLabel];
		[animatedLabel release];
		CALayer *iconViewLayer = animatedLabel.layer;
		
		CAKeyframeAnimation *animatedIconAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		animatedIconAnimation.removedOnCompletion = YES;
		animatedIconAnimation.duration = 0.5;
		animatedIconAnimation.delegate = self;
		animatedIconAnimation.path = path;
		animatedIconAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		[iconViewLayer addAnimation:animatedIconAnimation forKey:@"animateIcon"];
		
		// Start the icon animation.
		[iconViewLayer setPosition:CGPointMake(endPoint.x, endPoint.y)];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.5];
		[animatedLabel setTransform:CGAffineTransformMakeScale(0.3, 0.3)];
		[UIView commitAnimations];
	}
}

- (BOOL) webView:(UIWebView *) webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType
{
	if(navigationType == UIWebViewNavigationTypeLinkClicked && ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"]))
	{
		BrowserViewController *browser = [[BrowserViewController alloc] init];
		browser.url = request;
		UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
		self.navigationItem.backBarButtonItem = newBackButton;
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
	self.navigationItem.rightBarButtonItem = loadingView;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[activityIndicator startAnimating];
}

- (void) resizeWebView
{
	webView.frame = CGRectMake(0.0, headerView.frame.size.height + 10, 320, [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight + document.body.offsetTop;"] floatValue]);
	
	CGRect newFrame = headerView.frame;
	newFrame.size.height += webView.frame.size.height;
	headerView.frame = newFrame;
	
	detailsTableView.tableHeaderView = headerView;		
}

- (void) webViewDidFinishLoad:(UIWebView *) theWebView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[activityIndicator stopAnimating];
	self.navigationItem.rightBarButtonItem = installButton;
	if(!depictionLoaded)
	{
		depictionLoaded = YES;
		[self performSelector:@selector(resizeWebView) withObject:nil afterDelay:0.1];
	}
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView 
{
    return 1;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section
{
	return 4;
}

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
	if(indexPath.row == 0)
	{
		NSString *text = package.description;
		CGSize constraint = CGSizeMake(320.0 - (20.0), 20000.0f);
		CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
		if(size.height > 44.0f)
			return size.height + 10.0;
		else
			return 44.0;
	}
	return 44.0;

}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section
{
	return @"Package Info";
}

- (NSString *) tableView:(UITableView *) tableView titleForFooterInSection:(NSInteger) section
{
	return @"Please contact the author of this package to report bugs and request features.";
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath 
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	
	switch(indexPath.row)
	{
		case 0:
			cell.textLabel.text = package.description;
			cell.textLabel.font = [UIFont systemFontOfSize:16.0];
			cell.textLabel.numberOfLines = 0;
			break;
		case 1:
			cell.textLabel.text = @"ID";
			cell.detailTextLabel.text = package.package;
			break;
		case 2:
			cell.textLabel.text = @"Section";
			cell.detailTextLabel.text = package.section;
			break;
		case 3:
			cell.textLabel.text = @"Developer";
			cell.detailTextLabel.text = package.author;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			break;
	}

	return cell;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath 
{    		
	NSString *mailString;
	switch(indexPath.row)
	{
		case 3:
			if(package.authorEmail && ![package.authorEmail isEqualToString:@""])
			{
				mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
					[package.authorEmail stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					[[NSString stringWithFormat:@"Pakage/Apt: %@ (%@)", package.name, package.package] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					[@"" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
			}
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
