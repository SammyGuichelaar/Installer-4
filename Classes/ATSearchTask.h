//
//  ATSearchTask.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATTask.h"

@class ATSearch;
@class ATURLDownload;

@interface ATSearchTask : NSObject <ATTask> {
	NSString *			search;
	ATURLDownload *		download;
	NSString *			tempFileName;
}

@property (retain) NSString * search;
@property (retain) ATURLDownload * download;
@property (retain) NSString * tempFileName;

- (ATSearchTask*)initWithSearch:(ATSearch*)srch;

@end
