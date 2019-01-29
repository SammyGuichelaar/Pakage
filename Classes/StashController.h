
@interface StashController:UIViewController <UIActionSheetDelegate> 
{
	UIProgressView *progress;
	UIActivityIndicatorView *spinner;
	UILabel *status;
	UILabel *caption;
}

- (void) stashDirectories:(NSArray *) dirs;
- (void) _stash:(NSString *) dir;

@end