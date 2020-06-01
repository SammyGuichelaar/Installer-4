//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

/*********        includes        *********/

#import <Foundation/Foundation.h>
#import "EXArray.h"

/*********        implementation for EXArray category        *********/

@implementation NSArray (EXArray)

- (BOOL)extraContainsObjectIdenticalTo:(id)obj
{ 
    return [self indexOfObjectIdenticalTo:obj] != NSNotFound; 
}

- (id)extraFirstObject
{
    return [self extraObjectAtIndex:0];
}

- (id)extraObjectAtIndex:(NSUInteger)index
{
    id object = nil;

    if (index < [self count])
        object = [self objectAtIndex:index];

    return object;
}

- (NSArray*)extraSortedArray
{
    return [self sortedArrayUsingSelector:@selector(compare:)];
}

- (BOOL)isExtraReorderedArray:(NSArray*)otherArray
{
    BOOL result = NO;

    if ([self count] == [otherArray count])
    {
        result = YES;
        NSUInteger count = [otherArray count];
        NSUInteger i = 0;
        for (i = 0; i < count; i++)
        {
            if (![self extraContainsObjectIdenticalTo:[otherArray objectAtIndex:i]])
            {
                result = NO;
                break;
            }
        }
    }

    return result;
}

struct EXArrayRelativeReorderingContext
{
    __unsafe_unretained NSArray* receiver;
    __unsafe_unretained NSArray* otherArray;
};

static NSInteger EXCompareObjectsForReorderingArray(id obj1, id obj2, void* inContext)
{
    NSInteger result = NSOrderedAscending;

    NSUInteger otherIdx1 = NSNotFound;
    NSUInteger otherIdx2 = NSNotFound;

    struct EXArrayRelativeReorderingContext* context = (struct EXArrayRelativeReorderingContext*)[(__bridge NSMutableData*)  inContext mutableBytes];
    if (context->otherArray)
    {
        otherIdx1 = [context->otherArray indexOfObject:obj1];
        otherIdx2 = [context->otherArray indexOfObject:obj2];
    }

    if (otherIdx1 == NSNotFound)
    {
        if (otherIdx2 == NSNotFound)
        {
            NSUInteger thisIdx1 = [context->receiver indexOfObject:obj1];
            NSUInteger thisIdx2 = [context->receiver indexOfObject:obj2];
            result = (thisIdx1 < thisIdx2) ? NSOrderedAscending : NSOrderedDescending;
        }
        else
            result = NSOrderedDescending;
    }
    else if (otherIdx2 == NSNotFound)
    {
        result = NSOrderedAscending;
    }
    else
        result = (otherIdx1 < otherIdx2) ? NSOrderedAscending : NSOrderedDescending;

    return result;
}

- (NSArray*)extraReorderedArrayAgainstArray:(NSArray*)otherArray
{
    NSArray* result = self;

    if (otherArray != self && [otherArray count] > 0)
    {
        struct EXArrayRelativeReorderingContext context = {self, otherArray};
        NSMutableData* contextData = [NSMutableData dataWithBytes:&context length:sizeof(struct EXArrayRelativeReorderingContext)];
        result = [self sortedArrayUsingFunction:EXCompareObjectsForReorderingArray context:(__bridge void * _Nullable)(contextData)];
    }

    return result;
}

- (BOOL)isExtraIdenticalToArray:(NSArray*)otherArray
{
    BOOL result = NO;

    if ([self count] == [otherArray count])
    {
        result = YES;
        NSUInteger count = [otherArray count];
        NSUInteger i = 0;
        for (i = 0; i < count; i++)
        {
            if ([self objectAtIndex:i] != [otherArray objectAtIndex:i])
            {
                result = NO;
                break;
            }
        }
    }

    return result;
}

@end

#pragma mark -

@implementation NSMutableArray (EXMutableArray)

- (void)extraInsertObjectsFromArray:(NSArray*)array atIndex:(NSUInteger)index
{
    NSEnumerator* enumerator = [array objectEnumerator];
    NSObject* entry = nil;

    while (entry = [enumerator nextObject])
        [self insertObject:entry atIndex:index++];
}

- (void)extraRemoveObjectAtIndex:(NSUInteger)index
{
    if (index < [self count])
        [self removeObjectAtIndex:index];
}

- (void)extraAddObject:(id)object
{
    if (object != nil)
        [self addObject:object];
}

- (void)extraRemoveObject:(id)object
{
    if (object != nil)
        [self removeObject:object];
}

@end
