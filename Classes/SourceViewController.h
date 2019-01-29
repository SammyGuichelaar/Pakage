
@interface SourceViewController:UIViewController <UITableViewDataSource, UITableViewDelegate>
{
	UINavigationController *navigationController;
	UITableView *sourceTableView;
	NSMutableArray *cydiaList;
	NSMutableArray *pakageList;
	NSMutableArray *otherList;
	UIBarButtonItem *refreshButton;
	UIActivityIndicatorView *activityIndicator;
	UIBarButtonItem *loadingView;
	UITextField *srcField;
}

@property (nonatomic, retain) UINavigationController *navigationController;
@end
