//
//  Platform.h
//  Jumper_Threads
//
//  Created by Igor Nikolaev on 7/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Platform : NSObject {
	CCSprite *backGroundPlatform_;
	int offset_;
}

+(float)nearestPlatformPositionForX:(float)posX andY:(float)posY;
+(void)platformRangeForX:(float)posX andY:(float)posY leftX:(float*)left rightX:(float*)right;

@property(nonatomic, readonly) CCSprite *backGroundPlatform;
@property(nonatomic, readonly) int offset;

-(void)addOffset: (int)delta;
-(bool)isAtTheTop;
-(bool)isAtTheBottom;
-(void)toTheTop;
-(void)toTheBottom;

@end
