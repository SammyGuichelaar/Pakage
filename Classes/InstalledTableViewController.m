
@implementation InstalledTableViewController
@synthesize parentController;

- (void) loadView
{
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f - 112.0f) style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.rowHeight = 50;
	self.tableView = tableView;
	[tableView release];
}

- (void) viewDidLoad 
{
    [super viewDidLoad];
	[[PackageDatabase database] addNotification:self];
	manageList = [[PackageDatabase database] installedPackages];
	[manageList retain];
}

- (void) viewDidUnload 
{
	[manageList release];
	manageList = nil;
	[super viewDidUnload];
}

- (void) dealloc 
{
	[[PackageDatabase database] removeNotification:self];
    [super dealloc];
}

- (void) databaseDidUpdate
{
	[manageList release];
	manageList = [[PackageDatabase database] installedPackages];
	[manageList retain];
	
	[self.tableView reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
	return 1;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section 
{
	return manageList.count;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath 
{
	PackageCell *cell;	
    static NSString *CellIdentifier = @"Cell";
    cell = (PackageCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	Package *pkg;
	pkg = [manageList objectAtIndex:indexPath.row];
	
	if(cell == nil) 
		cell = [[[PackageCell alloc] initWithIdentifier:CellIdentifier package:pkg] autorelease];
	else
		[cell updateWithPackage:pkg];
	return cell;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
	DetailsViewController *detailViewController = [[DetailsViewController alloc] init];
	detailViewController.package = [manageList objectAtIndex:indexPath.row];
	detailViewController.navigationController = self.parentController.navigationController;
	[self.parentController.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

@end
