// AppTapp Framework
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "NSURLRequest+AppTappExtensions.h"
#import "ATPlatform.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation NSURLRequest (AppTappExtensions)

+ (id)requestWithURL:(NSURL *)URL {
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:URL cachePolicy:/*NSURLRequestReloadIgnoringCacheData*/NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	[request setValue:__USER_AGENT__ forHTTPHeaderField:@"User-Agent"];
	[request setValue:[ATPlatform deviceUUID] forHTTPHeaderField:@"X-Device-UUID"];

	return request;
}

@end

#pragma clang diagnostic pop
