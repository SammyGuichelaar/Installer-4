//
//  ATFeaturedViewController.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATViewController.h"

@class ATPackage;
@class ATPackageInfoController;
@class ATPackageMoreInfoView;
@class ATSearchTableViewController;

@interface ATFeaturedViewController : ATViewController <UIWebViewDelegate>{
	IBOutlet UIWebView * webView;


    IBOutlet ATPackageInfoController *packageInfoController;
    IBOutlet ATPackageMoreInfoView *packageCustomInfoController;
	
	IBOutlet ATSearchTableViewController *searchTableController;
	
	IBOutlet UISegmentedControl* titleControl;

	ATPackage* moreInfoPackage;
}

@property (retain, nonatomic) ATPackage* moreInfoPackage;

- (IBAction)segmentedControlChanged:(UISegmentedControl*)sender;

- (void)showPackageInfo:(NSString*)packageID;

- (NSString*)renderAbout;

@end
