
 #import <UIKit/UIButton.h>

@class NSSet, UIColor;

@interface UINavigationButton : UIButton
{
     NSSet *_possibleTitles;
    int _style;
  int _barStyle;
    UIColor *_tintColor;
    unsigned int _size:2;
    unsigned int _pad:30;
}
 
+ (id)defaultFont;
- (void)_updateStyle;
 - (id)initWithValue:(id)fp8 width:(float)fp12 style:(int)fp16 barStyle:(int)fp20 possibleTitles:(id)fp24 tintColor:(id)fp28;
 - (id)initWithTitle:(id)fp8;
 - (id)initWithTitle:(id)fp8 style:(int)fp12;
 - (id)initWithTitle:(id)fp8 possibleTitles:(id)fp12 style:(int)fp16;
 - (id)initWithImage:(id)fp8 width:(float)fp12 style:(int)fp16;
 - (id)initWithImage:(id)fp8;
 - (id)initWithImage:(id)fp8 style:(int)fp12;
 - (void)dealloc;
 - (id)title;
 - (void)setTitle:(id)fp8;
 - (id)image;
 - (void)setImage:(id)fp8;
 - (BOOL)contentsEqualTo:(id)fp8 withStyle:(int)fp12;
 - (struct CGSize)sizeThatFits:(struct CGSize)fp8;
 - (void)setStyle:(int)fp8;
 - (void)setControlSize:(int)fp8;
 - (int)controlSize;
 - (void)setBarStyle:(int)fp8;
 - (void)setTintColor:(id)fp8;
 - (BOOL)_canHandleStatusBarMouseEvents:(struct __GSEvent *)fp8;
 - (id)tintColor;
 - (int)barStyle;
 - (int)style;

 @end
