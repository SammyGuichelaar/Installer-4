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
@class ATSource;

@interface ATPackageIconFetch : NSObject <ATTask> {
	ATPackage *			package;
	ATSource *			source;
	ATURLDownload *		download;
	NSString *			tempFileName;
}

@property (retain) ATPackage * package;
@property (retain) ATSource * source;
@property (retain) ATURLDownload * download;
@property (retain) NSString * tempFileName;

- initWithPackage:(ATPackage*)pack source:(ATSource*)source;

@end
