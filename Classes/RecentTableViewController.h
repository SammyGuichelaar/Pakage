
@interface RecentTableViewController:UITableViewController 
{
	NSArray *dateHeaders;
	NSArray *dateList;
	UIViewController *parentController;
}

@property (nonatomic, assign) UIViewController *parentController;
@end
