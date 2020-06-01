// AppTapp Framework
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//


@interface NSFileManager (AppTappExtensions)

- (NSString *)fileHashAtPath:(NSString *)aPath;
- (BOOL)createPath:(NSString *)aPath handler:(id)handler;
- (BOOL)copyPath:(NSString *)source toPath:(NSString *)destination handler:(id)handler;
- (NSNumber *)freeSpaceAtPath:(NSString *)aPath;

- (NSString*)tempFilePath;
@end
