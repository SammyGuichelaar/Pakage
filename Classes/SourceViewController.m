
@implementation SourceViewController
@synthesize navigationController;

- (void) loadView
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	self.view = [[UIView alloc] initWithFrame:bounds];
}

- (void) viewDidLoad 
{
    [super viewDidLoad];
	[[PackageDatabase database] addNotification:self];
	[[SourceDatabase database] addNotification:self];
	
	cydiaList = [[SourceDatabase database] cydiaSources];
	[cydiaList retain];
	pakageList = [[SourceDatabase database] pakageSources];
	[pakageList retain];
	otherList = [[SourceDatabase database] otherSources];
	[otherList retain];
		
	sourceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f - 112.0f) style:UITableViewStylePlain];
	[self.view addSubview:sourceTableView];
	sourceTableView.delegate = self;	
	sourceTableView.dataSource = self;
	sourceTableView.rowHeight = 50.0f;
	
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[activityIndicator sizeToFit];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	loadingView.target = self;
	[activityIndicator startAnimating];
	
	refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshClicked:)];
	if(![[PackageDatabase database] isLoading] && ![[SourceDatabase database] isLoading])
		self.navigationItem.rightBarButtonItem = refreshButton;	
	else
		self.navigationItem.rightBarButtonItem = loadingView;
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addClicked:)];
	self.navigationItem.leftBarButtonItem = addButton;
}

- (void) viewDidUnload
{
	[super viewDidUnload];
}

- (void) dealloc 
{
	[cydiaList release];
	[pakageList release];
	[otherList release];
	
	[[PackageDatabase database] removeNotification:self];
	[[SourceDatabase database] removeNotification:self];
    [super dealloc];
}

- (void) refreshClicked:(UIBarButtonItem *) item
{
	if(![[SourceDatabase database] isLoading] && ![[PackageDatabase database] isLoading])
		[NSThread detachNewThreadSelector:@selector(refreshSources) toTarget:[SourceDatabase database] withObject:nil];
}

- (void) addClicked:(UIBarButtonItem *) item
{
	UIAlertView *dialog = [[[UIAlertView alloc] init] retain];
	[dialog setDelegate:self];
	[dialog setTitle:@"Add New Source"];
	[dialog setMessage:@" "];
	[dialog addButtonWithTitle:@"Cancel"];
	[dialog addButtonWithTitle:@"Add"];
	
	srcField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
	[srcField setBackgroundColor:[UIColor whiteColor]];
	[dialog addSubview:srcField];
	CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 100.0);
	[dialog setTransform: moveUp];
	[dialog show];
	[dialog release];
	[srcField release];
	srcField.text = @"http://";
	srcField.borderStyle = UITextBorderStyleLine;
	[srcField becomeFirstResponder];
}

- (void) alertView:(UIAlertView *) alert clickedButtonAtIndex:(NSInteger) buttonIndex
{
	[srcField resignFirstResponder];
	if(buttonIndex == 0)
		return;
	
	[[SourceDatabase database] addSource:srcField.text];
	[cydiaList release];
	[pakageList release];
	[otherList release];
	cydiaList = [[SourceDatabase database] cydiaSources];
	[cydiaList retain];
	pakageList = [[SourceDatabase database] pakageSources];
	[pakageList retain];
	otherList = [[SourceDatabase database] otherSources];
	[otherList retain];
	[sourceTableView reloadData];
}

- (void) databaseDidUpdate
{
	self.navigationItem.rightBarButtonItem = refreshButton;
}

- (void) databaseDidStartLoading
{
	self.navigationItem.rightBarButtonItem = loadingView;	
}

- (void) sourcesDidUpdate
{
	if(![[PackageDatabase database] isLoading])
		[NSThread detachNewThreadSelector:@selector(refreshFromCache) toTarget:[PackageDatabase database] withObject:nil];
}

- (void) sourcesDidStartLoading
{
	self.navigationItem.rightBarButtonItem = loadingView;	
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
    return 3;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section 
{
	if(section == 0)
		return pakageList.count;
	else if(section == 1)
		return cydiaList.count;
	else
		return otherList.count;
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section 
{
	if(section == 0)
	{
		if(pakageList.count > 0)
			return @"Pakage Sources";
	}
	else if(section == 1)
	{
		if(cydiaList.count > 0)
			return @"Cydia Sources";
	}
	else
	{
		if(otherList.count > 0)
			return @"Other Sources";
	}
	return nil;
}

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
	return 50.0f;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath 
{
	UITableViewCell *cell;	
    static NSString *CellIdentifier = @"Cell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) 
		cell = [[[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:CellIdentifier] autorelease];
	
	int section = indexPath.section;
	if(section == 0)
		cell.textLabel.text = [[pakageList objectAtIndex:indexPath.row] objectAtIndex:1];
	else if(section == 1)
		cell.textLabel.text = [[cydiaList objectAtIndex:indexPath.row] objectAtIndex:1];
	else
		cell.textLabel.text = [[otherList objectAtIndex:indexPath.row] objectAtIndex:1];
	
	return cell;
}


- (void) tableView:(UITableView *) tableView willBeginEditingRowAtIndexPath:(NSIndexPath *) indexPath
{
}

- (UITableViewCellEditingStyle) tableView:(UITableView *) tableView editingStyleForRowAtIndexPath:(NSIndexPath *) indexPath 
{
	int section = indexPath.section;
	if(section == 0 || section == 1)
        return UITableViewCellEditingStyleDelete;
	else
		return UITableViewCellEditingStyleNone;
}


- (void) deleteSourceAtIndexPath:(NSIndexPath *) indexPath
{
	int section = indexPath.section;
	NSMutableArray *current;
	UITableViewCell *cell = [sourceTableView cellForRowAtIndexPath:indexPath];
	[[SourceDatabase database] removeSource: cell.textLabel.text fromList:section];

	if(section == 0)
	{
		[pakageList release];
		current = pakageList;
		pakageList = [[SourceDatabase database] pakageSources];
		[pakageList retain];
	}
	else if(section == 1)
	{
		[cydiaList release];
		current = cydiaList;
		cydiaList = [[SourceDatabase database] cydiaSources];
		[cydiaList retain];
	}
	
	[sourceTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	if([current count] == 0)
		[sourceTableView reloadData];
}

- (void) tableView:(UITableView *) tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete && (indexPath.section == 0 || indexPath.section == 1))
		[self deleteSourceAtIndexPath:indexPath];
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
	// prompt for delete?
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
