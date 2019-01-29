
@interface InstallQueue:NSObject 
{
}

+ (InstallQueue *) queue;
- (void) removeNotification:(id) object;
- (void) addNotification:(id) object;
- (NSMutableArray *) allPackages;
- (void) addPackagesFromArray:(NSArray *) array;
- (void) addPackage:(Package *) pkg;
- (void) addPackageToRemove:(Package *) pkg;

@end
