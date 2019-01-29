
@interface SearchTableViewController:UITableViewController <UISearchBarDelegate>
{
	NSArray *results;
	UISearchBar *searchBar;
	UIViewController *parentController;
}

@property (nonatomic, assign) UIViewController *parentController;
@end
