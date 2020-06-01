//
//  ATPackagesTableViewController.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"
#import "ATPackage.h"
#import "ATPackageCell.h"
#import "ATPackageInfoController.h"

extern NSString* kCategorySpecial_AllPackages;
extern NSString* kCategorySpecial_InstalledPackages;
extern NSString* kCategorySpecial_RecentPackages;
extern NSString* kCategorySpecial_UpdatedPackages;

@interface ATPackagesTableViewController : ATTableViewController {
    IBOutlet ATPackageInfoController *packageInfoController;
    IBOutlet ATPackageMoreInfoView *packageCustomInfoController;
	
	NSString * category;
	int fetchCellNumber;
	int fetchSection;
	ATPackageCell *fetchCell;
}

@property (retain, nonatomic) NSString * category;

- (void) fetchDone:(NSNotification*)sender;

@end
