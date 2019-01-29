
@interface BrowseViewController:UIViewController
{
	UINavigationController *navigationController;
	SectionsTableViewController *sectionsTableViewController;
	SearchTableViewController *searchTableViewController;
	UISegmentedControl *segmentedControl;
}

@property (nonatomic, retain) UINavigationController *navigationController;
@end
