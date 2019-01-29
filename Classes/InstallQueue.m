
static NSMutableArray *gNotifications;
static NSOperationQueue *operationQueue;
static InstallQueue *gQueue = nil;

@implementation InstallQueue

+ (InstallQueue *) queue
{
	if(gQueue != nil)
		return gQueue;
	else
	{
		operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:1];
		gNotifications = [NSMutableArray array];
		[gNotifications retain];
		gQueue = [[InstallQueue alloc] init];
		return gQueue;
	}
}

#pragma mark -
#pragma mark Notifications

- (void) addNotification:(id) object
{
	[gNotifications addObject:object];
}

- (void) removeNotification:(id) object
{
	[gNotifications removeObjectIdenticalTo:object];
}

- (void) notifyAdded
{
	for(id object in gNotifications)
	{
		if([object respondsToSelector:@selector(packageWasAdded)])
			[object performSelectorOnMainThread:@selector(packageWasAdded) withObject:nil waitUntilDone:YES];
	}
}

- (void) notifyInstalled:(Package *)package
{
	for(id object in gNotifications)
	{
		if([object respondsToSelector:@selector(packageWasInstalled:)])
			[object performSelectorOnMainThread:@selector(packageWasInstalled:) withObject:package waitUntilDone:YES];
	}
}

#pragma mark -
#pragma mark Signgleton helpers

- (id) copyWithZone:(NSZone *) zone { return self; }
- (id) retain { return self; }
- (unsigned) retainCount { return UINT_MAX; }
- (void) release {}
- (id) autorelease { return self; }

- (NSMutableArray *) allPackages
{
	NSArray *obj = [operationQueue operations];
	NSMutableArray *new = [NSMutableArray array];
	for(NSOperation *oper in obj)
		[new addObject:[oper package]];
	return new;
}

- (void) addPackagesFromArray:(NSArray *) array
{
	for(Package *pkg in array)
		[self addPackage:pkg];
}

- (void) observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *) context
{
    if([keyPath isEqual:@"isFinished"]) 
	{
		[NSThread detachNewThreadSelector:@selector(rebuildMobileInstallationCache) toTarget:[ApplicationCache cache] withObject:nil];
		[self notifyInstalled:[object performSelector:@selector(package)]];
		[[object performSelector:@selector(package)] release];
    }
}

- (void) addPackage:(Package *) pkg
{
	NSArray *obj = [operationQueue operations];
	for(NSOperation *oper in obj)
	{
		if([oper package] == pkg)
			return;
	}
	InstallOperation *operation = [[InstallOperation alloc] initWithPackage:pkg];
	[operationQueue addOperation:operation];
	[operation addObserver:self
		   forKeyPath:@"isFinished"
			  options:(NSKeyValueObservingOptionNew |
					   NSKeyValueObservingOptionOld)
			  context:NULL];
	NSLog(@"Added %@ to queue.", pkg.package);
	[self notifyAdded];
}

- (void) addPackageToRemove:(Package *) pkg
{
	NSArray *obj = [operationQueue operations];
	for(NSOperation *oper in obj)
	{
		if([oper package] == pkg)
			return;
	}
	RemoveOperation *operation = [[RemoveOperation alloc] initWithPackage:pkg];
	[operationQueue addOperation:operation];
	[operation addObserver:self
				forKeyPath:@"isFinished"
				   options:(NSKeyValueObservingOptionNew |
							NSKeyValueObservingOptionOld)
				   context:NULL];
	NSLog(@"Added %@ to queue to remove.", pkg.package);
	[self notifyAdded];
}

@end
