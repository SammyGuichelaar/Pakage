
@implementation ManageViewController
@synthesize navigationController;

- (ManageViewController *) init
{
	if((self = [super init]))
	{
		installedTableViewController = [[InstalledTableViewController alloc] init];
		installedTableViewController.parentController = self;
		
		queueTableViewController = [[QueueTableViewController alloc] init];
		queueTableViewController.parentController = self;
	}
	
	return self;
}

- (void) loadView
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	self.view = [[UIView alloc] initWithFrame:bounds];
	
	[self.view addSubview:installedTableViewController.tableView];
	[self.view addSubview:queueTableViewController.tableView];
	
	segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Installed", @"Queue", nil]];
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 180, 30);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = NO;
	segmentedControl.selectedSegmentIndex = 0;
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];
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
	[installedTableViewController release];
	[queueTableViewController release];
	
    [super dealloc];
}

- (void) segmentAction:(UISegmentedControl *) segmented
{
	if(segmented.selectedSegmentIndex == 1)
		[self.view bringSubviewToFront:queueTableViewController.tableView];
	else
		[self.view bringSubviewToFront:installedTableViewController.tableView];
}

- (void) didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

@end
