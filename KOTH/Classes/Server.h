//
//  Server.h
//  KOTH
//
//  Created by Denis Davydenko on 10/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_NUMBER_OF_ROOMS 8
#define MAX_NUMBER_OF_PLAYERS 5
#define PLAYER_NAME_MAX_LENGTH 50

//SD - Server Data
typedef struct {
	int roomId;
	int maxNumClients;
	int currentNumClients;
	int time; //in seconds	
} SDRoomInfo;

typedef struct {
	int playerId;
	char playerName[PLAYER_NAME_MAX_LENGTH+1];
	float posX;
	float posY;
	int platformTime;
} SDConnectedPlayerInfo;

typedef struct {
	int playerId;
	int xDirection; //0 - left; 1 - right
	float posX;
	float posY;
	float velX;
	float velY;
	float accelX;
	float accelY;
	float rotation;
	float rotationVel;	
	int isFallen;
	int collisionState;
	int pingTime;
	int isPaused;
} SDJumperInfo;

typedef struct {
	int playerId;
	float posX;
	float posY;
	int direction;
	int isHitting;
	int hitResult;
	int hitFromSide; //1 - to the left; 0 - to the right
	int platformTime;
	int pingTime;
	int isPaused;
} SDFighterInfo;

typedef struct {
	int playerId;
	char playerName[PLAYER_NAME_MAX_LENGTH+1];
	int score;
	int punches;
	int isWinner;	
} SDPlayerScoreInfo;

typedef void(^ServerConnectedBlock)(BOOL isConnected);
typedef void(^RoomsInfoBlock)(int numberOfRooms, SDRoomInfo *rooms, BOOL canRejoin);
typedef void(^RoomConnectedBlock)(BOOL isConnected, int roomCapacity, int roundTimeInMins, int clientId);
typedef void(^ConnectedPlayersBlock)(int roomCapacity, int numberOfPlayers, SDConnectedPlayerInfo *players);
typedef void(^CountdownToGameBlock)(int timeToGameStart);
typedef void(^JumpInfoBlock)(int numberOfPlayers, int timeToGameOver, int *playerIds, SDJumperInfo *jumpers);
typedef void(^FightInfoBlock)(int numberOfPlayers, int timeToGameOver, int *playerIds, SDFighterInfo *fighters);
typedef void(^GameOverBlock)(int numberOfPlayers, int roundTimeInMins, SDPlayerScoreInfo *players);
typedef void(^PlayerDisconnectedBlock)(int playerId);
typedef void(^ServerDisconnectedBlock)();

@interface Server : NSObject {

@private
	
	NSString *serverIp_;
	NSDate *ipExpirationTime_;
	
	ServerConnectedBlock serverConnectedBlock_;
	RoomsInfoBlock roomsInfoBlock_;
	RoomConnectedBlock roomConnectedBlock_;
	ConnectedPlayersBlock connectedPlayersBlock_;
	CountdownToGameBlock countdownToGameBlock_;
	JumpInfoBlock jumpInfoBlock_;
	FightInfoBlock fightInfoBlock_;
	GameOverBlock gameOverBlock_;
	PlayerDisconnectedBlock playerDisconnectedBlock_;
	ServerDisconnectedBlock serverDisconnectedBlock_;
}

+(Server*)srv;

-(void)connect: (NSString*)geoServerDomainName withBlock:(ServerConnectedBlock)block;
-(void)disconnect;
-(void)reconnect;
-(BOOL)isConnected;

-(void)listen;
-(void)requestRoomListForDevice:(NSString*)deviceId withBlock:(RoomsInfoBlock)block;
-(void)connectToRoom:(int)roomId forDevice:(NSString*)deviceId withPlayerName:(NSString*)playerName withBlock:(RoomConnectedBlock)block;
-(void)waitConnectedPlayersWithBlock:(ConnectedPlayersBlock)block;
-(void)waitCountdownToGameWithBlock:(CountdownToGameBlock)block;
-(void)sendJumpControls:(float)accelX;
-(void)waitJumpInfoWithBlock:(JumpInfoBlock)block;
-(void)sendFightControls:(BOOL)toLeft andRight:(BOOL)toRight andHit:(BOOL)hit;
-(void)waitFightInfoWithBlock:(FightInfoBlock)block;
-(void)waitGameOverWithBlock:(GameOverBlock)block;
-(void)waitDisconnectedPlayerWithBlock:(PlayerDisconnectedBlock)block;
-(void)waitServerDisconnectedWithBlock:(ServerDisconnectedBlock)block;
-(void)sendPause:(BOOL)isPause;


@end