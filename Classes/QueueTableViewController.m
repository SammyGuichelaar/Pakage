
@implementation QueueTableViewController
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
	[[InstallQueue queue] addNotification:self];
	packageList = [[InstallQueue queue] allPackages];
	[packageList retain];
}

- (void) viewDidUnload 
{
	[packageList release];
	packageList = nil;
	[super viewDidUnload];
}

- (void) dealloc 
{
	[[InstallQueue queue] removeNotification:self];
    [super dealloc];
}

- (void) packageWasAdded
{
	[packageList release];
	packageList = [[InstallQueue queue] allPackages];
	[packageList retain];
	if(packageList.count > 0)
		self.parentController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", packageList.count];
	else
		self.parentController.tabBarItem.badgeValue = nil;
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:packageList.count - 1 inSection:0]] withRowAnimation:YES];
}

- (void) packageWasInstalled:(Package *) pkg
{
	[packageList release];
	packageList = [[InstallQueue queue] allPackages];
	[packageList retain];
	if(packageList.count > 0)
		self.parentController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", packageList.count];
	else
		self.parentController.tabBarItem.badgeValue = nil;
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:YES];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	cell.detailTextLabel.text = @"Running Task...";
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
	return 1;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section 
{
	return packageList.count;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath 
{
	PackageCell *cell;	
    static NSString *CellIdentifier = @"Cell";
    cell = (PackageCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	Package *pkg;
	pkg = [packageList objectAtIndex:indexPath.row];
	if(cell == nil) 
		cell = [[[PackageCell alloc] initWithIdentifier:CellIdentifier package:pkg] autorelease];
	else
		[cell updateWithPackage:pkg];
	
	if(indexPath.row == 0)
		cell.detailTextLabel.text = @"Running task...";
	else
		cell.detailTextLabel.text = @"Waiting in queue.";
	return cell;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
	DetailsViewController *detailViewController = [[DetailsViewController alloc] init];
	detailViewController.package = [packageList objectAtIndex:indexPath.row];
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
