
@interface BrowserViewController:UIViewController <UIWebViewDelegate>
{
	UINavigationController *navigationController;
	UIActivityIndicatorView *activityIndicator;
	UIWebView *webView;
	UIBarButtonItem *loadingView;
	NSURLRequest *url;
}

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) NSURLRequest *url;

@end
