
@interface PackageDatabase:NSObject 
{

}

+ (PackageDatabase *) database;
- (void) addPackage:(Package *) pkg;
- (void) loadAptCacheFile:(NSString *) fn;
- (BOOL) loadAptCache;
- (void) reloadSections;
- (BOOL) refreshFromCache;
- (NSArray *) allPackages;
- (NSArray *) allSections;
- (NSMutableArray *) packagesWithSearch:(NSString *) substring;
- (NSMutableArray *) installedPackages;
- (NSArray *) datesForPackages;
- (NSMutableArray *) recent;
- (NSMutableArray *) recentDates;
- (NSMutableArray *) needUpdates;
- (Package *) packageForPackageID:(NSString *) packageID;
- (NSMutableArray *) packagesInSection:(NSString *) section;
- (BOOL) loadDPKGCache;
- (void) removeNotification:(id) object;
- (void) addNotification:(id) object;
- (BOOL) isLoading;
- (void) scanForUpdates;

@end
