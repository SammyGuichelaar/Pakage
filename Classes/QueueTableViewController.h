
@interface QueueTableViewController:UITableViewController 
{
	NSArray *packageList;
	UIViewController *parentController;
}

@property (nonatomic, assign) UIViewController *parentController;
@end

