
#import "Management.h"


@implementation Management
/*
+ (BOOL) initializePackageLists
{
	NSDate *date = [NSDate date];
	if(!IN_IPHONE_SIMULATOR)
	{
		NSArray *aptLists = [FILEMANAGER contentsOfDirectoryAtPath:@"/var/lib/apt/lists/" error:NULL];
		if(!aptLists)
			return NO;
		
		for(NSString *element in aptLists)
		{
			if([element hasSuffix:@"Packages"])
				[Management addPackagesFromFile:element date:date];
		}
	}
	else
		return NO;
	return YES;
}
				
+ (BOOL) initializeSourceLists
{
	
	if(!IN_IPHONE_SIMULATOR)
	{
		NSLog(@"Adding sources...");
		NSArray *aptLists = [FILEMANAGER contentsOfDirectoryAtPath:@"/var/lib/apt/lists/" error:NULL];
		if(!aptLists)
			return NO;
					
		for(NSString *element in aptLists)
		{
			if([element hasSuffix:@"Release"])
				[Management addSourceFromFile:element];
		}
	}
	else
		return NO;
	return YES;
}

+ (BOOL) addPackagesFromFile:(NSString *) path date:(NSDate *) date
{
	NSLog(@"Adding from: %@", path);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSAutoreleasePool *pool2;
	NSString *data = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"/var/lib/apt/lists/%@", path]];
	NSArray *packages = [data componentsSeparatedByString:@"\n\n"];
	int iter = 0;
	NSString *elem;
	for(iter = 0; iter < packages.count; iter++)
	{
		elem = [packages objectAtIndex:iter];
		if(iter % 20 == 0)
			pool2 = [[NSAutoreleasePool alloc] init];
		NSMutableDictionary *elements = [Management parseDebianControlElementFast:elem];
		if([elements objectForKey:@"Package"] == nil)
		{
			if(iter % 20 == 0)
				[pool2 release];
			continue;
		}
		Package *pkg = [[Package alloc] init];
		pkg.package = [elements objectForKey:@"Package"];
		NSLog(@"Added package: %@", pkg.package);
		pkg.name = [elements objectForKey:@"Name"];
		pkg.version = [elements objectForKey:@"Version"];
		pkg.homepage = [elements objectForKey:@"Homepage"];
		pkg.description = [elements objectForKey:@"Description"];
		pkg.maintainer = [elements objectForKey:@""];
		pkg.maintainerEmail = [elements objectForKey:@""];
		pkg.author = [elements objectForKey:@""];
		pkg.authorEmail = [elements objectForKey:@""];
		pkg.sponsor = [elements objectForKey:@""];
		pkg.sponsorEmail = [elements objectForKey:@""];
		pkg.section = [elements objectForKey:@"Section"];
		pkg.size = [[elements objectForKey:@"Size"] integerValue];
		pkg.filename = [elements objectForKey:@"Filename"];
		pkg.installed = 0;
		pkg.date = date;
		[pkg save];
		[pkg release];
		if(iter % 20 == 0)
			[pool2 release];
	}
	[pool release];
	return YES;
}

+ (BOOL) addSourceFromFile:(NSString *) path
{
	NSLog(@"Adding from: %@", path);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *data = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"/var/lib/apt/lists/%@", path]];
	NSMutableDictionary *elements = [Management parseDebianControlElement:data];
	
	PackageSource *src = [[PackageSource alloc] init];
	src.origin = [elements objectForKey:@"Origin"];
	src.label = [elements objectForKey:@"Label"];
	src.version = [elements objectForKey:@"Version"];
	src.description = [elements objectForKey:@"Description"];
	src.baseurl = [[[path lastPathComponent] componentsSeparatedByString:@"_._"] objectAtIndex:0];
	src.packageurl = src.baseurl;
	[src save];
	[src release];
	[pool release];
	return YES;
}
				
+ (NSMutableDictionary *) parseDebianControlElement:(NSString *) data
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	NSArray *lines = [data componentsSeparatedByString:@"\n"];
	NSArray *parts;
	NSString *line;
	NSMutableString *value;
	int iter;
	for(iter = 0; iter < lines.count; iter++)
	{
		line = [lines objectAtIndex:iter];
		parts = [line componentsSeparatedByString:@": "];
		if(parts.count == 1)
			continue;
		
		if([[lines objectAtIndex:iter] hasPrefix:@" "])
		{
			value = [NSMutableString stringWithString:[parts objectAtIndex:1]];
			for(iter = 0; iter < lines.count; iter++)
			{
				if([[lines objectAtIndex:iter] hasPrefix:@" ."])
				   [value appendString:@"\n\n"];
				else if([[lines objectAtIndex:iter] hasPrefix:@" "])
					[value appendString:[[lines objectAtIndex:iter] substringFromIndex:1]];
			}
			[dict setObject:value forKey:[parts objectAtIndex:0]];
		}
		else
			[dict setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
	}
	return dict;
}

+ (NSMutableDictionary *) parseDebianControlElementFast:(NSString *) data
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSString *key;
	NSString *value;
	NSString *next;
	NSMutableString *newvalue;
	
	NSScanner *scan = [NSScanner scannerWithString:data];
	while(![scan isAtEnd])
	{
		[scan scanUpToString:@": " intoString:&key];
		if([key isEqualToString:@"\n"])
			break;
		scan.scanLocation = scan.scanLocation + 2;
		[scan scanUpToString:@"\n" intoString:&value];
		if(![scan isAtEnd])
			scan.scanLocation = scan.scanLocation + 1;
		
		if(![scan isAtEnd])
		{
			newvalue = [NSMutableString stringWithString:value];
			while([scan scanUpToCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&next] && [next isEqualToString:@" "])
			{
				scan.scanLocation = scan.scanLocation + 1;
				[scan scanUpToString:@"\n" intoString:&next];
				[newvalue appendString:next];
				scan.scanLocation = scan.scanLocation + next.length + 1;
			}
			//NSLog(@"%@: %@", key, newvalue);
		}
		[dict setObject:newvalue forKey:key];
	}
	return dict;
}
*/
	
@end
				
				/*		
				 Package *pkg = [[Package alloc] init];
				 pkg.package = @"com.icefire.awsum";
				 pkg.name = @"Pakage Test App";
				 pkg.version = @"1.51";
				 pkg.installedVersion = @"1.51";
				 pkg.homepage = @"http://xuzz.net";
				 pkg.description = @"Havin' fun!";
				 //pkg.depiction = @"http://xuzz.net/pakage/web/pakage.html";
				 pkg.maintainer = @"icefire";
				 pkg.maintainerEmail = @"xuzz@xuzz.net";
				 pkg.author = @"Xuzz";
				 pkg.authorEmail = @"xuzz@xuzz.net";
				 pkg.sponsor = @"Xuzz";
				 pkg.sponsorEmail = @"xuzz@xuzz.net";
				 pkg.section = @"Tweaks";
				 pkg.size = 0;
				 pkg.filename = @"./no.shit";
				 pkg.installed = 1;
				 pkg.date = [NSDate date];
				 [pkg save];
				 
				 
				 PackageSource *src = [[PackageSource alloc] init];
				 src.origin = @"Testing Source";
				 src.label = @"Testing";
				 src.version = @"1.0, bitches!";
				 src.description = @"Random testing source!";
				 src.baseurl = @"http://xuzz.net";
				 src.packageurl = @"http://xuzz.net";
				 [src save];
				 
				 To get installed packages:
				 dpkg --get-selections
				 
				 To get package info (one package):
				 dpkg --status PACKAGE
				 
				 To get all packages:
				 [Read /var/lib/apt/lists/*Packages and concat, then parse the output]
				 
				 To refresh sources:
				 apt-get -y -q update
				 
				 To get source list:
				 [Read /etc/apt/sources.list.d/* and concat, delete blank lines and all following a #]
				 
				 To get source info:
				 [Parse /var/lib/apt/lists/*Release -- but not *Release.gpg]
				 
				 To add a source:
				 [Append to /etc/apt/sources.list.d/pakage.list]
				 
				 To install package:
				 dpkg -i PACKAGE.deb | apt-get install PACKAGE
				 
				 To remove package:
				 dpkg -r PACKAGE	
				 */


/**********

 CGRect buttonFrame = [activeInstance convertRect:CGRectMake(18, 14, 22, 22) toView:keyWindow];
 
// Icon animation

// Determine the animation's path.
CGPoint startPoint = CGPointMake(buttonFrame.origin.x + buttonFrame.size.width / 2, buttonFrame.origin.y + buttonFrame.size.height / 2);
CGPoint curvePoint1 = CGPointMake(startPoint.x + 90, startPoint.y - 150);
CGPoint endPoint = CGPointMake(CGRectGetMidX(cellFrame), CGRectGetMidY(cellFrame));
CGPoint curvePoint2 = CGPointMake(startPoint.x + 140, endPoint.y - 40);

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

UIImageView* animatedLabel = [[UIImageView alloc] initWithImage:savedIcon];
animatedLabel.tag = 12345;
[enclosingView addSubview:animatedLabel];
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
[UIView setAnimationDuration:0.3];
[animatedLabel setTransform:CGAffineTransformMakeScale(0.3, 0.3)];
[UIView commitAnimations];

 
 //// SQLITE SHIT //////
 
 #pragma mark -
 #pragma mark Database Loading
 
 - (BOOL) loadDatabase:(NSString *) dbfn
 {
 char *errorMsg;
 
 if(sqlite3_open([dbfn UTF8String], &database) != SQLITE_OK) 
 {
 sqlite3_close(database);
 return NO;
 }
 
 sqlite3_exec(database, "PRAGMA encoding = \"UTF-8\"", NULL, NULL, &errorMsg);
 sqlite3_exec(database, "PRAGMA auto_vacuum=1", NULL, NULL, &errorMsg);
 
 const char *sqlStatement = "SELECT * FROM packages";
 sqlite3_stmt *compiledStatement;
 int ret = sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL);
 if(ret == SQLITE_OK) 
 {
 NSLog(@"Database time");
 while(sqlite3_step(compiledStatement) == SQLITE_ROW) 
 {
 Package *pkg = [[Package alloc] init];
 pkg.package = getString(sqlite3_column_text(compiledStatement, 0));
 pkg.name = getString(sqlite3_column_text(compiledStatement, 1));
 pkg.description = getString(sqlite3_column_text(compiledStatement, 2));
 pkg.depiction = getString(sqlite3_column_text(compiledStatement, 3));
 pkg.homepage = getString(sqlite3_column_text(compiledStatement, 4));
 pkg.version = getString(sqlite3_column_text(compiledStatement, 5));
 pkg.section = getString(sqlite3_column_text(compiledStatement, 6));
 pkg.filename = getString(sqlite3_column_text(compiledStatement, 7));
 pkg.icon = getString(sqlite3_column_text(compiledStatement, 8));
 pkg.author = getString(sqlite3_column_text(compiledStatement, 9));
 pkg.authorEmail = getString(sqlite3_column_text(compiledStatement, 10));
 pkg.source = getString(sqlite3_column_text(compiledStatement, 11));
 pkg.date = dateFromSQL(getString(sqlite3_column_text(compiledStatement, 12)));
 pkg.installed = sqlite3_column_int(compiledStatement, 13);
 pkg.essential = sqlite3_column_int(compiledStatement, 14);
 [self addPackage:pkg];
 [pkg release];
 }
 }
 else
 NSLog(@"Failed to database: %d", ret);
 sqlite3_finalize(compiledStatement);
 sqlite3_close(database);
 
 [self parseDPKGDatabase];
 [self reloadSections];
 [self notify:NO];
 return YES;
 }
 
 - (BOOL) savePackageList:(NSString *) dbfn
 {
 char *errorMsg;
 
 if(sqlite3_open([dbfn UTF8String], &database) != SQLITE_OK) 
 {
 sqlite3_close(database);
 return NO;
 }
 
 sqlite3_exec(database, "PRAGMA encoding = \"UTF-8\"", NULL, NULL, &errorMsg);
 sqlite3_exec(database, "PRAGMA auto_vacuum=1", NULL, NULL, &errorMsg);
 sqlite3_exec(database, "DELETE FROM packages", NULL, NULL, &errorMsg);
 
 NSLog(@"Prepare for evil");
 
 const char *sqlStatement = "INSERT INTO packages VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
 sqlite3_stmt *compiledStatement;
 int ret = sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL);
 if(ret == SQLITE_OK) 
 {
 NSLog(@"Prepaired the soup!");
 for(Package *pkg in gPackages)
 {
 sqlite3_bind_text(compiledStatement, 1, [pkg.package UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 2, [pkg.name UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 3, [pkg.description UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 4, [pkg.depiction UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 5, [pkg.homepage UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 6, [pkg.version UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 7, [pkg.section UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 8, [pkg.filename UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 9, [pkg.icon UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 10, [pkg.author UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 11, [pkg.authorEmail UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 12, [pkg.source UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_text(compiledStatement, 13, [dateForSQL(pkg.date) UTF8String], -1, SQLITE_STATIC);
 sqlite3_bind_int(compiledStatement, 14, pkg.installed);
 sqlite3_bind_int(compiledStatement, 15, pkg.essential);
 sqlite3_step(compiledStatement);
 sqlite3_reset(compiledStatement);
 }
 NSLog(@"Souped!");
 }
 else
 NSLog(@"Failed to prepare the soup because of %d.", ret);
 sqlite3_finalize(compiledStatement);
 sqlite3_close(database);
 
 return YES;
 }
 

***********/