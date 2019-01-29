
@interface RecentViewController:UIViewController
{
	UINavigationController *navigationController;
	UISegmentedControl *segmentedControl;
	UIBarButtonItem *upgradeButton;
	RecentTableViewController *recentTableViewController;
	UpdatesTableViewController *updatesTableViewController;
}
	
@property (nonatomic, retain) UINavigationController *navigationController;
@end
