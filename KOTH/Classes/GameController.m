//
//  GameController.m
//  KOTH
//
//  Created by Denis Davydenko on 10/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameController.h"
#import "Server.h"
#import "JumpScene.h"
#import "FightScene.h"
#import "Jumper.h"
#import "Fighter.h"
#import "GameOverScene.h"
#import "NSArrayEx.h"
#import "Platform.h"
#import "HomeScene.h"
#import "Tools.h"
#import "SimpleAudioEngine.h"

#define CONVERT_TO_FIGHT_Y(y) (y - (960.f - 85.f) + 115.f)
#define MAX_SERVER_DELAY 0.8f

@implementation PlayerInfo

@synthesize playerId = playerId_;
@synthesize name = name_;
@synthesize color = color_;
@synthesize time = time_;
@synthesize punches = punches_;
@synthesize isWinner = isWinner_;
@synthesize isLocalPlayer = isLocalPlayer_;
@synthesize isPaused = isPaused_;
@synthesize isDisconnected = isDisconnected_;

-(id) copyWithZone: (NSZone*) zone
{
	PlayerInfo *copy = [[[self class] allocWithZone: zone] init];
	copy.playerId = playerId_;
	copy.name = name_;
	copy.color = color_;
	copy.time = time_;
	copy.punches = punches_;
	copy.isWinner = isWinner_;
	copy.isLocalPlayer = isLocalPlayer_;
	copy.isPaused = isPaused_;
	copy.isDisconnected = isDisconnected_;
	return copy;
}

@end

@interface GameController(Private)

-(id)_init;
-(void)_switchScene:(GameSceneType)sceneType;
-(void)_stopScene;
-(void)_subscribeToServerData;
-(void)_handleConnectedPlayers:(int)number players:(SDConnectedPlayerInfo*) players;
-(void)_handleDisconnectedPlayer:(int)playerId;
-(void)_handleCountdownToGame:(int)timeToStart;

-(void)_handleJumpInfo:(int)number remainingTime:(int)timeToGameOver playerIds:(int*)playerIds players:(SDJumperInfo*)players;
-(Jumper*)_addJumper:(int)playerId withName:(NSString*)name andColor:(PlayerColor)color toPosition:(CGPoint)pos;
-(void)_updateJumper:(Jumper*)jumper withData:(SDJumperInfo)data;

-(void)_handleFightInfo:(int)number remainingTime:(int)timeToGameOver playerIds:(int*)playerIds players:(SDFighterInfo*)players;
-(Fighter*)_addFighter:(int)playerId withName:(NSString*)name andColor:(PlayerColor)color toPosition:(CGPoint)pos;
-(void)_updateFighter:(Fighter*)fighter withData:(SDFighterInfo)data;

-(void)_findAndRemoveDisconnectedPlayers:(int*)playerIds number:(int)number;
-(BOOL)_localPlayerExistsIn:(int*)playerIds number:(int)number;
-(void)_handleGameOverInfo:(int)number players:(SDPlayerScoreInfo*)players;
-(void)_detectLider;
-(PlayerInfo*)_playerInfoById:(int)playerId;
-(void)_removePlayerById:(int)playerId;

-(void)_handleServerDisconnectedEvent;
-(void)_updatedFromServer;

@end

@implementation GameController

@synthesize playerInfos = playerInfos_;
@synthesize localPlayerPingTime = localPlayerPingTime_; //in ms
@synthesize roundRemainingTime = roundRemainingTime_; //in s
@synthesize gameState = gameState_;
@synthesize countdownTime = countdownTime_; //in s
@synthesize isConnecting = isConnecting_;
@synthesize sceneType = sceneType_;

static GameController *currentGame_ = nil; 

+(void)createNewGame
{
	[currentGame_ release];
	currentGame_ = [[self alloc] _init];
}

+(GameController*)game
{
	return currentGame_;
}

-(id)_init
{
	if ((self = [super init])) {
		localPlayerId_ = -1;
		sceneType_ = gstNone;
		
		playerInfos_ = [[NSMutableArray arrayWithCapacity:MAX_NUMBER_OF_PLAYERS] retain];
		players_ = [[NSMutableDictionary dictionaryWithCapacity:MAX_NUMBER_OF_PLAYERS] retain];

		isCountdownToGame_ = NO;
		gameState_ = gsNone;

		isConnecting_ = NO;
		
		[self _subscribeToServerData];
	}
	return self;
}

-(void)startWithPlayerId:(int)playerId numberOfPlayers:(int)roomCapacity andGameTimeInMins:(int)roomTimeInMins
{
	localPlayerId_ = playerId;
	roomCapacity_ = roomCapacity;
	roundTimeInMins_ = roomTimeInMins;
	roundRemainingTime_ = roomTimeInMins * 60;
	
	sceneType_ = gstJumpScene;
	gameState_ = gsWaitingOthers;
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:GAME_SCENE_PAGE_TURN_TIME 
																					 scene:[JumpScene scene:NO]]];
}

-(void)addNewPlayersToScene:(CCLayer*)scene withType:(GameSceneType)type
{
	if (sceneType_ != type)
		return;
	
	for (Player *player in [players_ allValues]) {
		if (!player.isDisplayed) {
			[player addToScene:scene];
		}
	}
	
}

-(Fighter*)localFighter
{
	if (sceneType_ != gstFightScene)
		return nil;

	for (Fighter *fighter in [players_ allValues]) {
		if (fighter.isLocalPlayer) {
			return fighter;
		}
	}
	return nil;
}

-(Jumper*)localJumper
{
	if (sceneType_ != gstJumpScene)
		return nil;

	for (Jumper *jumper in [players_ allValues]) {
		if (jumper.isLocalPlayer) {
			return jumper;
		}
	}
	return nil;
}

-(NSArray*)allPlayers
{
	return [players_ allValues];
}

-(void)pause
{
	if (gameState_ != gsDisconnected && gameState_ !=gsWaitDisconnection && gameState_ != gsNone && gameState_ !=gsGameOver) {
		[[Server srv] sendPause:YES]; 
	}
}

-(void)resume
{
	if (gameState_ != gsDisconnected && gameState_ !=gsWaitDisconnection && gameState_ != gsNone && gameState_ !=gsGameOver) {
		[[Server srv] sendPause:NO]; 
	}
}

-(void)quit
{
	[self _stopScene];
	sceneType_ = gstNone;
	gameState_ = gsDisconnected;
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:GAME_SCENE_PAGE_TURN_TIME 
																					 scene:[HomeScene scene] backwards:YES]];
	[self performSelector:@selector(_disconnect) withObject:nil afterDelay:0.2];
}

-(void)update:(ccTime)dt
{
	if (gameState_ == gsJumping || gameState_ == gsFighting) {
		serverUpdateDelay_ += dt;
		
		if (serverUpdateDelay_ > MAX_SERVER_DELAY && !isConnecting_) {
			isConnecting_ = YES;
			NSLog(@"connecting to server...");
			
			for (Player *player in [players_ allValues]) {
				[player setIsPaused:YES];
				player.isFrozen = YES;
			}
		}
	}
}

-(void)_disconnect
{
	[[Server srv] disconnect];
}

-(void)_switchScene:(GameSceneType)sceneType
{
	if (sceneType_ != sceneType)
	{
		[self _stopScene];
		if (sceneType == gstJumpScene)
			[[CCDirector sharedDirector] replaceScene:[JumpScene scene:(sceneType_ == gstFightScene)]];
		else if (sceneType == gstFightScene)
			[[CCDirector sharedDirector] replaceScene:[FightScene scene]];

		sceneType_ = sceneType;
	}
}

-(void)_stopScene
{
	for (Player *player in [players_ allValues])
		[player removeFromScene];
	
	[players_ removeAllObjects];
	
	[[[CCDirector sharedDirector] runningScene] unscheduleAllSelectors];
	
	if (sceneType_ == gstJumpScene) {
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	}
}

-(void)_subscribeToServerData
{
	[[Server srv] waitConnectedPlayersWithBlock:^(int roomCapacity, int number, SDConnectedPlayerInfo *players)
	 {
		 [self _handleConnectedPlayers:number players:players];
	 }];
	
	[[Server srv] waitCountdownToGameWithBlock:^(int timeToStart)
	 {
		 [self _handleCountdownToGame:timeToStart];
	 }];
	
	[[Server srv] waitJumpInfoWithBlock:^(int number, int timeToGameOver, int *playerIds, SDJumperInfo *players)
	 {
		 [self _handleJumpInfo:number remainingTime:timeToGameOver playerIds:playerIds players:players];
	 }];
	
	[[Server srv] waitFightInfoWithBlock:^(int number, int timeToGameOver, int *playerIds, SDFighterInfo *players)
	 {
		 [self _handleFightInfo:number remainingTime:timeToGameOver playerIds:playerIds players:players];
	 }];
	
	[[Server srv] waitGameOverWithBlock:^(int number, int roundTimeInMins, SDPlayerScoreInfo *players)
	 {
		 [self _handleGameOverInfo:number players:players];
	 }];
	
	[[Server srv] waitDisconnectedPlayerWithBlock:^(int playerId)
	 {
		 [self _handleDisconnectedPlayer:playerId];
	 }];
	[[Server srv] waitServerDisconnectedWithBlock:^()
	 {
		 [self _handleServerDisconnectedEvent];
	 }];
}

-(void)_handleConnectedPlayers:(int)number players:(SDConnectedPlayerInfo*) players
{
	for (int i = 0; i < number; i++) {
		PlayerInfo *playerInfo = [self _playerInfoById: players[i].playerId];
		if (!playerInfo)
		{
			playerInfo = [[[PlayerInfo alloc] init] autorelease];
			playerInfo.playerId = players[i].playerId;
			playerInfo.name = [NSString stringWithUTF8String:players[i].playerName];
			playerInfo.color = i + 1; //mapping to PlayerColor enum values
			playerInfo.isLocalPlayer = players[i].playerId == localPlayerId_;
			playerInfo.time = players[i].platformTime;
			
			[playerInfos_ addObject:playerInfo];
			Jumper *jumper = [self _addJumper:players[i].playerId 
					withName:playerInfo.name 
					andColor:playerInfo.color 
				  toPosition:ccp(players[i].posX, players[i].posY)];
			
			float leftX, rightX;
			[Platform platformRangeForX:players[i].posX andY:players[i].posY leftX:&leftX rightX:&rightX];
			[jumper startWanderingFromLeftX:leftX+10 toRigthX:rightX-10];
		}else if (playerInfo.isDisconnected) {
			playerInfo.isDisconnected = NO;
			playerInfo.isPaused = NO;
			[self _detectLider];
		}
	}
}

-(void)_handleDisconnectedPlayer:(int)playerId
{
	PlayerInfo *info = [self _playerInfoById:playerId];
	if (info) {
		NSLog(@"player %@ disconnected", info.name);
		if (info.isLocalPlayer) {
			[self _handleServerDisconnectedEvent];
		}else {
			if (gameState_ == gsWaitingOthers) {
				[playerInfos_ removeObject:info];
				[self _removePlayerById:playerId];
			}else {
				info.isDisconnected = YES;
				[self _detectLider];
			}
		}
	}
}

-(void)_handleCountdownToGame:(int)timeToStart
{
	if (gameState_ == gsWaitingOthers) {
		for (Jumper *jumper in [players_ allValues]) {
			[jumper toStartPositionForMaxTime:timeToStart];
		}
		gameState_ = gsCountdownToGame;
	}
	countdownTime_ = timeToStart;
}

-(void)_handleJumpInfo:(int)number remainingTime:(int)timeToGameOver playerIds:(int*)playerIds players:(SDJumperInfo*)players
{
	if (gameState_ == gsGameOver || gameState_ == gsDisconnected)
		return;
	
	if (sceneType_ != gstJumpScene && [self _localPlayerExistsIn:playerIds number:number])
		[self _switchScene:gstJumpScene];

	for (int i = 0; i < number; i++) {		
		PlayerInfo *playerInfo = [self _playerInfoById: players[i].playerId];
		NSAssert1(playerInfo, @"playerInfo for player with id = %d can't be found", players[i].playerId);
		playerInfo.isPaused = players[i].isPaused;

		if (sceneType_ == gstJumpScene) {
			Jumper *jumper = [players_ objectForKey:[NSNumber numberWithInt:players[i].playerId]];
			if (!jumper) {
				jumper = [self _addJumper:players[i].playerId 
								 withName:playerInfo.name 
								 andColor:playerInfo.color
							   toPosition:ccp(players[i].posX, players[i].posY)];
			}
			[self _updateJumper: jumper withData:players[i]];
		}
	}
	
	if (sceneType_ == gstJumpScene) {
		gameState_ = gsJumping;	
		
		[self _findAndRemoveDisconnectedPlayers:playerIds number:number];
		
		roundRemainingTime_ = timeToGameOver;	

		[self _updatedFromServer];
	}
}

-(Jumper*)_addJumper:(int)playerId withName:(NSString*)name andColor:(PlayerColor)color toPosition:(CGPoint)pos
{	
	NSLog(@"Add jumper - %@ to position - (x=%2.1f; y=%2.1f) with color - %@", name, pos.x, pos.y, getColorFilePrefix(color) );
	Jumper *jumper = [Jumper jumperWithId:playerId name:name color:color position:pos isLocalPlayer:(playerId == localPlayerId_)];
	[players_ setObject:jumper forKey:[NSNumber numberWithInt:playerId]];
	
	return jumper;
}

-(void)_updateJumper:(Jumper*)jumper withData:(SDJumperInfo)data
{
	if (jumper.isWandering) {
		[jumper stopWandering];
	}
	
	jumper.srvDirection = data.xDirection;
	
/*	if (fabs(data.posY - jumper.posY) > 20.f)
	{
		NSLog(@"Warning! Player %@ - probably missed. srvX = %2.1f x = %2.1f srvY = %2.1f y = %2.1f dy = %2.1f",
			  jumper.playerName, data.posX, jumper.posX, data.posY, jumper.posY, data.posY - jumper.posY);
	}
	
	NSLog(@"Jumper %@ updated - x=%2.1f y=%2.1f vx=%2.1f vy=%2.1f rx=%2.1f ry=%2.1f rvx=%2.1f rvy=%2.1f dx=%2.1f dy=%2.1f dvx=%2.1f dvy=%2.1f", 
		  jumper.playerName, data.posX, data.posY, data.velX, data.velY, 
		  jumper.posX, jumper.posY, jumper.velX, jumper.velY, 
		  data.posX - jumper.posX, data.posY - jumper.posY, data.velX - jumper.velX, data.velY - jumper.velY);
	*/

	[jumper setIsFallen:data.isFallen];	
	jumper.srvPosX = data.posX;
	jumper.srvPosY = data.posY;
	jumper.velX = data.velX;
	jumper.velY = data.velY;
	jumper.accelX = data.accelX;
	jumper.accelY = data.accelY;
	jumper.srvRotation = data.rotation;
	jumper.rotationVel = data.rotationVel;
	[jumper setCollisionState:data.collisionState];
	[jumper setIsPaused:data.isPaused];	
	
	if (jumper.isLocalPlayer) {
		localPlayerPingTime_ = data.pingTime;
	}
}

-(void)_handleFightInfo:(int)number remainingTime:(int)timeToGameOver playerIds:(int*)playerIds players:(SDFighterInfo*)players
{
	if (gameState_ == gsGameOver || gameState_ == gsDisconnected)
		return;
	
	if (sceneType_ != gstFightScene && [self _localPlayerExistsIn:playerIds number:number])
		[self _switchScene:gstFightScene];
	
	for (int i = 0; i < number; i++) {		

		PlayerInfo *playerInfo = [self _playerInfoById: players[i].playerId];
		NSAssert1(playerInfo, @"playerInfo for player with id = %d can't be found", players[i].playerId);
		playerInfo.time = players[i].platformTime;
		playerInfo.isPaused = players[i].isPaused;
		[self _detectLider];
		
		if (sceneType_ == gstFightScene) {
			Fighter *fighter = [players_ objectForKey:[NSNumber numberWithInt:players[i].playerId]];
			if (!fighter) {
				fighter = [self _addFighter:players[i].playerId 
								   withName:playerInfo.name 
								   andColor:playerInfo.color 
								 toPosition:ccp(players[i].posX, CONVERT_TO_FIGHT_Y(players[i].posY))];
			}
			[self _updateFighter:fighter withData:players[i]];
		}
	}
	
	if (sceneType_ == gstFightScene) {
		gameState_ = gsFighting;	
		
		[self _findAndRemoveDisconnectedPlayers:playerIds number:number];	

		roundRemainingTime_ = timeToGameOver;	

		[self _updatedFromServer];
	}
}

-(Fighter*)_addFighter:(int)playerId withName:(NSString*)name andColor:(PlayerColor)color toPosition:(CGPoint)pos
{	
	Fighter *fighter = [Fighter fighterWithId:playerId name:name color:color position:pos];
	fighter.isLocalPlayer = (playerId == localPlayerId_);
	[players_ setObject:fighter forKey:[NSNumber numberWithInt:playerId]];

	return fighter;
}

-(void)_updateFighter:(Fighter*)fighter withData:(SDFighterInfo)data
{
	[fighter setIsHitting:data.isHitting hitResult:data.hitResult];
	[fighter setHitResult:data.hitResult hitToSide:!data.hitFromSide];
	fighter.srvPosX = data.posX;
	fighter.srvPosY = CONVERT_TO_FIGHT_Y(data.posY);
	fighter.srvDirection = data.direction;
	[fighter setIsAlone: [players_ count] == 1];
	[fighter setIsPaused:data.isPaused];

	if (fighter.isLocalPlayer) {
		localPlayerPingTime_ = data.pingTime;
	}
}

-(void)_findAndRemoveDisconnectedPlayers:(int*)playerIds number:(int)number
{
	for (NSNumber *playerId in [players_ allKeys]) {
		BOOL exist = NO;
		for (int i = 0; i < number; i++) {
			if (playerIds[i] == [playerId intValue]) {
				exist = YES;
				break;
			}
		}
		if (!exist) {
			[self _removePlayerById:[playerId intValue]];
		}
	}
}

-(void)_removePlayerById:(int)playerId
{
	NSNumber *playerNumberId = [[NSNumber alloc] initWithInt:playerId];
	[[players_ objectForKey:playerNumberId] removeFromScene];
	[players_ removeObjectForKey:playerNumberId];
	[playerNumberId release];
}

-(void)_detectLider
{
	PlayerInfo *leader = nil;
	int maxTime = 0;
	for(PlayerInfo *player in playerInfos_)
	{
		if (player.time > maxTime && !player.isDisconnected)
		{
			leader = player;
			maxTime = player.time;
		}
	}
	
	for(PlayerInfo *player in playerInfos_)
		player.isWinner = (player == leader);
}

-(void)_updatedFromServer
{
	serverUpdateDelay_ = 0.f;

	if (isConnecting_) {
		isConnecting_ = NO;
		for (Player *player in [players_ allValues]) {
			player.isFrozen = NO;
		}
	}
}

-(BOOL)_localPlayerExistsIn:(int*)playerIds number:(int)number
{
	for (int i = 0; i < number; i++) {
		if (playerIds[i] == localPlayerId_)
			return YES;
	}
	return NO;
}

-(void)_handleGameOverInfo:(int)number players:(SDPlayerScoreInfo*)players
{
	roundRemainingTime_ = 0;
	gameState_ = gsGameOver;
	
	[self _stopScene];
	[self _disconnect];
	
	PlayerInfo *winnerInfo = nil;
	PlayerInfo *localPlayerInfo;
	for (int i = 0; i < number; i++) {
		PlayerInfo *info = [self _playerInfoById: players[i].playerId];
		NSAssert(info, @"invalid playerId");
		
		info.time = players[i].score;
		info.punches = players[i].punches;
		NSLog(@"Game over info for - %@: time - %d:%02d; punches - %d", info.name, info.time/60, info.time%60, info.punches);
		if (players[i].isWinner)
			winnerInfo = info;

		if (info.isLocalPlayer)
			localPlayerInfo = info;
	}

	CCScene *scene = [GameOverScene sceneWithTime:roundTimeInMins_ andRoomCapacity:roomCapacity_ 
				andWinnerName:(winnerInfo ? winnerInfo.name : nil) 
				andWinnerColor:(winnerInfo ? winnerInfo.color : pcNone)
				andWinnerTime:(winnerInfo ? winnerInfo.time : 0)
				andWinnerPunches:(winnerInfo ? winnerInfo.punches : 0)
				andLocalPlayerTime:localPlayerInfo.time
				andLocalPlayerPunches:localPlayerInfo.punches
				localPlayerIsWinner:localPlayerInfo.isWinner];

	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:GAME_SCENE_PAGE_TURN_TIME scene:scene]];
}

-(void)_handleServerDisconnectedEvent
{	
	[self _stopScene];
	gameState_ = gsWaitDisconnection;
}

-(PlayerInfo*)_playerInfoById:(int)playerId
{
	return [playerInfos_ objectByPredicate:^(id info) { return (BOOL)([info playerId] == playerId); }];
}

-(void)dealloc
{
	[playerInfos_ release];
	[players_ release];
	[super dealloc];
}

@end
