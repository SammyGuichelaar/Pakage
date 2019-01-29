
#import <UIKit/UIKit.h>
#import "UINavigationButton.h"

@interface YFFileBrowser:UIAlertView <UITableViewDataSource, UITableViewDelegate>
{
	NSString *currentPath;
	id browserDelegate;
	id context;
	UINavigationButton *navButton;
	UITableView *_tableView;
	NSArray *_data;
}

@property (nonatomic, copy) NSString* currentPath;
@end


@protocol YFFileBrowserDelegate

- (void)fileBrowser:(YFFileBrowser*)browser
      didSelectPath:(NSString*)path
        withContext:(id)context;

- (void)fileBrowserDidCancel:(YFFileBrowser*)browser;

@end


@interface UIAlertView (PrivateTextFieldStuff)
- (id)addTextFieldWithValue:(id)value label:(id)label;
- (id)textFieldAtIndex:(int)index;
- (int)textFieldCount;
- (id)textField;
@end

@interface AlertPrompt : UIAlertView
- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
      okButtonTitle:(NSString *)okButtonTitle;
- (NSString *)enteredText;
@end
