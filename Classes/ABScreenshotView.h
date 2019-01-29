#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface ABScreenshotView : UIView <UIScrollViewDelegate> {
	UIScrollView *scrollView;
	UIPageControl *pageControl;
	
	id superView;
}
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, assign) id superView;

//Your screenshot array should contain strings only; anObject may be nil if you wish to insert at 0.
- (id)initWithScreenshots:(NSArray *)screenshots inView:(id)theView belowObject:(id)anObject;

//For viewing without the need of parsing a JSON Array yourself...
+ (NSArray *)testScreenshotArray;

//To scroll in superview to visibility 
- (void)scrollToVisible;
@end
