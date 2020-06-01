//
//  ATTasksTableViewController.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"
#import "ATTaskTableViewCell.h"


@interface ATTasksTableViewController : ATTableViewController {
	NSMutableArray*			tasks;
}

@property (retain) NSMutableArray* tasks;

- (void)pipelineManagerNotification:(NSNotification*)notification;
@end
