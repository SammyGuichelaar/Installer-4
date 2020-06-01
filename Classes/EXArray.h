//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

/*********        includes        *********/

#import <Foundation/NSArray.h>

/*!
    @category NSArray (EXArray)
*/

@interface NSArray (EXArray)

/*!
    @method extraContainsObjectIdenticalTo:
    @discussion Searches by pointer not by value.
*/
- (BOOL)extraContainsObjectIdenticalTo:(id)object;

/*!
    @method extraFirstObject
    @discussion Returns first object or nil if array is empty.
*/
- (id)extraFirstObject;

/*!
    @method extraObjectAtIndex:
    @discussion Returns nil but does not raise if index is out of range.
*/
- (id)extraObjectAtIndex:(NSUInteger)index;

/*!
    @method extraSortedArray
    @discussion Returns sorted array using selector -compare:.
*/
- (NSArray*)extraSortedArray;

/*!
    @method isExtraReorderedArray:
    @discussion Returns YES if all objects in the receiver are identical to all objects in otherArray, but in different order.
*/
- (BOOL)isExtraReorderedArray:(NSArray*)otherArray;

/*!
    @method isExtraReorderedArray:
    @discussion Returns reordered receiver, so that objects in otherArray go first, in their order in otherArray, then objects in the receiver go, with their order in the receiver.
*/
- (NSArray*)extraReorderedArrayAgainstArray:(NSArray*)otherArray;

/*!
    @method isExtraReorderedArray:
    @discussion Compares by pointer not by value.
*/
- (BOOL)isExtraIdenticalToArray:(NSArray*)otherArray;

@end

/*!
    @category NSMutableArray (EXMutableArray)
*/
@interface NSMutableArray (EXMutableArray)

/*!
    @method extraInsertObjectsFromArray:atIndex:
    @discussion Inserts objects at specified index. Behaves accordingly -insertObjectAtIndex:.
*/
- (void)extraInsertObjectsFromArray:(NSArray*)array atIndex:(NSUInteger)index;

/*!
    @method extraRemoveObjectAtIndex:
    @discussion Removes object at index. Does not raise if index is out of range.
*/
- (void)extraRemoveObjectAtIndex:(NSUInteger)index;

/*!
    @method extraAddObject:
    @discussion Add object to the array. Does not raise if object is nil.
*/
- (void)extraAddObject:(id)object;

/*!
    @method extraRemoveObject:
    @discussion Remove object from the array. Does not raise if object is nil.
*/
- (void)extraRemoveObject:(id)object;

@end
