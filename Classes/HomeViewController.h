
@interface HomeViewController:UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UINavigationController *navigationController;	
	UITableView *homeTableView;
	
	UIView *headerView;
	UILabel *titleLabel;
	UILabel *detailLabel;
	UIImageView *iconView;
}

@property (nonatomic, retain) UINavigationController *navigationController;
@end
