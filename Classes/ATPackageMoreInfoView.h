//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "ATViewController.h"
#import "ATInstaller.h"

@interface ATPackageMoreInfoView : ATViewController <UIActionSheetDelegate, UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
		
	NSURL*		urlToLoad;

	ATPackage *package;

	UIBarButtonItem *installButton;
	UIBarButtonItem *uninstallButton;
	UIBarButtonItem *updateButton;
}

@property (nonatomic, retain) NSURL* urlToLoad;

- (IBAction)installButtonPressed:(id)sender;

@property (retain, nonatomic) ATPackage* package;

@end
