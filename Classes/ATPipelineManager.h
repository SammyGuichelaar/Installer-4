//
//  ATPipelineManager.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>

// Pipeline types
extern NSString* ATPipelinePackageOperation;
extern NSString* ATPipelineSourceRefresh;
extern NSString* ATPipelineMisc;
extern NSString* ATPipelineSearch;
extern NSString* ATPipelineErrors;
extern NSString* ATPipelineSynchronization;

// Notifications
extern NSString* ATPipelineTaskQueuedNotification;
extern NSString* ATPipelineTaskChangedNotification;
extern NSString* ATPipelineTaskFinishedNotification;
extern NSString* ATPipelineTaskProgressNotification;
extern NSString* ATPipelineTaskStatusNotification;

// Keys for the userInfo dictionary
extern NSString* ATPipelineUserInfoPipelineID;
extern NSString* ATPipelineUserInfoTaskID;
extern NSString* ATPipelineUserInfoSuccess;
extern NSString* ATPipelineUserInfoError;		// if ATPipelineUserInfoSuccess == [NSNumber boolValue] == NO
extern NSString* ATPipelineUserInfoProgress;		// NSNumber, [0.0, 1.0]
extern NSString* ATPipelineUserInfoStatus;			// NSString

@class ATPipeline;

@interface ATPipelineManager : NSObject {
	NSMutableDictionary* pipelines;
	NSLock* pipelinesLock;
}

@property (nonatomic, retain) NSMutableDictionary* pipelines;

+ (ATPipelineManager*)sharedManager;

- (BOOL)queueTask:(id)task forPipeline:(NSString*)pipelineID;
- (BOOL)cancelTask:(id)task;
- (id)findTaskForID:(NSString*)identifier outPipeline:(NSString**)pipelineID;
- (ATPipeline*)findPipelineForTask:(id)task;
- (NSString*)piplineIDForTask:(id)task;

- (void)taskDoneWithError:(id)task error:(NSError*)error;
- (void)taskDoneWithSuccess:(id)task;

- (void)taskProgressChanged:(id)task;
- (void)taskStatusChanged:(id)task;

- (void)pipelineDone:(ATPipeline*)pipeline;

@end
