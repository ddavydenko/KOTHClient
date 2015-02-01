//
//  Player.h
//  KOTH
//
//  Created by Denis Davydenko on 10/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>
#import "CCLabelTTFx.h"
#import "PlayerColor.h"

@interface Player : NSObject {
	
@protected
	int playerId_;
	NSString *playerName_;
	CCLabelTTFx *playerNameLabel_;
	BOOL isLocalPlayer_;
	PlayerColor color_;
	BOOL isDisplayed_;
	
	//server data
	float srvPosX_;
	float srvPosY_;
	BOOL srvDirection_;
	float srvRotation_;
	BOOL isPaused_;
	
#ifdef SHOW_SERVER_VIEW		
	CCSprite *serverView_;
#endif
	
	//local data
	float posX_;
	float posY_;
	float rotation_;
	BOOL direction_; //YES - to the left; NO - to the right	
	BOOL isFrozen_;
}

@property (nonatomic, readonly) int playerId;
@property (nonatomic, readonly) NSString *playerName;
@property (nonatomic, readonly) BOOL isDisplayed;
@property (nonatomic) BOOL isLocalPlayer;
@property (nonatomic) float srvPosX;
@property (nonatomic) float srvPosY;
@property (nonatomic) BOOL srvDirection;
@property (nonatomic) float srvRotation;

@property (nonatomic, readonly) float posX;
@property (nonatomic, readonly) float posY;
@property (nonatomic) BOOL isFrozen;

-(id)initWithId:(int)playerId name:(NSString*)name color:(PlayerColor)color position:(CGPoint)position;

-(void)addToScene:(CCLayer*)scene;
-(void)removeFromScene;
-(void)update:(ccTime)dt;

-(void) schedule:(SEL)selector;
-(void) schedule:(SEL)selector interval:(ccTime)interval;
-(void) unschedule:(SEL)selector;
-(void) unscheduleAllSelectors;

-(CCNode*)currentView;
-(void)setIsPaused:(BOOL)isPaused;

@end

