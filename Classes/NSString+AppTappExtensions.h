// AppTapp Framework
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//


#import "ATPlatform.h"
#import "ATDependencyDescription.h"

@interface NSString (AppTappExtensions)

- (NSString *)stringByRemovingPathPrefix:(NSString *)pathPrefix;
- (BOOL)isContainedInPath:(NSString *)aPath;
- (NSString *)stringByExpandingSpecialPathsInPath;
- (NSString*)sqliteEscapedString;

- (unsigned long long)versionNumber;

- (NSString *)MD5Hash;

- (ATDependencyDescription *)dependencyDescription;

@end
