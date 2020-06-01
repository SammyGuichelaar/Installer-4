//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//


#import "ATPackageMoreInfoView.h"
#import "ATPackage.h"
#import "NSURL+AppTappExtensions.h"
#import "ATEmitErrorTask.h"
#import "ATPipelineManager.h"

@implementation ATPackageMoreInfoView
- (IBAction)installButtonPressed:(id)sender {
   	NSError* err = nil;
	
	if (self.package.isSynthetic)
	{
        UIAlertController* as = [UIAlertController alertControllerWithTitle:@"Warning" message:[NSString stringWithFormat:NSLocalizedString(@"The package \"%@\" comes from a source that is not yet added to Installer. If you Proceed, the source \"%@\" will be first added to your sources list, and then the package will be installed as normal.", @""), self.package.name, self.package.syntheticSourceName] preferredStyle:UIAlertControllerStyleActionSheet];
        [as addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
            
        }]];
        [as addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Proceed", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            
        }]];
        [self presentViewController:as animated:YES completion:^(void){
            
        }];
		return;
	}

	if ([package.identifier isEqualToString:__INSTALLER_BUNDLE_IDENTIFIER__] || [[ATPackageManager sharedPackageManager].packages.customQuery length] || !package.isInstalled)
		[package install:&err];
	else
		[package uninstall:&err];
		
	if (err)
	{
		// This may look awkward, but it's what it is - we spawn a new fake task that does nothing but reports an error...
		ATEmitErrorTask* errTask = [[ATEmitErrorTask alloc] initWithError:err];
		[[ATPipelineManager sharedManager] queueTask:errTask forPipeline:ATPipelineErrors];
		
	}

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
	installButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Install", @"")
													 style:UIBarButtonItemStylePlain
													 target:self 
													 action:@selector(installButtonPressed:)];
	uninstallButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Uninstall", @"")
													 style:UIBarButtonItemStylePlain
													target:self 
													action:@selector(installButtonPressed:)];
	updateButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Update", @"")
													   style:UIBarButtonItemStylePlain
													  target:self 
													  action:@selector(installButtonPressed:)];
}

@synthesize package;
@synthesize urlToLoad;

extern bool WebThreadIsLocked(void) WEAK_IMPORT_ATTRIBUTE;

- (void)viewWillDisappear:(BOOL)animated  // Called after the view was dismissed, covered or otherwise hidden. Default does nothing
{	
	[webView stopLoading];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
	
	while (WebThreadIsLocked())
	{
		//NSLog(@"Waiting on web thread to become less locked...");
		////NSAutoreleasePool* innerPool = [[NSAutoreleasePool alloc] init];
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.2]];
		
	}
	
	//NSLog(@"Done waiting on web thread");
	
	//[webView loadHTMLString:@"<html><body>&nbsp;</body></html>" baseURL:[NSURL URLWithString:@"http://apptapp.me"]];
	
	//NSLog(@"View will disappear, calling stop loading (currently done loading = %@)", webView.loading ? @"YES":@"NO");

/*
	while (webView.loading)
	{
		//NSAutoreleasePool* innerPool = [[NSAutoreleasePool alloc] init];
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.2]];
		
	}
	*/
	//[[NSURLCache sharedURLCache] removeAllCachedResponses];
	
	//[webView loadHTMLString:@"<html><body>&nbsp;</body></html>" baseURL:[NSURL URLWithString:@"http://apptapp.me"]];

	[super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{	
	if (self.urlToLoad)
	{
		NSURLRequest *urlReqest = [[NSURLRequest alloc] initWithURL:[self.urlToLoad URLWithInstallerParameters] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.];
		[webView loadRequest:urlReqest];
	}
	
	// let's see if we are in the updated packages category
	if ([[ATPackageManager sharedPackageManager].packages.customQuery length])
	{
		[self.navigationItem setRightBarButtonItem:updateButton];
	}
	else
	{
        if (![package.identifier isEqualToString:__INSTALLER_BUNDLE_IDENTIFIER__]) //If the package isn't installer itself
		{
			if (package.isInstalled)
			{
				[self.navigationItem setRightBarButtonItem:uninstallButton];
			}
			else
				[self.navigationItem setRightBarButtonItem:installButton];
		}
		else
			[self.navigationItem setRightBarButtonItem:nil];
	}
	
	[super viewDidAppear:animated];
}

- (void)webViewDidFinishLoad:(UIWebView *)ww
{
}

- (void)webView:(UIWebView *)ww didFailLoadWithError:(NSError *)error
{
	NSLog(@"loading failed with error: %@", error);
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

@end
