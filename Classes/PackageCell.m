
UIImage *gPackageImage = nil;

@implementation PackageCell
@synthesize package;

- (id) initWithIdentifier:(NSString *) reuseIdentifier package:(Package *) pkg
{
    if(self = [super initWithStyle:3 reuseIdentifier:reuseIdentifier])
	{
        self.package = pkg;
		if(pkg.version != nil)
			self.textLabel.text = [NSString stringWithFormat:@"%@ (v%@)", package.name, package.version];
		else
			self.textLabel.text = [NSString stringWithFormat:@"%@", package.name];
		self.detailTextLabel.text = package.description;
		if(package.installed && !package.needsUpgrade)
			self.accessoryType = UITableViewCellAccessoryCheckmark;
		else
			self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.imageView.image = [self loadImage];
	}
    return self;
}

- (UIImage *) loadImage
{
	if(gPackageImage == nil)
		gPackageImage = [UIImage imageNamed:@"packagesm.png"];
	return gPackageImage;
}

- (void) updateWithPackage:(Package *) pkg
{
	self.package = pkg;
	self.textLabel.text = [NSString stringWithFormat:@"%@ (v%@)", pkg.name, pkg.version];
	self.detailTextLabel.text = pkg.description;	
	if(package.installed && !package.needsUpgrade)
		self.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if(!self.imageView.image)
		self.imageView.image = [self loadImage];
}

- (void) dealloc 
{
	[package release];
    [super dealloc];
}


@end
