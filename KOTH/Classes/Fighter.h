//
//  Fighter.h
//  KOTH
//
//  Created by Denis Davydenko on 10/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>
#import "CCLabelTTFx.h"
#import "Player.h"
#import "CCMultiSprite.h"
#import "SimpleAudioEngine.h"

//#define SHOW_SERVER_VIEW 

typedef enum{
	fsStanding,
	fsClientMovement,
	fsFollowServerMovement,
	fsHitting,
	fsCrashing,
	fsFrozen,
} FighterState;

typedef enum {
	fhrNone = 0,
	fhrCrash = 1,
	fhrFightComplete = 2,
	fhrHit = 4
}FighterHitResult;


@interface Fighter : Player {

@private
	
	CCMultiSprite *view_;
	CCSprite *collisionSprite_;
	
	//server data
	BOOL srvIsHitting_;
	FighterHitResult hitResult_;
	
	//local data
	FighterState state_;
	BOOL isWaitingForServerHitResult_;
	BOOL isActionMovement_;
	BOOL isAlone_;
	BOOL isEatingGrass_;

	//state temp data
	float localXTarget_;
	FighterHitResult awaitedAttackerHitResult_;
	
	//for eating sound management
	ALuint eatSoundId_;
}

+(id)fighterWithId:(int)playerId name:(NSString*)name color:(PlayerColor)color position:(CGPoint)position;

-(id)initWithId:(int)playerId name:(NSString*)name color:(PlayerColor)color position:(CGPoint)position;
-(void)moveOnClientToDirection:(BOOL)direction;
-(void)setIsHitting:(BOOL)isPreparingToHit hitResult:(FighterHitResult)hitResult;
-(void)setHitResult:(FighterHitResult)hitResult hitToSide:(BOOL)hitSide; //YES - to the left; NO - to the right
-(void)update:(ccTime)dt;
-(void)setIsAlone:(BOOL)isAlone;

@end


