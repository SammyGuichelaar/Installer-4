//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

/*********        includes        *********/

#import "ATCydiaRepositoryParser.h"

/*********        implementation for ATCydiaRepositoryParser        *********/

@implementation ATCydiaRepositoryParser

+ (id)parserWithContentOfFile:(NSString*)filePath
{
    return [[self alloc] initWithContentOfFile:filePath];
}

- (id)initWithContentOfFile:(NSString*)filePath
{
    self = [super init];
    
    if (self)
        _filePath = filePath;
    
    return self;
}



#pragma mark -
#pragma mark *** Public methods ***
#pragma mark -

- (NSArray*)dictionaryRepresentation
{
    if (_dictionaryRepresentation == nil && _filePath != nil)
    {
        NSError* error = nil;
        
        NSString* dataString = [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
        if (dataString == nil)
            dataString = [NSString stringWithContentsOfFile:_filePath encoding:NSASCIIStringEncoding error:&error];
        
        if (dataString != nil)
        {
            NSArray* components = [dataString componentsSeparatedByString:@"\x0A\x0A"];
            NSString* component = nil;
            
            for (component in components)
            {
                NSArray* infoComponents = [component componentsSeparatedByString:@"\x0A"];
                NSString* infoComponent = nil;
                NSMutableDictionary* info = nil;
                
                for (infoComponent in infoComponents)
                {
                    NSRange findedRange = [infoComponent rangeOfString:@":"];
                    if (findedRange.location < [infoComponent length])
                    {
                        NSString* key = [[[infoComponent substringToIndex:findedRange.location] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] lowercaseString];
                        NSString* value = [[infoComponent substringFromIndex:(findedRange.location + 1)] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
                        
                        if (info == nil)
                            info = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        if (value != nil && key != nil)
                            [info setObject:value forKey:key];
                    }
                }
                
                if (info != nil)
                {
                    if (_dictionaryRepresentation == nil)
                        _dictionaryRepresentation = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    [_dictionaryRepresentation addObject:info];
                }
            }
        }
    }
    
    return _dictionaryRepresentation;
}

+ (NSMutableArray*)dependsFromDictionary:(NSDictionary*)dictionary
{
    NSMutableArray* result = nil;
    
    NSArray* components = nil;
    
    NSString* dependsString = [dictionary objectForKey:@"depends"];
    if (dependsString != nil)
        components = [dependsString componentsSeparatedByString:@","];
    else
        components = [dictionary objectForKey:@"PackageDependency"];
    
    if ([components count] > 0)
    {
        NSString* dependString = nil;
        
        for (dependString in components)
        {
            NSString* correctDependString = dependString;
            
            NSRange findedRange = [correctDependString rangeOfString:@"("];
            if (findedRange.location < [correctDependString length])
                correctDependString = [correctDependString substringToIndex:findedRange.location];
            
            correctDependString = [correctDependString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
            
            if ([correctDependString length] > 0)
            {
                if (result == nil)
                    result = [NSMutableArray arrayWithCapacity:0];
                
                [result addObject:[correctDependString lowercaseString]];
            }
        }
    }
    
    return result;
}

+ (NSArray*)conflictsFromDictionary:(NSDictionary*)dictionary
{
    NSMutableArray* result = nil;
    
    NSArray* components = nil;
    
    NSString* conflictsString = [dictionary objectForKey:@"conflicts"];
    if (conflictsString == nil)
        conflictsString = [dictionary objectForKey:@"Conflicts"];
    
    if (conflictsString != nil)
        components = [conflictsString componentsSeparatedByString:@","];
    
    if ([components count] > 0)
    {
        NSString* conflictString = nil;
        
        for (conflictString in components)
        {
            NSString* correctConflictString = conflictString;
            
            correctConflictString = [correctConflictString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
            
            if ([correctConflictString length] > 0)
            {
                if (result == nil)
                    result = [NSMutableArray arrayWithCapacity:0];
                
                [result addObject:[correctConflictString lowercaseString]];
            }
        }
    }
    
    return result;
}

@end

