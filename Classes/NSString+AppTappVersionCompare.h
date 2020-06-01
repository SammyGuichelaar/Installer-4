//
//  NSString+AppTappVersionCompare.h
//  Installer
//
//  Created by Slava Karpenko on 3/19/09.
//  Copyright 2009 Slava Karpenko. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (AppTappVersionCompare)

/*
operation can be one of:
 lt le eq ne ge gt       (treat empty version as earlier than any version);
 lt-nl le-nl ge-nl gt-nl (treat empty version as later than any version);
 < << <= = >= >> >
 
 if operation is nil, 'lt' is assumed
*/

- (BOOL)compareWithVersion:(NSString*)version operation:(NSString*)operation;
@end
