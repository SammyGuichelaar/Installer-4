//
//  ATTask.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>

/* An abstract protocol representing a task. Each task belongs to a pipeline. */

@protocol ATTask

- (NSString*)taskID;			// task identifier
- (NSString*)taskDescription;	// user-readable task description
- (double)taskProgress;			// [0.0, 1.0] or -1 for indeterminate progress
- (NSArray*)taskDependencies;	// an array of task identifiers that this task depends on. if one of these aborts, this task
								// gets aborted too.

- (void)taskStart;				// Launch the task execution

@optional
- (BOOL)taskCanCancel;
- (void)taskCancel;				// This task was cancelled, perform necessary teardowns.
- (NSString*)taskLocalizedObjectName;
- (NSString*)taskLocalizedTitle;

@end
