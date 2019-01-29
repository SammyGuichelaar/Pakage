
int command(NSString *aCommand)
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:[[aCommand componentsSeparatedByString:@" "] objectAtIndex:0]];
	
    NSMutableArray *arguments;
    arguments = [NSMutableArray arrayWithArray:[aCommand componentsSeparatedByString:@" "]];
    [arguments removeObjectAtIndex:0];
    [task setArguments:arguments];

	[task launch];
    [task waitUntilExit];
	int status = [task terminationStatus];
	
	[task release];
	return status;
}

static NSString* gStashableDirectories[] = 
{
#if defined(__i386__)
	@"/tmp/stashTest",
#else
	@"/Applications",
	@"/Library/Ringtones",
	@"/Library/Wallpaper",
	@"/usr/share",
#endif
	nil
};

@implementation PakageAppDelegate
@synthesize window, tabBarController, toStash;

- (void) applicationDidFinishLaunching:(UIApplication *) application 
{   
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	NSString *lastStashVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"StashOSVersion"];
	if(!lastStashVersion || ![lastStashVersion isEqualToString:[UIDevice currentDevice].systemVersion])
	{
		int i;
		toStash = nil;
		
		// check whether we need stashing
		for(i = 0; gStashableDirectories[i]; i++)
		{
			struct stat st;
			
			if(lstat([gStashableDirectories[i] fileSystemRepresentation], &st))
				continue;
			if((st.st_mode & S_IFMT) == S_IFLNK)
				continue;
			if(!toStash)
				toStash = [NSMutableArray arrayWithCapacity:0];
			
			[toStash addObject:gStashableDirectories[i]];
		}
		
		// stash it!
		if(toStash && toStash.count)
		{
			[[NSUserDefaults standardUserDefaults] setObject:[UIDevice currentDevice].systemVersion forKey:@"StashOSVersion"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			StashController *stash = [[StashController alloc] init];
			[window addSubview:stash.view];
			[window makeKeyAndVisible];
			
			return;
		}
	}
	
	
	
	[[PackageDatabase database] addNotification:self];
		
	HomeViewController *homeTab = [[HomeViewController alloc] init];
	homeTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Pakage" image:[UIImage imageNamed:@"home.png"] tag:0];
	homeTab.title = @"Pakage";
	homeTab.navigationController = [[UINavigationController alloc] initWithRootViewController:homeTab];
	
	BrowseViewController *browseTab = [[BrowseViewController alloc] init];
	browseTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Browse" image:[UIImage imageNamed:@"sections.png"] tag:1];
	browseTab.title = @"Browse";
	browseTab.navigationController = [[UINavigationController alloc] initWithRootViewController:browseTab];
	
	RecentViewController *recentTab = [[RecentViewController alloc] init];
	recentTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Recent" image:[UIImage imageNamed:@"recent.png"] tag:2];
	recentTab.title = @"Recent";
	recentTab.navigationController = [[UINavigationController alloc] initWithRootViewController:recentTab];
	if([[[PackageDatabase database] needUpdates] count] > 0)
		recentTab.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", [[[PackageDatabase database] needUpdates] count]];
	
	ManageViewController *manageTab = [[ManageViewController alloc] init];
	manageTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Manage" image:[UIImage imageNamed:@"install.png"] tag:3];
	manageTab.title = @"Manage";
	manageTab.navigationController = [[UINavigationController alloc] initWithRootViewController:manageTab];
	
	SourceViewController *sourceTab = [[SourceViewController alloc] init];
	sourceTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Sources" image:[UIImage imageNamed:@"sources.png"] tag:4];
	sourceTab.title = @"Sources";
	sourceTab.navigationController = [[UINavigationController alloc] initWithRootViewController:sourceTab];
	
	// Preload views
	[homeTab view];
	[recentTab view];
	[browseTab view];
	[manageTab view];
	[sourceTab view];
	
	tabBarController = [[UITabBarController alloc] init];  
	tabBarController.delegate = self;
	tabBarController.viewControllers = [NSArray arrayWithObjects:homeTab.navigationController, recentTab.navigationController, browseTab.navigationController, manageTab.navigationController, sourceTab.navigationController, nil];  
   
	[browseTab release];
	[homeTab release];

	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
	
	// TODO: refresh from sources (based on prefs)
	[NSThread detachNewThreadSelector:@selector(refreshFromCache) toTarget:[PackageDatabase database] withObject:nil];
}

- (void) tabBarController:(UITabBarController *) theTabBarController didSelectViewController:(UIViewController *) viewController
{
	UIViewController *ctrl = nil;
	NSArray *stack = nil;
	
	if([viewController isKindOfClass:[UINavigationController class]])
		stack = ((UINavigationController *) viewController).viewControllers;
	
	if([stack count])
		ctrl = [stack objectAtIndex:0];
	
	if(ctrl && [ctrl isKindOfClass:[BrowseViewController class]])
	{
		if(stack.count > 2)
			[(UINavigationController *) viewController popViewControllerAnimated:NO];
	}
	else
		[(UINavigationController *) viewController popToRootViewControllerAnimated:NO];
}

- (void) applicationWillTerminate:(UIApplication *) application
{
	// nothing to see here
}

- (void) applicationDidBecomeActive:(id) param
{
	// move along...
}

- (void) databaseDidUpdate
{
	// nothing to see here
}

- (void) dealloc 
{
	[[PackageDatabase database] removeNotification:self];
    [window release];
    [super dealloc];
}

@end
