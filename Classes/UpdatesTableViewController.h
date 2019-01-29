
@interface UpdatesTableViewController:UITableViewController <UIActionSheetDelegate>
{
	NSArray *updateList;
	UIViewController *parentController;
}

@property (nonatomic, assign) UIViewController *parentController;
@end
