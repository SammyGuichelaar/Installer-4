//
//  ATEntity.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface ATEntity : NSObject {
	NSString*			tableName;
	sqlite_int64		entryID;
	BOOL				autocommit;
	
@private
	NSMutableDictionary*	pendingChanges;
}

@property (retain) NSString* tableName;
@property (assign) sqlite_int64 entryID;
@property (assign) BOOL autocommit;

- (id)initWithTable:(NSString*)table entryID:(sqlite_int64)entryID;
- (BOOL)commit;
- (void)remove;		// subclassers can override to remove associated items

@end
