
@interface ManageViewController:UIViewController
{
	UINavigationController *navigationController;
	UISegmentedControl *segmentedControl;
	InstalledTableViewController *installedTableViewController;
	QueueTableViewController *queueTableViewController;
}

@property (nonatomic, retain) UINavigationController *navigationController;
@end
