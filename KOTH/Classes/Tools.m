//
//  Tools.m
//  KOTH
//
//  Created by Denis Davydenko on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Tools.h"
#import "cocos2d.h"


BOOL randomBOOL()
{
	return (BOOL)(rand()%2);
}

float randomFromMinToMax(float min, float max)
{
	return min + (max - min) * ((float)rand()/RAND_MAX);
}

int randomIntFromMinToMax(int min, int max)
{
	return min + (float)(max - min) * ((float)rand()/RAND_MAX);
}

void ccDrawRect(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
	CGPoint points[] = {{x, y}, {x + width, y}, {x + width, y + height}, {x, y + height}};
	ccDrawPoly( points, 4, YES );
}

@implementation NSString(Tools)

-(NSString*)truncatedStringToLength:(int)length
{
	return self.length > length ? [[self substringToIndex:length] stringByAppendingString:@"..."] : self;
}

-(NSString*)truncatedStringToWidth:(CGFloat)width withFont:(UIFont*)font
{
	if ([self sizeWithFont:font].width <= width) {
		return self;
	}
	
	CGSize dotsSize = [@"..." sizeWithFont:font];
	do
	{
		self = [self substringToIndex:[self length] - 1];
	}while ([self sizeWithFont:font].width + dotsSize.width > width);
	
	return [self stringByAppendingString:@"..."];
}

@end