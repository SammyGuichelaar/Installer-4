//
//  ATTrustedSourcesRefresh.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATTask.h"
#import "ATURLDownload.h"

@interface ATTrustedSourcesRefresh : NSObject <ATTask> {
	ATURLDownload *		download;
	NSString *			tempFileName;
}

@property (retain) ATURLDownload * download;
@property (retain) NSString * tempFileName;

@end
