
#import "YFFileBrowser.h"

@implementation HomeViewController
@synthesize navigationController;


- (void) loadView
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	self.view = [[UIView alloc] initWithFrame:bounds];
	
	homeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f - 112.0f) style:UITableViewStyleGrouped];
	homeTableView.delegate = self;
	homeTableView.dataSource = self;
	[self.view addSubview:homeTableView];
	
	headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
	homeTableView.tableHeaderView = headerView;
	[headerView release];
	
	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(77, 0, 250, 50)];
	titleLabel.shadowColor = [UIColor whiteColor];
	titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
	titleLabel.textColor = [UIColor colorWithRed:(76.0/255.0) green:(86.0/255.0) blue:(108.0/255.0) alpha:1.0f];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
	titleLabel.text = @"Welcome to Pakage";
	[headerView addSubview:titleLabel];
	[titleLabel release];
	
	detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(77, 25, 250, 50)];
	detailLabel.shadowColor = [UIColor whiteColor];
	detailLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
	detailLabel.textColor = [UIColor colorWithRed:(76.0/255.0) green:(86.0/255.0) blue:(108.0/255.0) alpha:1.0f];
	detailLabel.backgroundColor = [UIColor clearColor];
	detailLabel.font = [UIFont systemFontOfSize:15.0f];
	detailLabel.text = @"by #HACKERCHANNEL";
	[headerView addSubview:detailLabel];
	[detailLabel release];
	
	iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 57, 57)];
	iconView.image = [UIImage imageNamed:@"Icon.png"];
	[headerView addSubview:iconView];
	[iconView release];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(about)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Donate" style:UIBarButtonItemStyleDone target:self action:@selector(donate)];
	[self.navigationItem.rightBarButtonItem release];
	[self.navigationItem.leftBarButtonItem release];
	
}

- (void) viewDidLoad 
{
    [super viewDidLoad];
}

- (void) viewDidUnload
{
	[homeTableView release];
	homeTableView = nil;
	[super viewDidUnload];
}

- (void) dealloc 
{
    [super dealloc];
}

- (void) about
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"About Pakage" message:@"Contact: info@pakage.net or #HACKERCHANNEL on Freenode\n\nThanks to:\nDustin Howett for code/support.\nYoseff Francis for \"swoosh\".\nmvit for the icon and gfx.\nGlyphish for tab bar icons.\nripdev for Icy." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
	[self.view addSubview:alertView];
	[alertView show];
	[alertView release];
}

- (void) donate
{
	BrowserViewController *browser = [[BrowserViewController alloc] init];
	UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
	[[self navigationItem] setBackBarButtonItem:newBackButton];
	[newBackButton release];
	browser.title = @"Donate";

	browser.url = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=2AZTMSJJ9YPU2&lc=US&item_name=Pakage&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"]];
	[self.navigationController pushViewController:browser animated:YES];
	[browser release];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView 
{
    return 2; //3 for all options, 4 if we enable the screenshots
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section
{
	switch(section)
	{
	    case 0:
	        return 1; // 4;
	    case 1:
	        return 1; // 2;
	    case 2:
	        return 2;
		case 3:
			return 1;
	}
	return 0;
}

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
	if(indexPath.section == 3)
		return 369.0;
	if(indexPath.section == 0 && indexPath.row == 0)
		return 100.0; // big text area
	else
		return 44.0; // everything else
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section
{
	switch(section)
	{
	    case 0:
	        return @"Welcome";
	    case 1:
	        return @"Links"; // @"Information";
	    case 2:
	        return @"Other";
		case 3:
			return @"Screenshots";
	}
	return nil;
}

- (NSString *) tableView:(UITableView *) tableView titleForFooterInSection:(NSInteger) section
{
	switch(section)
	{
	    case 0:
	        return @"Tip: Pakage is on Twitter as PakageApp!";
	    case 1:
	        return @""; // @"Please report any bugs you find.";
	    case 2:
	        return @"Pakage is still in alpha.\nSupport: info@pakage.net";
	}
	return nil;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath 
{
	static NSString *CellIdentifier = @"Cell";
	ABScreenshotView *scr;
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:CellIdentifier] autorelease];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	switch(indexPath.section)
	{
	    case 0:
	    	switch(indexPath.row)
			{
				case 0:
					cell.textLabel.text = @"Welcome to Pakage! THIS APPLICATION IS NOT COMPLETE, EXPECT BUGS. I AM NOT LIABLE FOR ANYTHING THAT HAPPENS.";
					cell.textLabel.font = [UIFont systemFontOfSize:16.0];
					cell.textLabel.numberOfLines = 0;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 1:
					cell.textLabel.text = @"Pakage News";
					break;
				case 2:
					cell.textLabel.text = @"Pakage FAQ";
					break;
				case 3:
					cell.textLabel.text = @"Apple Updates";
					break;
			}
	        break;
	    case 1:
	        switch(indexPath.row)
			{
				case 0:
					cell.textLabel.text = @"Cydia Homepage"; // @"Report a Bug";
					break;
				case 1:
					cell.textLabel.text = @"Suggest a feature";
					break;
			}
	        break;
	    case 2:
	        switch(indexPath.row)
			{
				case 0:
					cell.textLabel.text = @"Known Issues";
					break;
				case 1:
					cell.textLabel.text = @"Change Log";
					break;
			}
	        break;
		case 3:
			scr = [[ABScreenshotView alloc] initWithScreenshots:[ABScreenshotView testScreenshotArray] inView:nil belowObject:nil];
			[cell.contentView addSubview:scr];
			[scr release];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			break;
	}
	return cell;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath 
{    		
	BrowserViewController *browser = [[BrowserViewController alloc] init];
	UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
	[[self navigationItem] setBackBarButtonItem:newBackButton];
	[newBackButton release];
	browser.title = self.title;

    switch(indexPath.section)
	{
	    case 0:
	    	switch(indexPath.row)
			{
				case 1:
					browser.url = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xuzz.net/pakage/web/news.html"]];
					[self.navigationController pushViewController:browser animated:YES];
					break;
				case 2:
					browser.url = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xuzz.net/pakage/web/faq.html"]];
					[self.navigationController pushViewController:browser animated:YES];
					break;
				case 3:
					browser.url = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xuzz.net/pakage/web/upgrade.html"]];
					[self.navigationController pushViewController:browser animated:YES];
					break;
			}
			break;
		case 1:
			switch(indexPath.row)
			{
				case 0:
					browser.url = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://cydia.saurik.com"]];//@"http://xuzz.net/pakage/web/bug.html"]];
					[self.navigationController pushViewController:browser animated:YES];
					break;
				case 1:
					browser.url = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xuzz.net/pakage/web/feature.html"]];
					[self.navigationController pushViewController:browser animated:YES];
					break;
			}
	        break;
		case 2:
			switch(indexPath.row)
			{
				case 0:
					browser.url = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xuzz.net/pakage/web/issues.html"]];
					[self.navigationController pushViewController:browser animated:YES];
					break;
				case 1:
					browser.url = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xuzz.net/pakage/web/changelog.html"]];
					[self.navigationController pushViewController:browser animated:YES];
					break;
			}
			break;
	}
	
	[browser release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end

