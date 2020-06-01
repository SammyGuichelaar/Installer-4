//
//  ATCategoriesTableViewController.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATSource.h"
#import "ATPackage.h"
#import "ATTableViewController.h"
#import "ATPackagesTableViewController.h"
#import "ATPackage.h"
#import "ATPackageCell.h"
#import "ATCategoriesCell.h"


@interface ATCategoriesTableViewController : ATTableViewController {
	IBOutlet ATPackagesTableViewController * packagesTableViewController;
	
	NSMutableArray* categoryCache;
}

- (void)_rebuildCache:(id)sender;
@end
