//
//  Platform.m
//  Jumper_Threads
//
//  Created by Igor Nikolaev on 7/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Platform.h"
#import "Jumper.h"

// This macro evaluates to the number of elements in an array. 
#define chDIMOF(Array) (sizeof(Array) / sizeof(Array[0]))

// This macro evaluates to the number of elements in an array. 
#define chDIMOFS(Array) ((sizeof(Array) / sizeof(Array[0])) - 1)


struct PlatformRock
{
	float left, right;
	float level;
	
	PlatformRock(float leftGranX, float rightGranX, float granY)
	{
		const float rockEdgeOffset = 5;
		left = leftGranX + rockEdgeOffset - [Jumper halfWidth];
		right = rightGranX - rockEdgeOffset + [Jumper halfWidth];
		level = granY;
	}
};

static PlatformRock allPlatforms[] = {
	PlatformRock(15.5, 104.5, 67.5)	//0
	, PlatformRock(142.5, 203.5, 67.5)	//1
	, PlatformRock(254.5, 364.5, 67.5)	//2
	, PlatformRock(387.5, 477.5, 67.5)	//3
	
	, PlatformRock(301.5, 356.5, 151.5)	//4
	, PlatformRock( 72.5, 125.5, 162.5)	//5
	, PlatformRock(349.5, 404.5, 216.5)	//6
	, PlatformRock(151.5, 264.5, 250.5)	//7
	, PlatformRock(238.5, 294.5, 334.5)	//8
	, PlatformRock(127.5, 185.5, 405.5)	//9
	, PlatformRock(198.5, 256.5, 464.5)	//10
	, PlatformRock(311.5, 364.5, 541.5)	//11
	, PlatformRock( 83.5, 137.5, 539.5)	//12
	, PlatformRock(182.5, 235.5, 606.5)	//13
	, PlatformRock(214.5, 268.5, 710.5)	//14
	, PlatformRock( 85.5, 141.5, 768.5)	//15
	, PlatformRock(272.5, 328.5, 797.5)	//16
};


@interface Platform(Private)

+(int)_nearestPlatformIndexForX:(float)posX andY:(float)posY;

-(void)_setOffset: (int)offset;

@end


@implementation Platform

+(float)nearestPlatformPositionForX:(float)posX andY:(float)posY
{
	int index = [Platform _nearestPlatformIndexForX:posX andY:posY];
	return (index != -1) ? allPlatforms[index].level + [Jumper halfHeight] : -200.f;
}

+(int)_nearestPlatformIndexForX:(float)posX andY:(float)posY
{
	int result = -1;
	float unitBottom = posY - [Jumper halfHeight];
	float bestDif = unitBottom + 1000;
	for (int i = 0; i != chDIMOF(allPlatforms); ++i)
	{
		if (posX >= allPlatforms[i].left 
			&& posX <= allPlatforms[i].right)
		{
			float platformY = allPlatforms[i].level;
			if (unitBottom >= platformY)
			{
				float dif = unitBottom - platformY;
				if (dif < bestDif)
				{
					bestDif = dif;
					result = i;
				}
			}
		}
	}
	return result;
}

+(void)platformRangeForX:(float)posX andY:(float)posY leftX:(float*)left rightX:(float*)right
{
	int index = [self _nearestPlatformIndexForX:posX andY:posY];
	if (index != -1) {
		PlatformRock rock = allPlatforms[index];
		*left = rock.left;
		*right = rock.right;
	}else {
		*left = 0;
		*right = [[CCDirector sharedDirector] winSize].width;
	}
}

@synthesize backGroundPlatform = backGroundPlatform_;
@synthesize offset = offset_;

-(id)init
{
	if ((self = [super init]))
	{
		offset_ = 0;
		backGroundPlatform_ = nil;
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		[backGroundPlatform_ release];
		backGroundPlatform_ = [[CCSprite spriteWithFile:@"JumpBackground.png"] retain];
		backGroundPlatform_.anchorPoint = ccp(0,0);
		backGroundPlatform_.position = ccp(0,0);		
	}
	return self;
}

-(void)addOffset: (int)delta
{
	[self _setOffset: offset_ + delta];
}

-(void)_setOffset: (int)offset
{
	offset_ = offset;
	int screenHeight = [[CCDirector sharedDirector] winSize].height;
	if (offset_ < 0) offset_ = 0;
	if (offset_ > backGroundPlatform_.contentSize.height - screenHeight) 
		offset_ = backGroundPlatform_.contentSize.height - screenHeight;
	backGroundPlatform_.position=ccp(0, offset_*-1);
}

-(bool)isAtTheBottom
{
	return offset_ == 0;
}

-(bool)isAtTheTop
{
	int screenHeight = [[CCDirector sharedDirector] winSize].height;
	return offset_ == backGroundPlatform_.contentSize.height - screenHeight;
}

-(void)toTheTop
{
	[self _setOffset:backGroundPlatform_.contentSize.height - [[CCDirector sharedDirector] winSize].height];
}

-(void)toTheBottom
{
	[self _setOffset:0];
}

- (void) dealloc
{
	[backGroundPlatform_ release];
	[super dealloc];
}

@end
