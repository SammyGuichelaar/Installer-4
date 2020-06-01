//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

/*********        includes        *********/

#import <Foundation/NSDictionary.h>

@class NSBundle;

/*********        creation dictionary from resource file         *********/

@interface NSDictionary (EXDictionaryCreation)

+ (id)extraDictionaryNamed:(NSString*)name; // Look for in main bundle.
+ (id)extraDictionaryNamed:(NSString*)name inBundle:(NSBundle*)bundle;

// Returns joined dictionaries as new object. Sub-arrays and dictionaries are joined also.
- (id)extraDictionaryByAppendingDictionary:(NSDictionary*)dictionary;

- (BOOL)extraContainsDictionary:(NSDictionary*)dictionary;

// If omitAbsent is YES, [NSNull null] is inserted in place of missing objects, otherwise the missing key is just skipped
- (NSArray*)extraObjectsForKeys:(NSArray*)keys omitAbsent:(BOOL)omitAbsent;

@end

@interface NSMutableDictionary (EXExtensions)

// Joins self and dictionary. Returns self. Sub-arrays and dictionaries are joined also.
- (id)extraAppendDictionary:(NSDictionary*)dictionary;

@end
