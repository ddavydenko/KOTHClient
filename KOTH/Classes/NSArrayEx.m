//
//  NSArrayEx.m
//  KOTH
//
//  Created by Denis Davydenko on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSArrayEx.h"


@implementation NSArray(Extended)

-(BOOL)containsObjectByPredicate:(BOOL(^)(id obj))block
{
	return [self objectByPredicate:block] != nil;
}


-(id)objectByPredicate:(BOOL(^)(id obj))block
{
	for (id obj in self) {
		if (block(obj)) {
			return obj;
		}
	}
	return nil;
}

-(void)enumerate:(void(^)(id obj))block
{
	for (id obj in self) {
		block(obj);
	}
}

-(void)syncronizeWithArray:(NSArray*)sourceArray 
					withCompareBlock:(BOOL(^)(id dest, id source))compareBlock 
					onAddBlock:(id(^)(id source))onAddBlock
					onUpdateBlock:(void(^)(id dest, id source))onUpdateBlock
					onDeleteBlock:(BOOL(^)(id dest))onDeleteBlock
{
	for(id source in sourceArray)
	{
		BOOL exists = NO;
		for(id dest in self)
		{
			if (compareBlock(dest, source)) {
				onUpdateBlock(dest, source);
				exists = YES;
				break;
			}
		}
		if (!exists) {
			id newObj = onAddBlock(source);
			if (newObj) {
				[self addObject:newObj];
			}	
		}
	}
	
	NSMutableArray *objectsForRemoval = nil;
	for(id dest in self)
	{
		BOOL exists = NO;
		for(id source in sourceArray)
		{
			if (compareBlock(dest, source)) {
				onUpdateBlock(dest, source);
				exists = YES;
				break;
			}
		}
		if (!exists) {
			if(onDeleteBlock(dest)) {
				if (objectsForRemoval == nil) {
					objectsForRemoval = [[NSMutableArray alloc] init];
				}
				[objectsForRemoval addObject:dest];
			}	
		}
	}

	if (objectsForRemoval != nil) {
		for(id objForRemoval in objectsForRemoval)
		{
			[self removeObject:objForRemoval];
		}
		[objectsForRemoval release];
	}
}

@end
