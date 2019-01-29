
@interface InstallOperation:NSOperation 
{
	Package *package;
}

- initWithPackage:(Package *) pkg;

@property (nonatomic,retain) Package *package;

@end
