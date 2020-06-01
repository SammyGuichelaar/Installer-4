//
//  ATInstaller.m
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATInstaller.h"
#import "ATPipelineManager.h"
#import "ATPackage.h"
#import <dlfcn.h>

static __strong ATInstaller * sharedInstaller = nil;

@implementation ATInstaller



@synthesize window;
@synthesize tabBarController;
@synthesize packageManager;
@synthesize notificationQueue;

+ (ATInstaller *)sharedInstaller {
	//return sharedInstaller ? sharedInstaller : [[self alloc] init];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstaller = [[ATInstaller alloc]init];
    });
    NSLog(@"Retain count now is %ld", CFGetRetainCount((__bridge CFTypeRef)sharedInstaller));
    return sharedInstaller ;
}

void patch_setuid() {
    void* handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
    if (!handle)
        return;
    
    // Reset errors
    dlerror();
    typedef void (*fix_setuid_prt_t)(pid_t pid);
    fix_setuid_prt_t ptr = (fix_setuid_prt_t)dlsym(handle, "jb_oneshot_fix_setuid_now");
    
    const char *dlsym_error = dlerror();
    if (dlsym_error)
        return;
    
    ptr(getpid());
}

- (id)init {
	if(self = [super init]) {
		
		patch_setuid(); // chown root Installer; chmod 6777 Installer
		setuid(0);
		setgid(0);
	
		//NSLog(@"ATInsaller = %@ (shared = %@)", self, sharedInstaller);
		
		sharedInstaller = self;
		offeredUpdate = NO;
		
		notificationQueue = [NSNotificationQueue defaultQueue];
				
		// Initialize the package manager
		packageManager = [ATPackageManager sharedPackageManager];
		[packageManager setDelegate:self];

		// Initialize the tab bar
		self.tabBarController = [[UITabBarController alloc] init];
        
		
		// The progress view
		progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[progressBar setFrame:CGRectMake(320.0f / 2 - 100.0f, 38.0f, 200.0f, 20.0f)];
		progressSheet = [UIAlertController alertControllerWithTitle:@"Progress" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [progressSheet.view addSubview:progressBar];
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedInstaller selector:@selector(taskDone:) name:ATPipelineTaskFinishedNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:sharedInstaller selector:@selector(sourceRefreshed:) name:ATSourceUpdatedNotification object:nil];
        CFBridgingRetain(sharedInstaller);

		if (geteuid() != 0)
		{
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insufficient Permissions", @"Installer Main") message:NSLocalizedString(@"Installer was not installed correctly. It should be run as root:wheel. We will continue but please remember that it may not function correctly.", @"Installer Main") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //Add Action Here
                //Left empty, since it's just an acknowledgement
            }];
            
            [alert addAction:actionOK];
            
            UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            if ( viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed ) {
                viewController = viewController.presentedViewController;
            }
            
            NSLayoutConstraint *constraint = [NSLayoutConstraint 
                                              constraintWithItem:alert.view 
                                              attribute:NSLayoutAttributeHeight 
                                              relatedBy:NSLayoutRelationLessThanOrEqual 
                                              toItem:nil 
                                              attribute:NSLayoutAttributeNotAnAttribute 
                                              multiplier:1 
                                              constant:viewController.view.frame.size.height*2.0f];
            
            [alert.view addConstraint:constraint];
            [viewController presentViewController:alert animated:YES completion:^{}];

			NSLog(@"Running as effective user %d", geteuid());

		}
	}
    CFBridgingRetain(self);
	return self;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[ATPackageManager sharedPackageManager] restartSpringBoardIfNeeded];
}

- (void)taskDone:(NSNotification*)notification
{
	static NSError* lastError = nil;
		
	if (![[[notification userInfo] objectForKey:ATPipelineUserInfoSuccess] boolValue])
	{
		NSError* err = [[notification userInfo] objectForKey:ATPipelineUserInfoError];
		
		//NSLog(@"Task done notification error: domain='%@', code = %u, locDesc='%@'", [err domain], [err code], [[err userInfo] objectForKey:NSLocalizedDescriptionKey]);
	
		if ([[err domain] isEqualToString:AppTappErrorDomain] && ![[err userInfo] objectForKey:NSLocalizedDescriptionKey])
		{
            NSString* errorText = [[NSBundle bundleForClass:[self class]] localizedStringForKey:[NSString stringWithFormat:@"%ld", (long)[err code]] value:[NSString stringWithFormat:@"Installer Error #%ld. Please report the error code to RiP Dev at support@ripdev.com so we can provide a better description for it.", (long)[err code]] table:@"Errors"];
			NSString* errorErrata = nil;
			
			if ([[err userInfo] objectForKey:@"package"])
				errorErrata = ((ATPackage*)[[err userInfo] objectForKey:@"package"]).name;
			else if ([[err userInfo] objectForKey:@"packageID"])
				errorErrata = [[err userInfo] objectForKey:@"packageID"];
			
			NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:0];
			
			if ([err userInfo])
				[userInfo addEntriesFromDictionary:[err userInfo]];
		
			[userInfo setObject:[NSString stringWithFormat:errorText, errorErrata] forKey:NSLocalizedDescriptionKey];
			
			err = [NSError errorWithDomain:[err domain] code:[err code] userInfo:userInfo];
		}
		
		if (lastError != err)
		{
			NSString* description = [err localizedDescription];

            UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"") message:description preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //Add Action Here
                //Left empty, since it's just an acknowledgement
            }];
            
            [alert addAction:actionOK];
            
            UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            if ( viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed ) {
                viewController = viewController.presentedViewController;
            }
            
            NSLayoutConstraint *constraint = [NSLayoutConstraint 
                                              constraintWithItem:alert.view 
                                              attribute:NSLayoutAttributeHeight 
                                              relatedBy:NSLayoutRelationLessThanOrEqual 
                                              toItem:nil 
                                              attribute:NSLayoutAttributeNotAnAttribute 
                                              multiplier:1 
                                              constant:viewController.view.frame.size.height*2.0f];
            
            [alert.view addConstraint:constraint];
            [viewController presentViewController:alert animated:YES completion:^{}];
		
			lastError = err;
		}
	}
}

- (void)sourceRefreshed:(NSNotification*)notification
{
	ATSource* source = (ATSource*)[notification object];
	
	if ([[source.location absoluteString] hasPrefix:@"http://i.ripdev.com"] && !offeredUpdate)
	{
		/* DOT - if ([[ATPackageManager sharedPackageManager].packages hasInstallerUpdate])
		{
			offeredUpdate = YES;
			
			UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Installer Update Available", @"") message:NSLocalizedString(@"An Installer update is available. Would you like to update it now? It is strongly recommended you stay up-to-date with the latest version.", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Update", @""), nil];
			
			[errorView show];
		}*/
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex)
	{
		// queue up an update
		ATPackage* installerUpdate = [[ATPackageManager sharedPackageManager].packages hasInstallerUpdate];
		if (installerUpdate)
			[installerUpdate install:nil];
	}
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	// Assign tabview items
	
	featuredViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];
	searchTableViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
	categoriesTableViewController.tabBarItem.image = [UIImage imageNamed:@"Categories.png"];
	sourcesTableViewController.tabBarItem.image = [UIImage imageNamed:@"Sources.png"];
	tasksTableViewController.tabBarItem.image = [UIImage imageNamed:@"Tasks.png"];
	
	NSArray * viewControllers = [NSArray arrayWithObjects:
								 [[UINavigationController alloc] initWithRootViewController:featuredViewController] ,
								 [[UINavigationController alloc] initWithRootViewController:categoriesTableViewController] ,
								 [[UINavigationController alloc] initWithRootViewController:searchTableViewController] ,
								 [[UINavigationController alloc] initWithRootViewController:sourcesTableViewController] ,
								 [[UINavigationController alloc] initWithRootViewController:tasksTableViewController] ,
								 nil];
	
	[tabBarController setViewControllers:viewControllers];
	[window setRootViewController:tabBarController];
    
    window = application.keyWindow;
    window.frame = [[UIScreen mainScreen] bounds];
	
	// Add the tab bar controller's current view as a subview of the window
	//window.rootViewController = tabBarController; //setRootViewController has already been declared above.

	// Make the window key and visible
	[window makeKeyAndVisible];

   
    
    NSLog(@"...'");
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	return [(id<UIWebViewDelegate>)featuredViewController webView:[UIWebView alloc] shouldStartLoadWithRequest:[NSURLRequest requestWithURL:url] navigationType:UIWebViewNavigationTypeLinkClicked];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	// Optional UITabBarControllerDelegate method
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
	// Optional UITabBarControllerDelegate method
}



#pragma mark -
#pragma mark Actions

- (IBAction)refreshAllSources:(id)sender {
	[[ATPackageManager sharedPackageManager] refreshAllSources];
}

@end

