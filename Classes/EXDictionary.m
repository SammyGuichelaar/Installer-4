//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

/*********        includes        *********/

#import <Foundation/Foundation.h>
#import "EXDictionary.h"

/*********        creation dictionary from resource file         *********/

@implementation NSDictionary (EXDictionaryCreation)

+ (id)extraDictionaryNamed:(NSString*)name
{
    return [self extraDictionaryNamed:name inBundle:[NSBundle mainBundle]];
}

+ (id)extraDictionaryNamed:(NSString*)name inBundle:(NSBundle*)bundle
{
    NSString* ext = [name pathExtension];
    NSString* path = [ext length] ? [bundle pathForResource:[name stringByDeletingPathExtension] ofType:ext] : nil;
    NSDictionary* dictionary = nil;

    if (path)
        dictionary = [self dictionaryWithContentsOfFile:path];

    if (!dictionary)
    {
        path = [bundle pathForResource:name ofType:@"list"];
        if (path)
            dictionary = [self dictionaryWithContentsOfFile:path];
    }

    if (!dictionary)
    {
        path = [bundle pathForResource:name ofType:@"plist"];
        if (path)
            dictionary = [self dictionaryWithContentsOfFile:path];
    }

    if (!dictionary)
    {
        path = [bundle pathForResource:name ofType:@"toolbar"];
        if (path)
            dictionary = [self dictionaryWithContentsOfFile:path];
    }

    if (!dictionary)
    {
        path = [bundle pathForResource:name ofType:@"strings"];
        if (path)
            dictionary = [self dictionaryWithContentsOfFile:path];
    }

    if (!dictionary)
    {
        path = [bundle pathForResource:name ofType:nil];
        if (path)
            dictionary = [self dictionaryWithContentsOfFile:path];
    }

    return dictionary;
}

- (id)extraDictionaryByAppendingDictionary:(NSDictionary*)dictionary
{
    NSMutableDictionary* mutableCopy = [NSMutableDictionary dictionaryWithDictionary:self];

    return [[self class] dictionaryWithDictionary:[mutableCopy extraAppendDictionary:dictionary]];
}

- (BOOL)extraContainsDictionary:(NSDictionary*)dictionary
{
    BOOL result = NO;

    if ([dictionary count] > 0)
    {
        result = YES;
        NSEnumerator* enumerator = [dictionary keyEnumerator];
        NSString* key = nil;
        while (key = [enumerator nextObject])
        {
            id ourValue = [self objectForKey:key];
            if (ourValue)
            {
                id otherValue = [dictionary objectForKey:key];
                result = [otherValue isEqual:ourValue];
            }
            else
                result = NO;
            if (!result)
                break;
        }
    }

    return result;
}

- (NSArray*)extraObjectsForKeys:(NSArray*)keys omitAbsent:(BOOL)omitAbsent
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[keys count]];

    NSEnumerator* enumerator = [keys objectEnumerator];
    NSString* key = nil;
    id null = nil;

    while (key = [enumerator nextObject])
    {
        id object = [self objectForKey:key];
        if (!object && !omitAbsent)
        {
            if (!null)
                null = [NSNull null];
            object = null;
        }
        if (object)
            [array addObject:object];
    }

    return array;
}

@end

@implementation NSMutableDictionary (EXExtensions)

- (id)extraAppendDictionary:(NSDictionary*)dictionary
{
    NSEnumerator* additionalKeysEnumerator = [dictionary keyEnumerator];
    NSString* additionalKey = nil;
    id additionalValue = nil;
    id value = nil;

    while (additionalKey = [additionalKeysEnumerator nextObject])
    {
        additionalValue = [dictionary objectForKey:additionalKey];
        value = [self objectForKey:additionalKey];

        if ([additionalValue isKindOfClass:[NSDictionary class]])
        {
                if (value)
                    value = [NSMutableDictionary dictionaryWithDictionary:value];
                else
                    value = [NSMutableDictionary dictionary];

                additionalValue = [value extraAppendDictionary:additionalValue];
        }
        else if ([additionalValue isKindOfClass:[NSArray class]])
        {
            if (value)
                additionalValue = [value arrayByAddingObjectsFromArray:additionalValue];        
            else
                additionalValue = [NSArray arrayWithArray:additionalValue];
        }

        [self setObject:additionalValue forKey:additionalKey];
    }

    return self;
}

@end
