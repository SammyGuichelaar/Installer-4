//
//  ATPackageUninstallTask.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATTask.h"

@class ATPackage;
@class ATScript;

@interface ATPackageUninstallTask : NSObject <ATTask> {
	ATPackage *			package;
	ATScript *			script;
	
	NSNumber *			progress;
	NSString *			status;
}

@property (retain) ATPackage * package;
@property (retain) ATScript * script;
@property (retain) NSNumber * progress;
@property (retain) NSString * status;

- initWithPackage:(ATPackage*)pack;

@end
