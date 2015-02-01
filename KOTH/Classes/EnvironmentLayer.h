//
//  BoardLayer.h
//  KOTH
//
//  Created by Denis Davydenko on 11/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>
#import "GameController.h"
#import	"CCLabelTTFx.h"
#import "CCMultiSprite.h"


@interface BoardPlayerInfo : CCNode
{
@private
	PlayerInfo *playerInfo_;
	CCLabelTTFx *timeLabel_;
	CCLabelTTFx *nameLabel_;
	CCMultiSprite *faceSprite_;
	CCSprite *disconnectedIcon_;
}

@property (nonatomic, readonly) CCLabelTTFx *timeLabel;
@property (nonatomic, readonly) CCLabelTTFx *nameLabel;
@property (nonatomic, readonly) CCMultiSprite *faceSprite;
@property (nonatomic, readonly) int playerId;
@property (nonatomic, readonly) BOOL isLocalPlayer;
@property (nonatomic) BOOL disconnectedIconVisible;

-(id)initWithPlayerInfo:(PlayerInfo*)info;
-(void)updateWithPlayerInfo:(PlayerInfo*)info;

@end


@interface EnvironmentLayer : CCLayer {

@private
	NSMutableArray *playerInfos_;
	
	CCLabelTTFx *roundRemainingTimeLabel_;
	CCLabelTTFx *gameMessageLabel_;
	CCLabelTTFx *playerPingLabel_;
	CCLabelTTFx *gameConnectingLabel_;
	
	BOOL alertIsOpen_;
	
}

-(void)update:(NSMutableArray*)playerInfos isConnecting:(BOOL)isConnecting;
-(void)setRoundRemainingTime:(int)time;
-(void)setGameMessage:(NSString*)message;
-(void)setPlayerPingTime:(int)pingTime;

@end
