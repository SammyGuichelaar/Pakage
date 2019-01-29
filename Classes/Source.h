
@interface PackageSource:NSObject
{
	NSString *origin;
	NSString *label;
	NSString *version;
	NSString *description;
	NSString *baseurl;
	NSString *packageurl;
}

@property (nonatomic, retain) NSString *origin;
@property (nonatomic, retain) NSString *label;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *baseurl;
@property (nonatomic, retain) NSString *packageurl;

@end
