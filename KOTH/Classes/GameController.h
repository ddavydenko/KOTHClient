//
//  GameController.h
//  KOTH
//
//  Created by Denis Davydenko on 10/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "PlayerColor.h"
#import "Fighter.h"
#import "Jumper.h"
#import "Server.h"

#define GAME_SCENE_PAGE_TURN_TIME 0.5f

typedef enum  {
	gstNone,
	gstJumpScene,
	gstFightScene,
} GameSceneType;

typedef enum {
	gsNone,
	gsWaitingOthers,
	gsCountdownToGame,
	gsJumping,
	gsFighting,
	gsWaitDisconnection,
	gsGameOver,
	gsDisconnected,
} GameState;

@interface PlayerInfo : NSObject
{
	
@private
	int playerId_;
	NSString *name_;
	PlayerColor color_;
	int time_; //in s	
	int punches_;
	BOOL isWinner_;
	BOOL isLocalPlayer_;
	BOOL isPaused_;
	BOOL isDisconnected_;
}

@property (nonatomic) int playerId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic) PlayerColor color;
@property (nonatomic) int time;
@property (nonatomic) int punches;
@property (nonatomic) BOOL isWinner;
@property (nonatomic) BOOL isLocalPlayer;
@property (nonatomic) BOOL isPaused;
@property (nonatomic) BOOL isDisconnected;

@end

@interface GameController : NSObject {

@private
	int roomCapacity_;
	int roundTimeInMins_;
	int	localPlayerId_;
	GameSceneType sceneType_;

	NSMutableArray *playerInfos_;
	NSMutableDictionary *players_;
	
	int roundRemainingTime_;
	int coundownTime_;
	int localPlayerPingTime_;
	BOOL isCountdownToGame_;
	GameState gameState_;
	
	float serverUpdateDelay_;
	BOOL isConnecting_;
}

+(void)createNewGame;
+(GameController*)game;

@property (nonatomic, readonly) NSMutableArray *playerInfos;
@property (nonatomic, readonly) int localPlayerPingTime; //in ms
@property (nonatomic, readonly) int roundRemainingTime; //in s
@property (nonatomic, readonly) GameState gameState;
@property (nonatomic, readonly) GameSceneType sceneType;
@property (nonatomic, readonly) int countdownTime; //in s
@property (nonatomic, readonly) BOOL isConnecting;

-(void)startWithPlayerId:(int)playerId numberOfPlayers:(int)roomCapacity andGameTimeInMins:(int)roomTimeInMins;
-(void)addNewPlayersToScene:(CCLayer*)scene withType:(GameSceneType)type;
-(Fighter*)localFighter;
-(Jumper*)localJumper;
-(NSArray*)allPlayers;
-(void)pause;
-(void)resume;
-(void)quit;
-(void)update:(ccTime)dt;

@end
