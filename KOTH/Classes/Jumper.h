//
//  Jumper.h
//  KOTH
//
//  Created by Denis Davydenko on 10/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>
#import "CCLabelTTFx.h"
#import "Player.h"


typedef enum {
	jcsNone = 0, 
	jcsCollisionWinner = 1, 
	jcsCollisionLoser = 2
}JumperCollisionState;

@interface Jumper : Player
{
	
@private
	
	CCSprite *view_;
	CCSprite *fallenView_;
	
	float prevPosY_;
	float velX_;
	float velY_;
	float prevVelY_;
	float srvVelY_;
	float accelX_;
	float accelY_;
	float rotationVel_;
	JumperCollisionState collisionState_;
	
	BOOL isFallen_; 
	
	BOOL isWandering_;
	float startXPosition_;
	float leftXBoundForWandering_;
	float rightXBoundForWandering_;
	
	float yOffset_;
}

@property (nonatomic) float velX;
@property (nonatomic) float velY;
@property (nonatomic) float accelX;
@property (nonatomic) float accelY;
@property (nonatomic) float rotationVel;
@property (nonatomic) BOOL isWandering;

+(id)jumperWithId:(int)playerId name:(NSString*)name color:(PlayerColor)color 
		 position:(CGPoint)position isLocalPlayer:(BOOL)isLocalPlayer;
+(float)halfWidth;
+(float)halfHeight;

-(id)initWithId:(int)playerId name:(NSString*)name color:(PlayerColor)color 
	   position:(CGPoint)position isLocalPlayer:(BOOL)isLocalPlayer;
-(void)setIsFallen:(BOOL)isFallen; 
-(void)setCollisionState:(JumperCollisionState)state;
-(void)update:(ccTime)dt;
-(void)startWanderingFromLeftX:(float)leftX toRigthX:(float)rightX;
-(void)toStartPositionForMaxTime:(int)timeToStart; //in secs
-(void)stopWandering;
-(void)setYOffset:(float)yOffset;

@end

