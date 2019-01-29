
@interface DetailsViewController:UIViewController <UIWebViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>
{
	UINavigationController *navigationController;

	UIActivityIndicatorView *activityIndicator;
	UIBarButtonItem *installButton;
	UIBarButtonItem *loadingView;
	
	UITableView *detailsTableView;
	UIWebView *webView;
	BOOL depictionLoaded;
	
	UIView *headerView;
	UILabel *titleLabel;
	UILabel *detailLabel;
	UIImageView *iconView;
	
	Package *package;
}

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) Package *package;

- (int) getTitle;
@end
