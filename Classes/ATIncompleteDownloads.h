//
//  ATIncompleteDownloads.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>

@class ATIncompleteDownload;

@interface ATIncompleteDownloads : NSObject {

}

- (ATIncompleteDownload *)downloadWithLocation:(NSURL*)url;
- (void)cleanupTempFolder;

@end
