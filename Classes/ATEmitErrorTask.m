//
//  ATEmitErrorTask.m
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATEmitErrorTask.h"
#import "ATPipelineManager.h"

@implementation ATEmitErrorTask
@synthesize error;

- (id)initWithError:(NSError*)err
{
	if (self = [super init])
	{
		self.error = err;
	}
	
	return self;
}

- (void)dealloc
{
	self.error = nil;
	
}

#pragma mark -

- (NSString*)taskID
{
	return [NSString stringWithFormat:@"error.%@.%d", [self.error domain], (int)[self.error code]];
}

- (NSString*)taskDescription
{
	return @"";
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
	[[ATPipelineManager sharedManager] taskDoneWithError:self error:self.error];
}

@end
