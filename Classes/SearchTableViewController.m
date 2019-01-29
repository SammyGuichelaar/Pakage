
@implementation SearchTableViewController
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
	results = [NSMutableArray array];
	[results retain];
}

- (void) viewDidUnload 
{
	[super viewDidUnload];
}

- (void) dealloc 
{
	[results release];
    [super dealloc];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
	return 2;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section 
{
	if(section == 0)
		return 1;
	else
	{
		if(results.count > 0)
			return results.count;
		else
			return 1;
	}
}

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
	if(indexPath.section == 0)
		return 44.0f;
	else
		return 50.0f;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath 
{
	PackageCell *cell;
	if(indexPath.section == 0)
	{
		static NSString *CellIdentifier = @"SearchBarCell";
		UITableViewCell *searchBarCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		searchBar = [[UISearchBar alloc] initWithFrame:searchBarCell.frame];
		searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
		searchBar.delegate = self;
		searchBar.placeholder = @"Search Packages...";
		[searchBarCell addSubview:searchBar];
		return searchBarCell;
	}
	
	static NSString *CellIdentifier = @"SearchCell";
	
	if(results.count == 0)
	{
		cell = [[[PackageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Blank"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.detailTextLabel.text = nil;
		cell.imageView.image = nil;
		cell.textLabel.text = nil;
		return cell;
	}
	
	cell = (PackageCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) 
		cell = [[[PackageCell alloc] initWithIdentifier:CellIdentifier package:[results objectAtIndex:indexPath.row]] autorelease];
	else
		[cell updateWithPackage:[results objectAtIndex:indexPath.row]];
	return cell;	
}


- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
	if(indexPath.section == 0 || results.count == 0)
		return;
	else
	{
		DetailsViewController *detailViewController = [[DetailsViewController alloc] init];
		detailViewController.package = [results objectAtIndex:indexPath.row];
		detailViewController.navigationController = self.parentController.navigationController;
		[self.parentController.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void) searchBarSearchButtonClicked:(UISearchBar *) aSearchBar
{
	NSString *search = searchBar.text;
	[results release];
	results = [[PackageDatabase database] packagesWithSearch:search];
	[results retain];
	
	[self.tableView reloadData]; 
	[searchBar resignFirstResponder];
	searchBar.text = search;
}

- (void) searchBarCancelButtonClicked:(UISearchBar *) aSearchBar
{
	[searchBar resignFirstResponder];
}

- (BOOL) searchBarShouldBeginEditing:(UISearchBar *) aSearchBar 
{  
	[searchBar setShowsCancelButton:YES animated:YES];  
	return YES;
}  

- (BOOL) searchBarShouldEndEditing:(UISearchBar *) aSearchBar 
{  
	[searchBar setShowsCancelButton:NO animated:YES];  
	return YES;
}  

- (void) didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

@end

