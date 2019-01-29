
static NSMutableArray *gPackages;
static NSMutableArray *gSections;
static NSMutableArray *gNotifications;
static NSMutableArray *gTempPackages;
static NSMutableDictionary *gDates;
static PackageDatabase *gDatabase = nil;
static BOOL gLoading = NO;
static NSDate *gDate;

@implementation PackageDatabase

+ (PackageDatabase *) database
{
	if(gDatabase != nil)
		return gDatabase;
	else
	{
		PackageDatabase *db = [[PackageDatabase alloc] init];
		gNotifications = [NSMutableArray array];
		[gNotifications retain];
		gSections = [NSMutableArray array];
		[gSections retain];
		gPackages = [NSMutableArray array];
		[gPackages retain];
		gDates = [NSMutableDictionary dictionary];
		[gDates retain];
		gTempPackages = [NSMutableArray array];
		[gTempPackages retain];
		gDatabase = db;
		return db;
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
		if(!type && [object respondsToSelector:@selector(databaseDidUpdate)])
			[object performSelectorOnMainThread:@selector(databaseDidUpdate) withObject:nil waitUntilDone:NO];
		else if(type && [object respondsToSelector:@selector(databaseDidStartLoading)])
			[object performSelectorOnMainThread:@selector(databaseDidStartLoading) withObject:nil waitUntilDone:NO];
	}
}

- (BOOL) isLoading
{
	return gLoading;
}

#pragma mark -
#pragma mark Singleton helpers

- (id) copyWithZone:(NSZone *) zone { return self; }
- (id) retain { return self; }
- (unsigned) retainCount { return UINT_MAX; }
- (void) release {}
- (id) autorelease { return self; }

#pragma mark -
#pragma mark Refreshing

- (BOOL) refreshFromCache
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	gLoading = YES;
	[self notify:YES];
	
	NSDate *gDate = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *todayDateString = [dateFormatter stringFromDate:gDate];
	[dateFormatter release];
	[gDates setObject:[NSMutableArray array] forKey:todayDateString];
	
	[self loadAptCache];
	[self loadDPKGCache];
	[self scanForUpdates];
	[self performSelectorOnMainThread:@selector(substituteTemp) withObject:nil waitUntilDone:YES];
	[self reloadSections];
	gLoading = NO;
	[self notify:NO];
	[pool release];
	return YES;
}

- (void) substituteTemp
{
	NSMutableArray *old = gPackages;
	gPackages = gTempPackages;
	[old release];
	gTempPackages = [NSMutableArray array];
	[gTempPackages retain];	
}

- (void) reloadSections
{
	[gSections release];
	gSections = [NSMutableArray array];
	for(Package *pkg in gPackages)
	{	
		if(pkg.section != nil && ![gSections containsObject:pkg.section])
		{
			[gSections addObject:pkg.section];
			[pkg.section release];
		}
	}
	gSections = [NSMutableArray arrayWithArray:[[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:gSections collationStringSelector:@selector(copy)]];
	[gSections retain];
}

- (BOOL) loadAptCache
{
	DIR *topdir;
	struct dirent *dp;
	
	if(!IN_IPHONE_SIMULATOR)
		topdir = opendir("/var/lib/apt/lists");
	else
		topdir = opendir([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/lists"] UTF8String]);
	if(topdir != NULL)
	{
		do
		{
			if((dp = readdir(topdir)) && dp->d_type != DT_DIR && memcmp(dp->d_name, ".", 1) != 0 && strstr(dp->d_name, "Packages") && !strstr(dp->d_name, ".IndexDiff"))		
				[self loadAptCacheFile:[NSString stringWithCString:dp->d_name]];
		} while(dp);
		closedir(topdir);
	}
	
	[self reloadSections];
	return YES;
}

- (void) loadAptCacheFile:(NSString *) fileName
{
	NSString *pathName;
	if(!IN_IPHONE_SIMULATOR)
		pathName = @"/var/lib/apt/lists/";
	else
		pathName = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/lists/"];
	
	FILE *fp;
	char buf[0x400];
	char val[0x4000];
	char key[0x400];
	int x, colon, off = 0;
	Package *pkg;
	
	NSLog(@"Loading %@", fileName);
	fp = fopen([[NSString stringWithFormat:@"%@%@", pathName, fileName] UTF8String], "rb");
	if(fp == NULL)
		return;
	if(fgets(buf, 0x400, fp) == NULL)
		return;
	
	pkg = [[Package alloc] init];
	while(1)
	{
		if(*buf == '\n') // new pakgage! save this one and move on
		{
			pkg.installed = 0;
			if(!pkg.author)
			{
				pkg.author = @"Unknown.";
				pkg.authorEmail = @"";
			}
			else
			{
				NSArray *parts = [pkg.author componentsSeparatedByString:@"<"];
				if(!parts)
				{
					pkg.author = @"Unknown";
					pkg.authorEmail = @"";
				}
				else
				{
					if(parts.count > 1) // yay, has an email
					{
						pkg.author = [[parts objectAtIndex:0] substringToIndex:[[parts objectAtIndex:0] length] - 1];
						pkg.authorEmail = [[parts objectAtIndex:1] substringToIndex:[[parts objectAtIndex:1] length] - 1];
					}
					else // we don't need to set the author because its already correct!
						pkg.authorEmail = @"";
				}
			}
			
			pkg.date = gDate;
			if(pkg.name == nil)
				pkg.name = pkg.package;
			if(pkg.package != nil)
				[self addPackage:pkg];
			[pkg release];
			
			if(fgets(buf, 0x400, fp) == NULL)
				break;
			
			pkg = [[Package alloc] init];
			continue;
		}
		
		char *here = strchr(buf, ':');
		if(here != NULL && *buf != ' ') // this line has a key
		{
			colon = here - buf;
			strncpy(key, buf, colon);
			key[colon] = 0x00;
			strncpy(val + off, buf + colon + 2 /* add two to get rid of colon-space */, strlen(buf + colon));
			val[strlen(buf + colon) - 3] = 0x00;
		}
		else // this line has no key, just skip the space
		{
			x = strlen(val);
			val[x] = ' ';
			val[x + 1] = 0x00;
			strncpy(val + off, buf + 1, strlen(buf) - 2);
			x = strlen(val);
			val[x] = ' ';
			val[x + 1] = 0x00;
		}
		off = strlen(val);
		
		if(fgets(buf, 0x400, fp) == NULL || *buf == 0x00)
			break;
		
		if(*buf != ' ') // next line has a new key, so we need to save
		{
			off = 0;
			// save key -> val into pkg
			if(strcasecmp(key, "Package") == 0)
				pkg.package = [NSString stringWithCString:val];
			else if(strcasecmp(key, "Version") == 0)
				pkg.version = [NSString stringWithCString:val];
			else if(strcasecmp(key, "Section") == 0)
				pkg.section = [[NSString stringWithCString:val] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
			else if(strcasecmp(key, "Filename") == 0)
				pkg.filename = [NSString stringWithCString:val];
			else if(strcasecmp(key, "Homepage") == 0)
				pkg.homepage = [NSString stringWithCString:val];
			else if(strcasecmp(key, "Depiction") == 0)
				pkg.depiction = [NSString stringWithCString:val];
			else if(strcasecmp(key, "Size") == 0)
				pkg.size = atoi(val);
			else if(strcasecmp(key, "Description") == 0)
				pkg.description = [NSString stringWithCString:val];
			else if(strcasecmp(key, "Name") == 0)
				pkg.name = [NSString stringWithCString:val];
			else if(strcasecmp(key, "Icon") == 0)
				pkg.icon = [NSString stringWithCString:val];
			else if(strcasecmp(key, "Author") == 0)
				pkg.author = [NSString stringWithCString:val];
			else if(strcasecmp(key, "Essential") == 0 && strcasecmp(val, "yes") == 0)
				pkg.essential = YES;
		}
	}
	fclose(fp);
}

- (void) addPackage:(Package *) pkg
{
	[gTempPackages addObject:pkg];
}

#pragma mark -
#pragma mark Specific Package

- (Package *) packageForPackageID:(NSString *) packageID
{
	for(Package *pkg in gPackages)
	{	
		if([pkg.package isEqualToString:packageID])
			return pkg;
	}
	return nil;
}

- (Package *) tempPackageForPackageID:(NSString *) packageID
{
	for(Package *pkg in gTempPackages)
	{	
		if([pkg.package isEqualToString:packageID])
			return pkg;
	}
	return nil;
}

#pragma mark -
#pragma mark Package Retrieval

- (NSArray *) allPackages
{
	return gPackages;
}

- (NSArray *) allSections
{
    return gSections;	
}

- (NSMutableArray *) packagesWithSearch:(NSString *) substring
{
	NSMutableArray *ret = [NSMutableArray array];
	NSString *sub = [substring lowercaseString];
	for(Package *pkg in gPackages)
	{	
		if([[pkg.name lowercaseString] rangeOfString:sub].location != NSNotFound || [pkg.package rangeOfString:sub].location != NSNotFound)
			[ret addObject:pkg];
	}
	return ret;
}

- (NSMutableArray *) installedPackages
{
	NSMutableArray *ret = [NSMutableArray array];
	for(Package *pkg in gPackages)
	{	
		if(pkg.installed)
			[ret addObject:pkg];
	}
	ret = [NSMutableArray arrayWithArray:[[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:ret collationStringSelector:@selector(name)]];
	return ret;
}

- (NSArray *) datesForPackages
{
	NSMutableArray *ret = [NSMutableArray array];
	for(Package *pkg in gPackages)
	{	
		if(pkg.date != nil && ![ret containsObject:pkg.date])
			[ret addObject:pkg.date];
	}
	NSArray *reversedArray = [[ret reverseObjectEnumerator] allObjects];
	return reversedArray;
}

// returns array of arrays, each sub-array being a list of packages new at that time
- (NSMutableArray *) recent
{
	NSMutableArray *ret = [NSMutableArray array];
	NSArray *dates = [self datesForPackages];
	NSMutableArray *item;
	for(NSDate *date in dates)
	{
		item = [NSMutableArray array];
		for(Package *pkg in gPackages)
		{	
			if([pkg.date compare:date] == NSOrderedSame)
				[item addObject:pkg];
		}
		item = [NSMutableArray arrayWithArray:[[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:item collationStringSelector:@selector(name)]];
		[ret addObject:item];
	}
	return ret;
}

// section headers for recent, in NSString * format
- (NSMutableArray *) recentDates
{
	NSMutableArray *ret = [NSMutableArray array];
	NSArray *dates = [self datesForPackages];
	for(NSDate *date in dates)
		[ret addObject:[date descriptionWithCalendarFormat:@"%m/%d/%Y at %I:%M %p" timeZone:nil locale:nil]];
	return ret;
}

- (void) scanForUpdates
{
	for(Package *pkg in gTempPackages)
	{	
		pkg.needsUpgrade = NO;
		if(pkg.installed && ![pkg.version isEqualToString:pkg.installedVersion])
		{
			if(!IN_IPHONE_SIMULATOR)
			{
				// Use dpkg so we don't have to violate the GPL!
				NSString *str = [NSString stringWithFormat:@"dpkg --compare-versions %@ gt %@", pkg.version, pkg.installedVersion];
				if(!system([str UTF8String]))
					pkg.needsUpgrade = YES;
			}
			else // For simulator debugging
				pkg.needsUpgrade = YES;
		}
	}
}

- (NSMutableArray *) needUpdates
{
	NSMutableArray *ret = [NSMutableArray array];
	for(Package *pkg in gPackages)
	{	
		if(pkg.needsUpgrade == YES)
			[ret addObject:pkg];
	}
	ret = [NSMutableArray arrayWithArray:[[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:ret collationStringSelector:@selector(name)]];
	return ret;
}

- (NSMutableArray *) packagesInSection:(NSString *) section
{
	NSMutableArray *ret = [NSMutableArray array];
	for(Package *pkg in gPackages)
	{	
		if(pkg.section != nil && [pkg.section isEqualToString:section])
			[ret addObject:pkg];
	}
	return ret;
}

#pragma mark -
#pragma mark DPKG Cache

- (BOOL) loadDPKGCache
{
	NSString *path;
	if(IN_IPHONE_SIMULATOR)
		path = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/status"];
	else
		path = @"/var/lib/dpkg/status";
	NSError *err = nil;
	
	NSString *databaseData = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
	if(err) // fallback to ASCII if there's something wrong with the file
		databaseData = [[NSString alloc] initWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&err];
	
	if(!databaseData)
		return NO;
	
	NSArray *packs = [databaseData componentsSeparatedByString:@"\n\n"];
	[databaseData release];
	
	for(NSString *package in packs)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSArray *lines = [package componentsSeparatedByString:@"\n"];
		NSMutableDictionary *newEntry = [NSMutableDictionary dictionaryWithCapacity:0];
		NSString *lastKey = nil;
		
		for(NSString *line in lines)
		{
			if([line hasPrefix:@" "])
			{
				// continue of multi-line object
				if(lastKey)
				{
					NSString *lastValue = [newEntry objectForKey:lastKey];
					
					if([lastValue isKindOfClass:[NSString class]])
						[newEntry setObject:[lastValue stringByAppendingString:line] forKey:lastKey];
				}
				continue;
			}
			
			NSRange separator = [line rangeOfString:@": "];
			if(separator.length)
			{
				NSString *key = [[line substringToIndex:separator.location] lowercaseString];
				NSString *value = [line substringFromIndex:separator.location + separator.length];
				
				lastKey = key;
				
				if(value && key)
					[newEntry setObject:value forKey:key];
			}
		}
		
		if([newEntry count])
		{
			NSString *status = [newEntry objectForKey:@"status"];
			NSArray *comps = [status componentsSeparatedByString:@" "];
			Package *pkg = [self tempPackageForPackageID:[newEntry objectForKey:@"package"]];
			if(pkg != nil)
			{
				if((comps && [comps containsObject:@"install"] && [comps containsObject:@"ok"] && [comps containsObject:@"installed"]))
				{
					pkg.installedVersion = [newEntry objectForKey:@"version"];
					pkg.installed = YES;
				}
				else
				{
					pkg.installed = NO;
					pkg.installedVersion = nil;
				}
			}
		}
		[pool release];
	}

	return YES;
}

@end
