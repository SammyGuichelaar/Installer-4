//
//  ATSourcesTableViewController.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATSource.h"
#import "ATTableViewController.h"
#import "ATSourceInfoController.h"
#import "ATSourceTableViewCell.h"


@interface ATSourcesTableViewController : ATTableViewController <UITableViewDelegate> {
	IBOutlet ATSourceInfoController *sourceInfoView;
	UIBarButtonItem *refreshAllButton;
	//UIBarButtonItem *editButton;
	//UIBarButtonItem *doneButton;
	UIBarButtonItem *addButton;
	bool editMode;

}

// Actions
- (IBAction) refreshAllSources:(id)sender;
//- (IBAction) doEdit:(id)sender;
- (IBAction) addSource:(id)sender;

@end
