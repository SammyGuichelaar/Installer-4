//
//  ATSearchTableViewController.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>

@class ATPackageMoreInfoView;
@class ATPackageInfoController;
@class ATPackageCell;

@interface ATSearchTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    IBOutlet ATPackageInfoController *packageInfoController;
    IBOutlet ATPackageMoreInfoView *packageCustomInfoController;
	IBOutlet UITableView * tableView;
	IBOutlet UISearchBar * searchBar;

	int fetchCellNumber;
	ATPackageCell *fetchCell;
}

- (void)setSearch:(NSString*)text;

@end
