//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

/*********        includes        *********/

#import <Foundation/NSObject.h>

/*********        interface for ATCydiaRepositoryParser        *********/
/*!
    @class ATCydiaRepositoryParser
    @discussion Interface for Cydia repository data parser.
*/

@interface ATCydiaRepositoryParser : NSObject
{
@private
    NSString* _filePath;
    NSMutableArray* _dictionaryRepresentation;
}

+ (id)parserWithContentOfFile:(NSString*)filePath;

- (id)initWithContentOfFile:(NSString*)filePath;

- (NSArray*)dictionaryRepresentation;

+ (NSMutableArray*)dependsFromDictionary:(NSDictionary*)dictionary;
+ (NSArray*)conflictsFromDictionary:(NSDictionary*)dictionary;

@end
