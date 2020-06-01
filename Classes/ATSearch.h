//
//  ATSearch.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>

@class ATResultSet;
@class ATPackage;

extern NSString* ATSearchResultsUpdatedNotification;

@interface ATSearch : NSObject
{
	NSString* searchCriteria;
	NSString* _sortCriteria;
}

@property (retain) NSString* searchCriteria;

- (unsigned int)count;
- (ATPackage *)packageAtIndex:(unsigned int)index;

- (void)searchImmediately;
- (void)_search;
- (void)_externalSearch;

- (NSString*)sortCriteria;
- (void)setSortCriteria:(NSString*)sortCriteria;

@end
