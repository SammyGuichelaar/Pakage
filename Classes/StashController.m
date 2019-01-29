#import <sys/stat.h>
#import "StashController.h"

static void cmd_system_chroot(const char* newRoot, char * argv[]);
static void sig_chld_ignore(int signal);
static void sig_chld_waitpid(int signal);

#if defined(__i386__)
	#define STASH_DIR "/tmp/stash/"
#else
	#define STASH_DIR "/var/stash/"
#endif

@implementation StashController

- (void) loadView
{
	CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	self.view = [[UIView alloc] initWithFrame:bounds];
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
	progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	progress.frame = CGRectMake(85, 195, 150, 11);
	[self.view addSubview:progress];
	[progress release];
	progress.progress = 0.0;
	
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.frame = CGRectMake(140, 400, 37, 37);
	[self.view addSubview:spinner];
	[spinner release];
	[spinner startAnimating];
	
	caption = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 280, 40)];
	caption.text = @"Initializing Filesystem";
	caption.font = [UIFont boldSystemFontOfSize:23.0f];
	caption.textColor = [UIColor whiteColor];
	caption.backgroundColor = [UIColor clearColor];
	caption.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:caption];
	[caption release];
	
	status = [[UILabel alloc] initWithFrame:CGRectMake(20, 215, 280, 20)];
	status.text = @"Preparing...";
	status.font = [UIFont systemFontOfSize:12.0f];
	status.textColor = [UIColor whiteColor];
	status.backgroundColor = [UIColor clearColor];
	status.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:status];
	[status release];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL) animated
{
	[NSThread detachNewThreadSelector:@selector(stashDirectories:) toTarget:self withObject:((PakageAppDelegate *) [UIApplication sharedApplication]).toStash];	
}

- (void) didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload 
{
	[super viewDidUnload];
}

- (void) dealloc 
{
    [super dealloc];
}

- (void)stashDirectories:(NSArray *) dirs
{
	int i = 0;
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	
	for (NSString* dir in dirs)
	{
		NSAutoreleasePool* innerPool = [[NSAutoreleasePool alloc] init];
		i++;
		status.text = dir;
		progress.progress = ((float)i / (float)[dirs count]);
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
		[self _stash:dir];
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
		[innerPool release];
	}
	
	progress.progress = 1.;
	status.text = @"";
	
	UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"Filesystem has now been initialized successfully. Pakage will now exit, restart to access the main program." delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Quit" otherButtonTitles:nil];
	[as performSelectorOnMainThread:@selector(showInView:) withObject:self.view waitUntilDone:YES];
	[as release];
}

- (void) actionSheet:(UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	exit(0);
}

- (void) _stash:(NSString *) dir
{
	struct stat st;
	
	if(stat(STASH_DIR, &st))
		mkdir(STASH_DIR, 0755);
	
	char stashDir[1024];
	
	strcpy(stashDir, STASH_DIR);
	strcat(stashDir, [[dir lastPathComponent] UTF8String]);
	
	// make random ending for the stash dir
	strcat(stashDir, [[NSString stringWithFormat:@"-%@", [[[[NSDate date] description] MD5] substringToIndex:5]] UTF8String]);
	
	printf("Stashing %s -> %s\n", [dir fileSystemRepresentation], stashDir); fflush(stdout);
	
	// it's time to mooove
	cmd_system_chroot((const char *) NULL, (char *[]) {"/bin/mv", (char *) [dir fileSystemRepresentation], stashDir, (char *) 0});
	
	symlink(stashDir, [dir fileSystemRepresentation]);
}

@end

void cmd_system_chroot(const char* newRoot, char * argv[])
{
	pid_t fork_pid;
	signal(SIGCHLD, &sig_chld_ignore);
	if((fork_pid = fork()) != 0)
	{
		while(waitpid(fork_pid, NULL, WNOHANG) <= 0)
		{
			NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
			
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
			
			[pool release];
		}
	}
	else
	{
		if(newRoot)
		{
			if(chroot(newRoot) != 0)
			{
				fprintf(stderr, "execute command: chroot failed\n");
				exit(0);
			}
			if(chdir("/") != 0)
			{
				fprintf(stderr, "execute command: chdir failed\n");
				exit(0);
			}
			fflush(stderr);
		}
		
		setenv("PATH", "/bin", 1);
		
		if(execve(argv[0], argv, NULL) != 0)
		{
			perror("execv");
			fflush(stderr);
			fflush(stdout);
		}
		
		exit(0);
	}
	
	signal(SIGCHLD, &sig_chld_waitpid);
}

static void sig_chld_ignore(int signal)
{
	return;
}

static void sig_chld_waitpid(int signal)
{
	while(waitpid(-1, 0, WNOHANG) > 0);
}
