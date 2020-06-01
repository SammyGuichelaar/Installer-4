//
//  ATSources.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATSource.h"


@interface ATSources : NSObject {

}

- (unsigned int)count;
- (ATSource *)sourceAtIndex:(unsigned int)index;
- (ATSource *)sourceWithLocation:(NSString*)locationString;
- (BOOL)addSourceWithLocation:(NSString *)locationString;
- (BOOL)removeSourceWithLocation:(NSString *)locationString;

@end
