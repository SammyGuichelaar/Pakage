
@interface PackageListViewController:UIViewController <UITableViewDataSource, UITableViewDelegate>
{
	UINavigationController *navigationController;
	UITableView *packageTableView;
	NSArray *packageList;
	NSMutableArray *sectionsArray;
	NSString *sql;
}
 
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UITableView *packageTableView;
@property (nonatomic, retain) NSArray *packageList;
@end
