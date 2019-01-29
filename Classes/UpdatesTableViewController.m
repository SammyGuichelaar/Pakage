
@implementation UpdatesTableViewController
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
	[[InstallQueue queue] addNotification:self];
	updateList = [[PackageDatabase database] needUpdates];
	[updateList retain];
}

- (void) viewDidUnload 
{
	[super viewDidUnload];
}

- (void) dealloc 
{
	[[PackageDatabase database] removeNotification:self];
	[[InstallQueue queue] removeNotification:self];
	[updateList release];
    [super dealloc];
}

- (void) packageWasInstalled:(Package *) pkg
{
	[updateList release];
	updateList = [[PackageDatabase database] needUpdates];
	[updateList retain];
	
	if([updateList count] > 0)
		self.parentController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", [updateList count]];
	else
		self.parentController.tabBarItem.badgeValue = nil;
	
	[self.tableView reloadData];
}

- (void) showUpgradePrompt
{
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil	delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Upgrade All" otherButtonTitles:nil];
	[sheet showInView:[((PakageAppDelegate *) [UIApplication sharedApplication]) window]];
	[sheet release];
}

- (void) actionSheet:(UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	if(buttonIndex == 0)
	{
		// Icon animation
		
		// Determine the animation's path.
		CGPoint startPoint = CGPointMake(280, 20); //CGPointMake(buttonFrame.origin.x + buttonFrame.size.width / 2, buttonFrame.origin.y + buttonFrame.size.height / 2);
		CGPoint curvePoint1 = CGPointMake(startPoint.x - 130, startPoint.y - 10);
		CGPoint endPoint = CGPointMake(260, 500); //CGPointMake(CGRectGetMidX(cellFrame), CGRectGetMidY(cellFrame));
		CGPoint curvePoint2 = CGPointMake(startPoint.x - 140, endPoint.y - 40);
		
		// Create the animation's path.
		CGPathRef path = NULL;
		CGMutablePathRef mutablepath = CGPathCreateMutable();
		CGPathMoveToPoint(mutablepath,  NULL, 
						  startPoint.x, startPoint.y);
		
		CGPathAddCurveToPoint(mutablepath,   NULL, 
							  curvePoint1.x, curvePoint1.y,
							  curvePoint2.x, curvePoint2.y,
							  endPoint.x,    endPoint.y);
		
		path = CGPathCreateCopy(mutablepath);
		CGPathRelease(mutablepath);
		
		// Create animated icon view.
		
		UIImageView* animatedLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"packagesm.png"]];
		animatedLabel.tag = 12345;
		[[((PakageAppDelegate *) [UIApplication sharedApplication]) window] addSubview:animatedLabel];
		[animatedLabel release];
		CALayer *iconViewLayer = animatedLabel.layer;
		
		CAKeyframeAnimation *animatedIconAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		animatedIconAnimation.removedOnCompletion = YES;
		animatedIconAnimation.duration = 0.5;
		animatedIconAnimation.delegate = self;
		animatedIconAnimation.path = path;
		animatedIconAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		[iconViewLayer addAnimation:animatedIconAnimation forKey:@"animateIcon"];
		
		// Start the icon animation.
		[iconViewLayer setPosition:CGPointMake(endPoint.x, endPoint.y)];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.5];
		[animatedLabel setTransform:CGAffineTransformMakeScale(0.3, 0.3)];
		[UIView commitAnimations];
		
		[[InstallQueue queue] addPackagesFromArray:updateList];
	}
}


- (void) databaseDidUpdate
{
	[updateList release];
	updateList = [[PackageDatabase database] needUpdates];
	[updateList retain];
	
	if([updateList count] > 0)
		self.parentController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", [updateList count]];
	else
		self.parentController.tabBarItem.badgeValue = nil;
	
	[self.tableView reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
	return 1;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section 
{
	return updateList.count;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath 
{
	PackageCell *cell;	
    static NSString *CellIdentifier = @"Cell";
    cell = (PackageCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) 
		cell = [[[PackageCell alloc] initWithIdentifier:CellIdentifier package:[updateList objectAtIndex:indexPath.row]] autorelease];
	else
		[cell updateWithPackage:[updateList objectAtIndex:indexPath.row]];
	return cell;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
	DetailsViewController *detailViewController = [[DetailsViewController alloc] init];
	detailViewController.package = [updateList objectAtIndex:indexPath.row];
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

