
@implementation SectionsTableViewController
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
	
	NSArray *categoryList = [[PackageDatabase database] allSections];
	NSMutableArray *themesList = [NSMutableArray array];
	[themesList retain];
	NSMutableArray *appsList = [NSMutableArray array];
	[appsList retain];
	for(NSString *sec in categoryList)
	{
		if([sec hasPrefix:@"Themes"])
			[themesList addObject:sec];
		else
			[appsList addObject:sec];
	}
	sectionsArray = [NSMutableArray array];
	if(appsList.count > 0)
		[sectionsArray addObject:appsList];
	if(themesList.count > 0)
		[sectionsArray addObject:themesList];
	[sectionsArray retain];
}

- (void) viewDidUnload 
{
	[super viewDidUnload];
}

- (void) dealloc 
{
	[[PackageDatabase database] removeNotification:self];
	[sectionsArray release];
    [super dealloc];
}

- (void) databaseDidUpdate
{
	[sectionsArray release];
	
	NSArray *categoryList = [[PackageDatabase database] allSections];
	NSMutableArray *themesList = [NSMutableArray array];
	[themesList retain];
	NSMutableArray *appsList = [NSMutableArray array];
	[appsList retain];
	for(NSString *sec in categoryList)
	{
		if([sec hasPrefix:@"Themes"])
			[themesList addObject:sec];
		else
			[appsList addObject:sec];
	}
	sectionsArray = [NSMutableArray array];
	if(appsList.count > 0)
		[sectionsArray addObject:appsList];
	if(themesList.count > 0)
		[sectionsArray addObject:themesList];
	[sectionsArray retain];
	
	[self.tableView reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
	return [sectionsArray count] + 1;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section 
{
	if(section == 0)
		return 1;
	else
		return [[sectionsArray objectAtIndex:section - 1] count];
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section 
{
	switch(section)
	{
		case 0:
			return nil;
			break;
		case 1:
			if([[sectionsArray objectAtIndex:section - 1] count] > 0)
				return @"Apps";
			break;
		case 2:
			if([[sectionsArray objectAtIndex:section - 1] count] > 0)
				return @"Themes";
			break;
	}
	return nil;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath 
{
	UITableViewCell *cell;	
	static NSString *CellIdentifier = @"SectionCell";
    
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) 
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if(indexPath.section == 0)
		cell.textLabel.text = @"All Packages";
	else
		cell.textLabel.text = [[[sectionsArray objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
	return cell;
}


- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
	PackageListViewController *packageViewController = [[PackageListViewController alloc] init];
	if(indexPath.section > 0)
	{
		packageViewController.packageList = [[PackageDatabase database] packagesInSection:[[sectionsArray objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row]];
		packageViewController.title = [[sectionsArray objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row];
	}
	else
	{
		packageViewController.packageList = [[PackageDatabase database] allPackages];
		packageViewController.title = @"All Packages";
	}
	packageViewController.navigationController = self.parentController.navigationController;
	[self.parentController.navigationController pushViewController:packageViewController animated:YES];
	[packageViewController release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void) didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

@end

