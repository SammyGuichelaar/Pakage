
@interface PakageAppDelegate:UIApplication <UIAccelerometerDelegate, UITabBarDelegate>
{
    UIWindow *window;
	UITabBarController *tabBarController;
	NSMutableArray *toStash;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableArray *toStash;

@end

int command(NSString *aCommand);