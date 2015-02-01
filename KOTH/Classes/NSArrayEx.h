//
//  NSArrayEx.h
//  KOTH
//
//  Created by Denis Davydenko on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray(Extended)

-(BOOL)containsObjectByPredicate:(BOOL(^)(id obj))block;
-(id)objectByPredicate:(BOOL(^)(id obj))block;
-(void)enumerate:(void(^)(id obj))block;

-(void)syncronizeWithArray:(NSArray*)sourceArray 
		  withCompareBlock:(BOOL(^)(id dest, id source))compareBlock 
				onAddBlock:(id(^)(id source))onAddBlock
			 onUpdateBlock:(void(^)(id dest, id source))onUpdateBlock
			 onDeleteBlock:(BOOL(^)(id dest))onDeleteBlock;

@end
