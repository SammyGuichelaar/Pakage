
@implementation RecentTableViewController
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
	dateHeaders = [[PackageDatabase database] recentDates];
	[dateHeaders retain];
	dateList = [[PackageDatabase database] recent];
	[dateList retain];
}

- (void) viewDidUnload 
{
	// Release any retained subviews of the main view.
}

- (void) dealloc 
{
	[[PackageDatabase database] removeNotification:self];
	[dateHeaders release];
	[dateList release];
    [super dealloc];
}

- (void) databaseDidUpdate
{
	[dateHeaders release];
	[dateList release];
	
	dateHeaders = [[PackageDatabase database] recentDates];
	[dateHeaders retain];
	dateList = [[PackageDatabase database] recent];
	[dateList retain];
	
	[self.tableView reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
	return [dateHeaders count];
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section 
{
	return [[dateList objectAtIndex:section] count];
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section 
{
	return [dateHeaders objectAtIndex:section];
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath 
{
	PackageCell *cell;	
    static NSString *CellIdentifier = @"Cell";
    cell = (PackageCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) 
		cell = [[[PackageCell alloc] initWithIdentifier:CellIdentifier package:[[dateList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]] autorelease];
	else
		[cell updateWithPackage:[[dateList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];	
	return cell;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
	DetailsViewController *detailViewController = [[DetailsViewController alloc] init];
	detailViewController.package = [[dateList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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

