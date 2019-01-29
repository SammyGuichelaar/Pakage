
@implementation RemoveOperation
@synthesize package;

- initWithPackage:(Package *) pkg
{
	if(self = [super init])
		package = [pkg retain];
	
	return self;
}

- (void) dealloc
{
	[package release];
	[super dealloc];
}

- (void) main
{
	NSLog(@"Uninstall running running! %@", package.package);
	int ret = 0;
	
	if(IN_IPHONE_SIMULATOR)
		sleep(4);
	else
		ret = command([NSString stringWithFormat:@"/usr/bin/dpkg --remove %@", package.package]);
	
	if(ret == 0)
	{
		package.installedVersion = nil;
		package.installed = NO;
		package.needsUpgrade = NO;
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"An error occured uninstalling %@ (%@ v%@).", package.name, package.package, package.version] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
		[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
		[alert release];
	}
}

@end
