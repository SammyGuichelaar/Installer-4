//
//  ATPackageUSBInstallTask.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATTask.h"

@class ATPackage;
@class ATURLDownload;
@class ATScript;

@interface ATPackageUSBInstallTask : NSObject <ATTask> {
	ATPackage *			package;
	ATURLDownload *		download;
	NSString *			tempFileName;
	ATScript *			script;
	
	NSNumber *			progress;
	NSString *			status;
	
	NSUInteger			downloadBytes;
	BOOL				canCancel;
}

@property (retain) ATPackage * package;
@property (retain) ATURLDownload * download;
@property (retain) NSString * tempFileName;
@property (retain) ATScript * script;
@property (retain) NSNumber * progress;
@property (retain) NSString * status;
@property (assign) NSUInteger downloadBytes;
@property (assign) BOOL canCancel;

- (id)initWithPackage:(ATPackage*)pack;

- (void)embedLuaObjectsInto:(NSMutableArray*)array;

@end
