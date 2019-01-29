
@interface InstalledTableViewController:UITableViewController 
{
	NSArray *manageList;
	UIViewController *parentController;
}

@property (nonatomic, assign) UIViewController *parentController;
@end

