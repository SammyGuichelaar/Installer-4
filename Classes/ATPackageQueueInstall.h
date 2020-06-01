//
//  ATPackageQueueInstall.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATTask.h"
#import "ATPackage.h"

@interface ATPackageQueueInstall : NSObject <ATTask> {
	ATPackage*	mPackage;
	BOOL		mUSB;
	
	NSMutableArray* mQueue;
	NSMutableArray* mProcessedPackages;
}

- initWithPackage:(ATPackage*)package;
- initWithPackage:(ATPackage*)package usb:(BOOL)isUSB;

- (void)loop;

@end
