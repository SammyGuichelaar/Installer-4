//
//  ATSourceRefresh.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATTask.h"
#import "ATCydiaRepositoryNode.h"

@class ATSource, ATURLDownload;

@interface ATSourceRefresh : NSObject <ATTask, ATCydiaRepositoryNodeDelegate> {
	ATSource*		source;
	ATURLDownload*	download;
	NSString*		tempFileName;
	
	NSString*		Description;

    BOOL cydiaSource;
    ATCydiaRepositoryNode* rootNode;
	
	double progress;
	BOOL			canCancel;
}

@property (retain) ATSource* source;
@property (retain) ATURLDownload* download;
@property (retain) NSString* tempFileName;
@property (retain) NSString* Description;
@property (assign) BOOL canCancel;

+ (ATSourceRefresh*)sourceRefreshWithSourceLocation:(NSString*)location;
+ (ATSourceRefresh*)sourceRefreshWithSource:(ATSource*)src;
- (ATSourceRefresh*)initWithSource:(ATSource*)src;

@end
