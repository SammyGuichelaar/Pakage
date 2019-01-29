
@interface Package:NSObject
{
	NSString *package;
	NSString *name;
	NSString *version;
	NSString *installedVersion;
	NSString *description;
	NSString *homepage;
	NSString *depiction;
	NSString *maintainer;
	NSString *maintainerEmail;
	NSString *author;
	NSString *authorEmail;
	NSString *sponsor;
	NSString *sponsorEmail;
	NSString *section;
	NSString *filename;
	NSString *icon;
	int size;
	NSString *source;
	int installed;
	int needsUpgrade;
	int essential;
	NSDate *date;
}

@property (nonatomic, retain) NSString *package;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *installedVersion;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *homepage;
@property (nonatomic, retain) NSString *depiction;
@property (nonatomic, retain) NSString *maintainer;
@property (nonatomic, retain) NSString *maintainerEmail;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *authorEmail;
@property (nonatomic, retain) NSString *sponsor;
@property (nonatomic, retain) NSString *sponsorEmail;
@property (nonatomic, retain) NSString *section;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, assign) int size;
@property (nonatomic, assign) int needsUpgrade;
@property (nonatomic, assign) int installed;
@property (nonatomic, assign) int essential;
@property (nonatomic, retain) NSString *source;
@property (nonatomic, retain) NSDate *date;

@end
