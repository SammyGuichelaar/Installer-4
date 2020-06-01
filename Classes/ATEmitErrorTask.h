//
//  ATEmitErrorTask.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATTask.h"

@interface ATEmitErrorTask : NSObject <ATTask> {
	NSError* error;
}

@property (nonatomic, retain) NSError* error;

- (id)initWithError:(NSError*)err;

@end
