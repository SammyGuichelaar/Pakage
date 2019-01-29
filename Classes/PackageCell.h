
@interface PackageCell:UITableViewCell 
{
	Package *package;
}

@property (nonatomic, retain) Package *package;

- (id) initWithIdentifier:(NSString *) reuseIdentifier package:(Package *) pkg;
- (void) updateWithPackage:(Package *) pkg;
- (UIImage *) loadImage;

@end
