
static NSMutableArray *gCydia;
static NSMutableArray *gPakage;
static NSMutableArray *gOther;
static SourceDatabase *gDatabase = nil;
static BOOL            gLoading = NO;
static NSMutableArray *gNotifications;

@implementation SourceDatabase

+ (SourceDatabase *) database
{
	if(gDatabase != nil)
		return gDatabase;
	else
	{
		SourceDatabase *db = [[SourceDatabase alloc] init];
		gPakage = [NSMutableArray array];
		[gPakage retain];
		gCydia = [NSMutableArray array];
		[gCydia retain];
		gOther = [NSMutableArray array];
		[gOther retain];
		gNotifications = [NSMutableArray array];
		[gNotifications retain];
		gDatabase = db;
		
		[gDatabase loadSources];
		return db;
	}
}

- (void) loadSources
{
	NSString *path;
	if(!IN_IPHONE_SIMULATOR)
		path = @"/etc/apt/sources.list.d";
	else
		path = [NSString stringWithFormat:@"%@/sources.list.d", [[NSBundle mainBundle] resourcePath]];
	
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
	NSArray *parts, *chunks;
	NSMutableArray *current;
	for(NSString *file in files)
	{
		if([file isEqualToString:@"cydia.list"])
			current = gCydia;
		else if([file isEqualToString:@"pakage.list"])
			current = gPakage;
		else
			current = gOther;
				
		parts = [[NSString stringWithContentsOfFile:[path stringByAppendingFormat:@"/%@", file]] componentsSeparatedByString:@"\n"];
		for(NSString *part in parts)
		{
			chunks = [part componentsSeparatedByString:@" "];
			if(![[chunks objectAtIndex:0] isEqualToString:@"deb"] && ![[chunks objectAtIndex:0] isEqualToString:@"deb-src"])
				continue;
			[current addObject:chunks];
		}
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

- (void) notify:(BOOL) type
{
	for(id object in gNotifications)
	{
		if(!type && [object respondsToSelector:@selector(sourcesDidUpdate)])
			[object performSelectorOnMainThread:@selector(sourcesDidUpdate) withObject:nil waitUntilDone:NO];
		else if(type && [object respondsToSelector:@selector(sourcesDidStartLoading)])
			[object performSelectorOnMainThread:@selector(sourcesDidStartLoading) withObject:nil waitUntilDone:NO];
	}
}

- (BOOL) isLoading
{
	return gLoading;
}

#pragma mark -
#pragma mark Signgleton helpers

- (id) copyWithZone:(NSZone *) zone { return self; }
- (id) retain { return self; }
- (unsigned) retainCount { return UINT_MAX; }
- (void) release {}
- (id) autorelease { return self; }

- (NSArray *) allSources
{
	NSArray *ret = [NSArray array];
	ret = [ret arrayByAddingObjectsFromArray:gPakage];
	ret = [ret arrayByAddingObjectsFromArray:gCydia];
	ret = [ret arrayByAddingObjectsFromArray:gOther];
	return ret;
}

- (NSMutableArray *) pakageSources
{
	return gPakage;
}

- (NSMutableArray *) cydiaSources
{
	return gCydia;
}

- (NSMutableArray *) otherSources
{
	return gOther;
}

- (void) dumpWithCurrent:(NSMutableArray *) current andFile:(NSString *) file
{
	NSString *path;
	if(!IN_IPHONE_SIMULATOR)
		path = @"/etc/apt/sources.list.d/";
	else
		path = [NSString stringWithFormat:@"%@/sources.list.d/", [[NSBundle mainBundle] resourcePath]];
	
	NSMutableString *data = [NSMutableString string];
	for(NSArray *entry in current)
	{
		NSMutableString *str = [NSMutableString string];
		int i = 0;
		for(NSString *obj in entry)
		{
			[str appendString:obj];
			i++;
			if(i != entry.count)
				[str appendString:@" "];
			else
				[str appendString:@"\n"];
		}
	}
	[data writeToFile:[path stringByAppendingString:file] atomically:YES encoding:NSASCIIStringEncoding error:NULL];		
}

- (void) addSource:(NSString *) src
{
	// TODO: vaildate source!
	
	if(![src hasSuffix:@"/"])
		src = [src stringByAppendingString:@"/"];
	
	[gPakage addObject:[NSArray arrayWithObjects:@"deb", src, @"./", nil]];

	[self dumpWithCurrent:gPakage andFile:@"pakage.list"];
}

- (void) removeSource:(NSString *) src fromList:(int) section
{
	NSMutableArray *current = nil;
	NSString *file;
	if(section == 0)
	{
		file = @"pakage.list";
		current = gPakage;
	}
	if(section == 1)
	{
		file = @"cydia.list";
		current = gCydia;
	}
	
	if(!current)
		return;
	
	int i;
	for(i = 0; i < current.count; i++)
	{
		if([src isEqualToString:[[current objectAtIndex:i] objectAtIndex:1]])
		{
			[current removeObjectAtIndex:i];
			break;
		}
	}
	[self dumpWithCurrent:current andFile:file];
}

- (void) refreshSources
{
	gLoading = YES;
	[self notify:YES];
	system("apt-get update");
	gLoading = NO;
	[self notify:NO];
}

@end
