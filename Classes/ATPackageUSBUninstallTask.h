//
//  ATPackageUSBUninstallTask.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATTask.h"

@class ATPackage;
@class ATScript;

@interface ATPackageUSBUninstallTask : NSObject <ATTask> {
	ATPackage *			package;
	
	NSNumber *			progress;
	NSString *			status;
}

@property (retain) ATPackage * package;
@property (retain) NSNumber * progress;
@property (retain) NSString * status;

- (id)initWithPackage:(ATPackage*)pack;

@end
