//
//  ATPackageQueueInstall.m
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATPackageQueueInstall.h"
#import "ATPipelineManager.h"
#import "ATURLDownload.h"
#import "NSURL+AppTappExtensions.h"
#import "ATEmitErrorTask.h"

@implementation ATPackageQueueInstall

- initWithPackage:(ATPackage*)package
{
	return [self initWithPackage:package usb:NO];
}

- initWithPackage:(ATPackage*)package usb:(BOOL)isUSB
{
	if (self = [super init])
	{
		mPackage = package;
		mUSB = isUSB;
		mQueue = [[NSMutableArray alloc] initWithCapacity:0];
		mProcessedPackages = [[NSMutableArray alloc] initWithCapacity:0];
	}
	
	return self;
}


- (NSString*)taskID
{
	return [NSString stringWithFormat:@"install-queue:%@", mPackage.identifier];
}

- (NSString*)taskDescription
{
	return [NSString stringWithFormat:NSLocalizedString(@"Preparing %@...", @""), mPackage.name];
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
	// fetch extended info
	// check dependencies
	//		for each dependency
	//			cycle
	//		end
	// queue install to the end of queue

    if (mPackage.identifier != nil)
    {
        [mQueue addObject:mPackage.identifier];
        [mProcessedPackages addObject:mPackage.identifier];
    }

	[self loop];
}

- (void)loop
{
	if (![mQueue count] || (gATBehaviorFlags & kATBehavior_NoNetwork))
	{
		// All done, queue first package install now.
		NSError* error = nil;
		BOOL res = NO;
		
		if (mUSB)
			res = [mPackage _installUSB:&error];
		else
			res = [mPackage _install:&error];
			
		if (!res)
		{
			ATEmitErrorTask* emit = [[ATEmitErrorTask alloc] initWithError:error];
			[[ATPipelineManager sharedManager] queueTask:emit forPipeline:ATPipelinePackageOperation];
			
		}
		
		[[ATPipelineManager sharedManager] taskDoneWithSuccess:self];
		return;
	}
	
	NSString* packageID = [mQueue objectAtIndex:0];
	
	ATPackage* package = [[ATPackageManager sharedPackageManager].packages packageWithIdentifier:packageID];

	if (!package)
	{
		NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys: packageID, @"packageID",
																			[NSString stringWithFormat:NSLocalizedString(@"Cannot install package \"%@\" as it was not found. Sorry!", @""), packageID], NSLocalizedDescriptionKey,
								  nil];
		
		NSError* err = [NSError errorWithDomain:AppTappErrorDomain code:kATErrorPackageNotFound userInfo:userInfo];
		
		[[ATPipelineManager sharedManager] taskDoneWithError:self error:err];
		return;
	}
	[mQueue removeObjectAtIndex:0];
	
	// first, fetch extended info
	NSURL* sourceURL = [package.moreURL URLWithInstallerParameters];

	if (sourceURL == nil)
	{
		NSError* err = [NSError errorWithDomain:AppTappErrorDomain code:kATErrorPackageInfoDecodeFailed userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Unable to location package more info at %@", package.name], NSLocalizedDescriptionKey,
																																							package.identifier, @"packageID", nil]];
		[[ATPipelineManager sharedManager] taskDoneWithError:self error:err];
		return;
	}

    ATURLDownload* dl = [[ATURLDownload alloc] initWithRequest:[NSURLRequest requestWithURL:sourceURL] delegate:self];
	dl.refcon = (void*)CFBridgingRetain(package);
	
	// we'll continue from the download callbacks
}

- (void)downloadDidFinish:(ATURLDownload *)download
{
	ATPackage* package = (ATPackage*)download.refcon;
	
	NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:download.downloadFilePath];
	
	[[NSFileManager defaultManager] removeItemAtPath:download.downloadFilePath error:nil];
	
	
	
	if (!dict)
	{
        //TODO: Change this errormessage to use localized/translated String
		NSError* err = [NSError errorWithDomain:AppTappErrorDomain code:kATErrorPackageInfoDecodeFailed userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Unable to decode package more info at %@", package.moreURL], NSLocalizedDescriptionKey,
																																							package.identifier, @"packageID", nil]];
		[[ATPipelineManager sharedManager] taskDoneWithError:self error:err];
		return;
	}
	
	package.Description = [dict objectForKey:@"description"];
	package.Hash = [dict objectForKey:@"hash"];
	package.location = [dict objectForKey:@"location"];
	package.size = [dict objectForKey:@"size"];
	package.sponsor = [dict objectForKey:@"sponsor"];
	package.sponsorURL = [dict objectForKey:@"sponsorURL"];
	package.maintainer = [dict objectForKey:@"maintainer"];
	package.contact = [dict objectForKey:@"contact"];
	if ([dict objectForKey:@"customInfo"])
		package.customInfoURL = [NSURL URLWithString:[dict objectForKey:@"customInfo"]];
//	if (![self.package.source.isTrusted boolValue])		// disable custom infos for non-trusted sources
//		package.customInfoURL = nil;	
	if ([dict objectForKey:@"url"])
		package.url = [NSURL URLWithString:[dict objectForKey:@"url"]];
	if ([dict objectForKey:@"icon"])
		package.iconURL = [NSURL URLWithString:[dict objectForKey:@"icon"]];
	if ([dict objectForKey:@"dependencies"] && [[dict objectForKey:@"dependencies"] isKindOfClass:[NSArray class]])
		package.dependencies = [NSMutableArray arrayWithArray:[dict objectForKey:@"dependencies"]];
    if ([dict objectForKey:@"screenshots"] && [[dict objectForKey:@"screenshots"] isKindOfClass:[NSArray class]])
        package.screenshots = [NSMutableArray arrayWithArray:[dict objectForKey:@"screenshots"]];
    
	[package commit];
	
	
	NSArray* deps = [dict objectForKey:@"dependencies"];
	if (deps)
		for (NSString* dep in deps)
		{
			if ([mProcessedPackages containsObject:dep])
			{
				continue;
			}
			
			if (![mQueue containsObject:dep])
				[mQueue addObject:dep];
		
			[mProcessedPackages addObject:dep];
		}
	
	[self loop];
	//[self performSelector:@selector(loop) withObject:nil afterDelay:.0];
}

- (void)download:(ATURLDownload *)download didFailWithError:(NSError *)error
{
	
	
	[[ATPipelineManager sharedManager] taskDoneWithError:self error:error];
}

@end
