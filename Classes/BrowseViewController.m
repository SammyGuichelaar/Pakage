
@implementation BrowseViewController
@synthesize navigationController;

- (BrowseViewController *) init
{
	if((self = [super init]))
	{
		searchTableViewController = [[SearchTableViewController alloc] init];
		searchTableViewController.parentController = self;
		
		sectionsTableViewController = [[SectionsTableViewController alloc] init];
		sectionsTableViewController.parentController = self;
	}
	
	return self;
}

- (void) loadView
{
	CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	self.view = [[UIView alloc] initWithFrame:bounds];
	
	[self.view addSubview:sectionsTableViewController.tableView];
	[self.view addSubview:searchTableViewController.tableView];
	
	segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Sections", @"Search", nil]];
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 180, 30);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = NO;
	segmentedControl.selectedSegmentIndex = 0;
	
	// this view has no standard title so we need to set this
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    
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
	[sectionsTableViewController release];
	[searchTableViewController release];
	
	[[PackageDatabase database] removeNotification:self];
    [super dealloc];
}

- (void) segmentAction:(UISegmentedControl *) segmented
{
	if(segmented.selectedSegmentIndex == 1)
		[self.view bringSubviewToFront:searchTableViewController.tableView];
	else
		[self.view bringSubviewToFront:sectionsTableViewController.tableView];
}

- (void) didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

@end
