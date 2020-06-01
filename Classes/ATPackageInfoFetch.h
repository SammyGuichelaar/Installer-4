//
//  ATPackageInfoFetch.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATTask.h"

@class ATPackage;
@class ATURLDownload;

@interface ATPackageInfoFetch : NSObject <ATTask> {
	ATPackage *			package;
	ATURLDownload *		download;
	NSString *			tempFileName;
}

@property (retain) ATPackage * package;
@property (retain) ATURLDownload * download;
@property (retain) NSString * tempFileName;

- initWithPackage:(ATPackage*)pack;

@end
