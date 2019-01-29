
@interface SourceDatabase:NSObject 
{
}

+ (SourceDatabase *) database;
- (BOOL) isLoading;
- (void) addNotification:(id) object;
- (void) removeNotification:(id) object;
- (NSArray *) allSources;
- (NSMutableArray *) pakageSources;
- (NSMutableArray *) cydiaSources;
- (NSMutableArray *) otherSources;
- (void) addSource:(NSString *) src;
- (void) removeSource:(NSString *) src fromList:(int) section;
- (void) loadSources;
- (void) refreshSources;

@end
