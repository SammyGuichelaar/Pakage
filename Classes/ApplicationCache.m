
static ApplicationCache *gCache;

@implementation ApplicationCache

+ (ApplicationCache *) cache
{
	if(gCache != nil)
		return gCache;
	else
	{
		gCache = [[ApplicationCache alloc] init];
		return gCache;
	}
}

- (id) copyWithZone:(NSZone *) zone { return self; }
- (id) retain { return self; }
- (unsigned) retainCount { return UINT_MAX; }
- (void) release {}
- (id) autorelease { return self; }

- (ApplicationCache *) current
{
	return gCache;
}

// Stolen from Icy, thank you ripdev!
- (void) rebuildMobileInstallationCache
{
	NSData* data = [NSData dataWithContentsOfMappedFile:@"/var/mobile/Library/Caches/com.apple.mobile.installation.plist"];
	
	if (!data)
		return;
	
	NSMutableDictionary* miCache = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListMutableContainersAndLeaves format:NULL errorDescription:NULL];
	if (!miCache)
		return;
	
	NSArray* apps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications" error:nil];
	if (!apps)
		return;
	
	NSMutableDictionary* systemAppsDict = [miCache objectForKey:@"System"];
	NSMutableArray* systemAppsArray = [miCache objectForKey:@"System"];
	
	if (![systemAppsDict isKindOfClass:[NSDictionary class]])
		systemAppsDict = nil;
	
	if (![systemAppsArray isKindOfClass:[NSArray class]])
		systemAppsArray = nil;
	
	[systemAppsDict removeAllObjects];
	[systemAppsArray removeAllObjects];
	
	for (NSString* app in apps)
	{
		NSString* path = [@"/Applications" stringByAppendingPathComponent:app];
		if ([[path pathExtension] isEqualToString:@"app"])
		{
			NSMutableDictionary* infoPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:@"Info.plist"]];
			
			if (infoPlist && [infoPlist objectForKey:@"CFBundleIdentifier"])
			{
				[infoPlist setObject:path forKey:@"Path"];
				[infoPlist setObject:@"System" forKey:@"ApplicationType"];
				
				[systemAppsDict setObject:infoPlist forKey:[infoPlist objectForKey:@"CFBundleIdentifier"]];
				[systemAppsArray addObject:infoPlist];
			}
			
			[infoPlist release];
		}
	}
	
	// Save out
	data = [NSPropertyListSerialization dataFromPropertyList:miCache format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
	if (data)
		[data writeToFile:@"/var/mobile/Library/Caches/com.apple.mobile.installation.plist" options:NSAtomicWrite error:nil];
	
	notify_post("com.apple.mobile.application_installed");
}

@end
