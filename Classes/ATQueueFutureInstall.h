//
//  ATQueueFutureInstall.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATTask.h"

@interface ATQueueFutureInstall : NSObject <ATTask> {
	NSString* packageID;
}

@property (retain) NSString* packageID;

- initWithPackageID:(NSString*)identifier;

@end
