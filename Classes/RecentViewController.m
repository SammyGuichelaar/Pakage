
@implementation RecentViewController
@synthesize navigationController;

- (RecentViewController *) init
{
	if((self = [super init]))
	{
		updatesTableViewController = [[UpdatesTableViewController alloc] init];
		updatesTableViewController.parentController = self;
		
		recentTableViewController = [[RecentTableViewController alloc] init];
		recentTableViewController.parentController = self;
	}
	
	return self;
}

- (void) loadView
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	self.view = [[UIView alloc] initWithFrame:bounds];
	
	upgradeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showUpgradePrompt)];
	
#ifdef ENABLE_RECENTS
	[self.view addSubview:recentTableViewController.tableView];
	[self.view addSubview:updatesTableViewController.tableView];

	segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Recent", @"Updates", nil]];
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 180, 30);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = NO;
	segmentedControl.selectedSegmentIndex = 0;
    
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];
#else
	self.title = @"Updates";
	[self.view addSubview:updatesTableViewController.tableView];
	self.navigationItem.rightBarButtonItem = upgradeButton;
#endif 
}

- (void) viewDidLoad 
{
    [super viewDidLoad];
}

- (void) viewDidUnload 
{
	[super viewDidUnload];
}

- (void) dealloc 
{
	[recentTableViewController release];
	[updatesTableViewController release];
	
    [super dealloc];
}

- (void) showUpgradePrompt // Just forward it down the chain
{
	[updatesTableViewController showUpgradePrompt];
}

- (void) segmentAction:(UISegmentedControl *) segmented
{
	if(segmented.selectedSegmentIndex == 1)
	{
		[self.view bringSubviewToFront:updatesTableViewController.tableView];
		self.navigationItem.rightBarButtonItem = upgradeButton;
	}
	else
	{
		[self.view bringSubviewToFront:recentTableViewController.tableView];
		self.navigationItem.rightBarButtonItem = nil;
	}
}

- (void) didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

@end
