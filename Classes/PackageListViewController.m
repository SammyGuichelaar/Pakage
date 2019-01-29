
@implementation PackageListViewController

@synthesize navigationController, packageTableView, packageList;

- (void) loadView
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	self.view = [[UIView alloc] initWithFrame:bounds];
	
	packageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f - 112.0f) style:UITableViewStylePlain];
	packageTableView.delegate = self;
	packageTableView.dataSource = self;
	packageTableView.rowHeight = 50;
	[self.view addSubview:packageTableView];
}

- (void) viewDidLoad 
{
    [super viewDidLoad];
	[[PackageDatabase database] addNotification:self];
	
	// show "Back" to avoid stupid "..." parts
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
	
	UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
	NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
	
	sectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	
	for(index = 0; index < sectionTitlesCount; index++) 
	{
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[sectionsArray addObject:array];
		[array release];
	}
	
	for(Package *pkg in packageList) 
	{
		NSInteger sectionNumber = [collation sectionForObject:pkg collationStringSelector:@selector(name)];
		NSMutableArray *currentArray = [sectionsArray objectAtIndex:sectionNumber];
		[currentArray addObject:pkg];
	}
	
	for(index = 0; index < sectionTitlesCount; index++) 
	{
		NSMutableArray *arrayForSection = [sectionsArray objectAtIndex:index];
		NSArray *sortedArrayForSection = [collation sortedArrayFromArray:arrayForSection collationStringSelector:@selector(name)];
		[sectionsArray replaceObjectAtIndex:index withObject:sortedArrayForSection];
	}
}

- (void) viewDidUnload 
{
	[super viewDidUnload];
}

- (void) dealloc 
{
	[[PackageDatabase database] removeNotification:self];
	for(NSArray *array in sectionsArray)
		[array release];
	[sectionsArray release];
	
    [super dealloc];
}


- (void) databaseDidUpdate
{
	for(NSArray *array in sectionsArray)
		[array release];
	[sectionsArray release];
	
	UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
	NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
	
	sectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	
	for(index = 0; index < sectionTitlesCount; index++) 
	{
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[sectionsArray addObject:array];
		[array release];
	}
	
	for(Package *pkg in packageList) 
	{
		NSInteger sectionNumber = [collation sectionForObject:pkg collationStringSelector:@selector(name)];
		NSMutableArray *currentArray = [sectionsArray objectAtIndex:sectionNumber];
		[currentArray addObject:pkg];
	}
	
	for(index = 0; index < sectionTitlesCount; index++) 
	{
		NSMutableArray *arrayForSection = [sectionsArray objectAtIndex:index];
		NSArray *sortedArrayForSection = [collation sortedArrayFromArray:arrayForSection collationStringSelector:@selector(name)];
		[sectionsArray replaceObjectAtIndex:index withObject:sortedArrayForSection];
	}
	[packageTableView reloadData];
}



- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
    return [sectionsArray count];
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section 
{
	return [[sectionsArray objectAtIndex:section] count];
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *) tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section 
{
    if([[sectionsArray objectAtIndex:section] count] > 0) 
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    return nil;
}

- (NSInteger) tableView:(UITableView *) tableView sectionForSectionIndexTitle:(NSString *) title atIndex:(NSInteger) index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath 
{
	PackageCell *cell;	
    static NSString *CellIdentifier = @"Cell";
    
    cell = (PackageCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) 
        cell = [[[PackageCell alloc] initWithIdentifier:CellIdentifier package:[[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]] autorelease];
	else
		[cell updateWithPackage:[[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
	
	return cell;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
	DetailsViewController *detailViewController = [[DetailsViewController alloc] init];
	detailViewController.package = [[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	detailViewController.navigationController = self.navigationController;
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

@end
