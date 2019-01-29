
#import "YFFileBrowser.h"
#define HOME_DIR @"/"
extern UIImage *_UIImageWithName(NSString* name);

UIImage* addImage;
UINavigationButton* addButton = nil;

int kNewFolderAlert = 5;

@implementation AlertPrompt
- (id)initWithTitle:(NSString *)title
            message:(NSString *)message   
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
      okButtonTitle:(NSString *)okayButtonTitle {
		addImage = _UIImageWithName(@"UINavigationBarAddButton.png");
	addButton = [[UINavigationButton alloc] initWithImage:addImage
													style:0];

	if (self = [super initWithTitle:title
							message:message
						   delegate:delegate
				  cancelButtonTitle:cancelButtonTitle
				  otherButtonTitles:okayButtonTitle, nil]) {
		[self addTextFieldWithValue:@"" label:@""];
	}
	return self;
}

- (NSString *)enteredText {
	return [[self textFieldAtIndex:0] text];
}

@end

@implementation YFFileBrowser
@synthesize currentPath;

- (id)initWithPath:(NSString*)path
           context:(id)ctx
          delegate:(id)del
{  
	if (self = [super initWithTitle:nil // set later by setCurrentPath:
							message:@"\n\n\n"
						   delegate:self
				  cancelButtonTitle:@"Cancel"
				  otherButtonTitles:@"Save", nil]) {
		browserDelegate = [del retain];
		context = [ctx retain];
		self.currentPath = path;
		[self draw]; // draw subviews
	}
	return self;
}

- (void) draw
{
	UIView* container = nil;
	container = [[UIView alloc] initWithFrame:CGRectMake(11, 47, 261, 135)];
	container.backgroundColor = [UIColor whiteColor];
	container.clipsToBounds = YES;
	[self addSubview:container];
	
	// _tableView is an ivar
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 261, 135)
											  style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[container addSubview:_tableView];
	
	navButton = [[UINavigationButton alloc] initWithTitle:nil style:1];
	navButton.frame = CGRectMake(10, 10, 70, 29);
	navButton.alpha = 0;
	[navButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:navButton];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	// |_data| is an NSArray* ivar containing the directory contents at currentPath
	return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:@"listCell"] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
	}  
	
	NSString* item = [_data objectAtIndex:indexPath.row];
	NSString* full = [currentPath stringByAppendingPathComponent:item];
	
	cell.textLabel.text = item;
	
	NSFileManager* fm = [NSFileManager defaultManager];
	
	BOOL isDir = NO;
	if ([fm fileExistsAtPath:full
				 isDirectory:&isDir] && isDir) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.textColor = [UIColor blackColor];
		cell.imageView.image = [UIImage imageNamed:@"packagesm.png"];
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.textColor = [UIColor grayColor];
		cell.imageView.image = [UIImage imageNamed:@"packagesm.png"];
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 38.0f;
}

- (NSIndexPath*)tableView:(UITableView *)tableView
 willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* item = [_data objectAtIndex:indexPath.row];
	NSString* full = [currentPath stringByAppendingPathComponent:item];
	NSFileManager* fm = [NSFileManager defaultManager];
	BOOL isDir = NO;
	if ([fm fileExistsAtPath:full
				 isDirectory:&isDir] && isDir) {
		return indexPath;
	}
	return nil; // disallow selection
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString* item = [_data objectAtIndex:indexPath.row];
	CAMediaTimingFunction* timing;
	timing = [CAMediaTimingFunction
			  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	CATransition *animation = [CATransition animation];
	[animation setTimingFunction:timing];
	[animation setDelegate:self];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setDuration:0.3];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:YES];
	[[_tableView layer] addAnimation:animation
							   forKey:@"pushAnim"];
	self.currentPath = [currentPath stringByAppendingPathComponent:item];
}


- (void)newFolder {
	AlertPrompt *prompt = [AlertPrompt alloc];
	prompt = [prompt initWithTitle:@"New Folder"
						   message:@"Enter a name for the new folder"
						  delegate:self
				 cancelButtonTitle:@"Cancel"
					 okButtonTitle:@"OK"];
	prompt.tag = kNewFolderAlert;
	[prompt show];
	[prompt release];  
}


- (void)alertView:(UIAlertView *)alert
clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alert.tag == kNewFolderAlert) {
		if (buttonIndex != [alert cancelButtonIndex])
		{
			NSString *entered = [(AlertPrompt *)alert enteredText];
			NSFileManager* fm = [NSFileManager defaultManager];
			BOOL success = [fm createDirectoryAtPath:
							[currentPath stringByAppendingPathComponent:entered]
										  attributes:nil];
			if (success) {
				self.currentPath = [currentPath stringByAppendingPathComponent:entered];
			}
		}
	}
	else {
		if (buttonIndex != [alert cancelButtonIndex]) {
			if([browserDelegate respondsToSelector:@selector(fileBrowser:didSelectPath:withContext:)])
				[browserDelegate fileBrowser:self
							didSelectPath:currentPath
							  withContext:context];
		}
		else {
			if([browserDelegate respondsToSelector:@selector(fileBrowserDidCancel:)])
				[browserDelegate fileBrowserDidCancel:self];
		}
	}
}


- (void)setCurrentPath:(NSString*)path {
	[currentPath release];
	currentPath = [path copy];
	if (path == nil) {
		return;
	}
	NSArray *contents = [[NSFileManager defaultManager]
						 directoryContentsAtPath:path];
	self.title = [[currentPath lastPathComponent]
				  stringByAppendingString:@"\n\n\n\n"];
	// |navButton| is the backButton we created earlier
	[navButton setTitle:[[currentPath
						  stringByDeletingLastPathComponent]
						 lastPathComponent]]; // get parent directory path
	if ([currentPath isEqualToString:HOME_DIR]) {
		// mini sandbox to prevent navigating outside a particular directory
		navButton.alpha = 0;
	}
	else {
		navButton.alpha = 1;
	}
	_data = [contents retain];
	[_tableView reloadData];
}

- (void)back {
	CATransition *animation = [CATransition animation];
	[animation setTimingFunction:
	 [CAMediaTimingFunction
	  functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setDelegate:self];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	[animation setDuration:0.3];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:YES];
	[[_tableView layer] addAnimation:animation forKey:@"pushAnim"];
	self.currentPath = [currentPath stringByDeletingLastPathComponent];
}

@end
