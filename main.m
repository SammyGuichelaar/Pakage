
int main(int argc, char *argv[]) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	setreuid(0, 0);
    int retVal = UIApplicationMain(argc, argv, @"PakageAppDelegate", @"PakageAppDelegate");
    [pool release];
    return retVal;
}
