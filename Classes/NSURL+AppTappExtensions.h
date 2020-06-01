// AppTapp Framework
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//


@interface NSURL (AppTappExtensions)

- (BOOL)isEqualToURL:(NSURL *)aURL;
- (NSString *)comparableStringValue;
- (NSURL *)URLWithInstallerParameters;

- (NSString*)tempDownloadFileName;

@end
