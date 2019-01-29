#import "ABScreenshotView.h"

#define PADDING_TOP 18.0
#define SPADDING_TOP 18.0	
#define SPADDING_BTM 18.0

#define DARK_BACKGROUND  [UIColor colorWithRed:161.0/255.0 green:162.0/255.0 blue:164.0/255.0 alpha:1.0]

@implementation ABScreenshotView

@synthesize scrollView, pageControl, superView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}
- (id)initWithScreenshots:(NSArray *)screenshots inView:(id)theView belowObject:(id)anObject {
	if (self = [super init]) {
		
		[self setSuperView:theView];
		
		//Set approxomite frame and position
		float originX = -10.0;
		float originY = ([anObject frame].origin.y + [anObject frame].size.height + PADDING_TOP);
		
		if (anObject == nil) originY = 0;
		
		float sizeWidth = 320;
		float sizeHeight = 367;
		
		[self setFrame:CGRectMake(originX, originY, sizeWidth, sizeHeight)];
		
		[self setBackgroundColor:DARK_BACKGROUND];
		
		UIView *topShadow = [[[UIView alloc] initWithFrame:CGRectMake(0, -1, 320, 28)] autorelease];
		[topShadow setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"screen_bg.png"]]];
		[self addSubview:topShadow];
		
		UIView *bottomShadow = [[[UIView alloc] initWithFrame:CGRectMake(0, (sizeHeight - 27), 320, 28)] autorelease];
		[bottomShadow setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"screen_bg_btm.png"]]];
		[self addSubview:bottomShadow];
		
		NSUInteger kNumberOfPages = [screenshots count];
		NSLog(@"ABScreenshotView[kNumberOfPages]: %i", kNumberOfPages);
		
		//Set up scroll view
		float sOriginX = 0;
		float sOriginY = SPADDING_TOP;
		float sSizeWidth = 320;
		float sSizeHeight = (367 - SPADDING_BTM - SPADDING_TOP);
		
		NSLog(@"ABScreenshotView[sOriginY]: %f", sOriginY);
		NSLog(@"ABScreenshotView[sSizeHeight]: %f", sSizeHeight);
		
		[self setScrollView:[[UIScrollView alloc] initWithFrame:CGRectMake(sOriginX, sOriginY, sSizeWidth, sSizeHeight)]];
		
		scrollView.pagingEnabled = YES;
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.scrollsToTop = NO;	
		scrollView.delegate = self;
		[scrollView setBackgroundColor:[UIColor clearColor]];
		
		float imageViewX = 54;
		float imageViewY = 0;
		float imageViewWidth = 212;
		float imageViewHeight = 317;
		
		NSLog(@"ABScreenshotView[imageViewY]: %f", imageViewY);
		
		for (int i = 0; i < kNumberOfPages;) {
			
			if (i > 0) imageViewX += 108;
			
			float currentImageViewX = (imageViewX + (imageViewWidth * i));
			
			UIImageView *shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_shadow.png"]];
			[shadowView setFrame:CGRectMake((currentImageViewX - 3), (imageViewY - 3), 221, 327)];
			[scrollView addSubview:shadowView];
			
			EGOImageView *currentImageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"screen_placeholder.png"]];
			[currentImageView setImageURL:[NSURL URLWithString:[screenshots objectAtIndex:i]]];
			[currentImageView setFrame:CGRectMake(currentImageViewX, imageViewY, imageViewWidth, imageViewHeight)];
			[currentImageView setContentMode:UIViewContentModeScaleToFill];
			[scrollView addSubview:currentImageView];
			
			i++;
		}
		
		[self addSubview:scrollView];
		
		[self setPageControl:[[UIPageControl alloc] initWithFrame:CGRectMake(0, 337, 320, 36)]];
		pageControl.numberOfPages = kNumberOfPages;
		pageControl.currentPage = 0;
		pageControl.hidesForSinglePage = YES;
		pageControl.userInteractionEnabled = NO;
		[self addSubview:pageControl];
		[self bringSubviewToFront:pageControl];
	}
	return self;
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    //if (pageControlUsed) {
	// do nothing - the scroll was initiated from the page control, not the user dragging
	//  return;
    //}
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
	
	[self scrollToVisible];
}
+ (NSArray *)testScreenshotArray {
	return [NSArray arrayWithObjects:
		[[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"screen1" ofType:@"png" inDirectory:@""] isDirectory:NO] absoluteString], 
		[[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"screen2" ofType:@"png" inDirectory:@""] isDirectory:NO] absoluteString], 
		[[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"screen3" ofType:@"png" inDirectory:@""] isDirectory:NO] absoluteString], 
		[[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"screen4" ofType:@"png" inDirectory:@""] isDirectory:NO] absoluteString],
		nil];
}
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
- (void)scrollToVisible {
	CGRect scrollFrame = CGRectMake(0, (self.frame.origin.y + 69), self.frame.size.width, self.frame.size.height);
	if (superView != nil && [superView respondsToSelector:@selector(scrollRectToVisible:animated:)]) {
		[superView scrollRectToVisible:scrollFrame animated:YES];
	}
}
- (void)dealloc {
	[scrollView release];
	[pageControl release];
    [super dealloc];
}

@end
