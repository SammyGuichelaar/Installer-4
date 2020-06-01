//
//  ATRatingFetchTask.m
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATRatingFetchTask.h"
#import "ATPackage.h"
#import "ATPipelineManager.h"
#import "NSURL+AppTappExtensions.h"
#import "ATURLDownload.h"

#ifndef INSTALLER_APP
    #import "ATInstaller.h"
#endif // INSTALLER_APP

@implementation ATRatingFetchTask

@synthesize download;
@synthesize tempFileName;
@synthesize package;

- initWithPackage:(ATPackage*)pack
{
	if (self = [super init])
	{
		self.package = pack;
	}
	
	return self;
}

- (void)dealloc
{
	[self.download cancel];
    if (download.delegate == self)
        download.delegate = nil;

	self.package = nil;
	self.download = nil;
	self.tempFileName = nil;
}

#pragma mark -
#pragma mark ATSource Protocol

- (void)taskCancel
{
	[self.download cancel];
    if (download.delegate == self)
        download.delegate = nil;

	self.download = nil;	
}

- (NSString*)taskID
{
	return [NSString stringWithFormat:@"rating:%@", self.package.identifier];
}

- (NSString*)taskDescription
{
	return [NSString stringWithFormat:NSLocalizedString(@"Getting rating for \"%@\"...", @""), self.package.name];
}

- (double)taskProgress
{
	return -1;
}

- (NSArray*)taskDependencies
{
	return nil;
}

- (void)taskStart
{
	if (gATBehaviorFlags & kATBehavior_NoNetwork)
	{
		[[ATPipelineManager sharedManager] taskDoneWithSuccess:self];
		return;
	}
	
	NSURL* sourceURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://search.i.apptapp.me/rate/get/?i=%@&u=%@", [self.package.identifier stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], [[ATPlatform deviceUUID] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
	
	self.download = [[ATURLDownload alloc] initWithRequest:[NSURLRequest requestWithURL:sourceURL] delegate:self];
}

#pragma mark -
#pragma mark ATURLDownload delegate

- (void)download:(ATURLDownload *)dl didCreateDestination:(NSString *)path
{
	self.tempFileName = path;
}

- (void)downloadDidFinish:(ATURLDownload *)dl
{
	// do processing
	NSString* str = [NSString stringWithContentsOfFile:self.tempFileName encoding:NSUTF8StringEncoding error:nil];
	
	[[NSFileManager defaultManager] removeItemAtPath:self.tempFileName error:nil];
	
	if (!str)
	{
		[[ATPipelineManager sharedManager] taskDoneWithSuccess:self];
		return;
	}
	
	NSArray* comps = [str componentsSeparatedByString:@":"];
	
	if ([comps count] >= 4)
	{
		int version = [[comps objectAtIndex:0] intValue];
		float rating = [[comps objectAtIndex:1] floatValue];
		//int votes = [[comps objectAtIndex:2] intValue];
		float myRating = [[comps objectAtIndex:3] floatValue];
		
		if (version == 1 && rating <= 5 && rating >= 0)
		{
			self.package.rating = [NSNumber numberWithFloat:rating];
			self.package.ratingRefresh = [NSDate date];
			self.package.myRating = [NSNumber numberWithFloat:myRating];
			[self.package commit];

			[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:ATPackageInfoRatingChangedNotification object:self.package userInfo:nil] waitUntilDone:NO];
		}
	}
	
	[[ATPipelineManager sharedManager] taskDoneWithSuccess:self];
}

- (void)download:(ATURLDownload *)dl didFailWithError:(NSError *)error
{
	[[ATPipelineManager sharedManager] taskDoneWithSuccess:self];
}

@end
