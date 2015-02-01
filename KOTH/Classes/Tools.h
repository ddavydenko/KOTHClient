//
//  Tools.h
//  KOTH
//
//  Created by Denis Davydenko on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^VoidBlock)();
typedef void(^BOOLBlock)(BOOL);
typedef void(^Int64Block)(int64_t);


BOOL randomBOOL();
float randomFromMinToMax(float min, float max);
int randomIntFromMinToMax(int min, int max);
void ccDrawRect(CGFloat x, CGFloat y, CGFloat width, CGFloat height);

@interface NSString(Tools)

-(NSString*)truncatedStringToLength:(int)length;
-(NSString*)truncatedStringToWidth:(CGFloat)width withFont:(UIFont*)font;

@end

