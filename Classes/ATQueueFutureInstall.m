//
//  ATQueueFutureInstall.m
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATQueueFutureInstall.h"
#import "ATPackageManager.h"
#import "ATPackage.h"
#import "ATPackages.h"
#import "ATPipelineManager.h"

@implementation ATQueueFutureInstall

@synthesize packageID;

- initWithPackageID:(NSString*)identifier;
{
	if (self = [super init])
	{
		self.packageID = identifier;
	}
	
	return self;
}

- (void)dealloc
{
	self.packageID = nil;
	
}

#pragma mark -

- (NSString*)taskID
{
	return [NSString stringWithFormat:@"future-install:%@", self.packageID];
}

- (NSString*)taskDescription
{
	return NSLocalizedString(@"Queueing package install...", @"");
}

- (double)taskProgress
{
	return -1.;
}

- (NSArray*)taskDependencies
{
	return nil;
}

- (void)taskStart
{
	ATPackage* pack = [[ATPackageManager sharedPackageManager].packages packageWithIdentifier:self.packageID];
	if (pack)
	{
		NSError* err = nil;
		
		if (![pack install:&err])
		{
			[[ATPipelineManager sharedManager] taskDoneWithError:self error:err];
		}
		else
			[[ATPipelineManager sharedManager] taskDoneWithSuccess:self];
	}
	else
	{
		NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.packageID, @"packageID",
																			[NSString stringWithFormat:NSLocalizedString(@"Cannot install package \"%@\" as it was not found. Sorry!", @""), self.packageID], NSLocalizedDescriptionKey,
								  nil];
		
		NSError* err = [NSError errorWithDomain:AppTappErrorDomain code:kATErrorPackageNotFound userInfo:userInfo];
		
		[[ATPipelineManager sharedManager] taskDoneWithError:self error:err];
	}
}

@end
