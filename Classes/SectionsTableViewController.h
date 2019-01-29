
@interface SectionsTableViewController:UITableViewController 
{
	NSMutableArray *sectionsArray;
	UIViewController *parentController;
}

@property (nonatomic, assign) UIViewController *parentController;
@end
