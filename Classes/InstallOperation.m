
@implementation InstallOperation
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
	NSLog(@"Install running: %@.", package.package);
	int ret = 0;
	
	if(IN_IPHONE_SIMULATOR)
		sleep(4);
	else
		ret = command([NSString stringWithFormat:@"/usr/bin/apt-get -y --force-yes install --reinstall %@", package.package]);
	
	if(ret == 0)
	{
		package.installedVersion = package.version;
		package.installed = YES;
		package.needsUpgrade = NO;
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"An error occured installing %@ (%@ v%@).", package.name, package.package, package.version] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
		[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
		[alert release];
	}
}

@end
