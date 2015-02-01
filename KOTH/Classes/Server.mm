//
//  Server.m
//  KOTH
//
//  Created by Denis Davydenko on 10/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Server.h"
#import "Tools.h"
#import "SimpleHttpClient.h"

#include "RakNetworkFactory.h"
#include "RakPeerInterface.h"
#include "RakNetStatistics.h"
#include "RakNetTypes.h"
#include "BitStream.h"
#include "RakSleep.h"
#include "RakString.h"
#include "MessageIdentifiers.h"

#define SERVER_PORT 60200
#define CONNECTION_PASSWORD "Rumpelstiltskin"
#define DEFAULT_SERVER_IP @"184.72.49.164"

enum ClientPacketType {
	cptRoomsInfo = 101, 
	cptConnectToRoom = 102,
	cptJumpControls = 99,
	cptFightControls = 44,
	cptPause = 107,
};

enum ServerPacketType {
	sptConnectToRoom = 102,
	sptCountdownToGame = 105,
	sptWaitingPlayers = 103,
	sptRoomsInfo = 101,
	sptJumpInfo = 88,
	sptFightInfo = 44,
	sptGameOver = 104,
	sptPlayerDesconnected = 106,
};

@interface Server(Private)

-(unsigned char) _getPacketIdentifier:(Packet*)p;
-(void) _processCustomPacket:(Packet*)p;
-(void)_processWaitingPlayersPacket:(RakNet::BitStream&)inStream;
-(void)_copyPlayerName:(char*)dest source:(const char*)source;
-(void)_processJumpInfoPacket:(RakNet::BitStream&)inStream;
-(void)_processFightInfoPacket:(RakNet::BitStream&)inStream;
-(void)_processRoomsInfoPacket:(RakNet::BitStream&)inStream;
-(void)_processGameOverPacket:(RakNet::BitStream&)inStream;
-(void)_processConnectedToRoomPacket:(RakNet::BitStream&)inStream;

-(void)_setServerConnectedBlock:(ServerConnectedBlock)block;
-(void)_setRoomsInfoBlock:(RoomsInfoBlock)block;
-(void)_setRoomConnectedBlock:(RoomConnectedBlock)block;
-(void)_setConnectedPlayersBlock:(ConnectedPlayersBlock)block;
-(void)_setCountdownToGameBlock:(CountdownToGameBlock)block;
-(void)_setJumpInfoBlock:(JumpInfoBlock)block;
-(void)_setFightInfoBlock:(FightInfoBlock)block;
-(void)_setGameOverBlock:(GameOverBlock)block;
-(void)_setPlayerDisconnectedBlock:(PlayerDisconnectedBlock)block;
-(void)_setServerDisconnectedBlock:(ServerDisconnectedBlock)block;

-(void)_obtainServerIpFromGeoServer:(NSString*)geoServerDomainName withBlock:(VoidBlock)block;
-(void)_connectToServer;

@end


@implementation Server

static RakPeerInterface *rakClient_ = 0;

static Server *instance_ = nil;

+(Server*) srv
{
	@synchronized(self)
	{
		if (!instance_)
			instance_ = [[Server alloc] init];
	}
	return instance_;
}

-(void)connect: (NSString*)geoServerDomainName withBlock:(ServerConnectedBlock)block
{
	NSAssert(geoServerDomainName, @"Geo server domain name is undefined");
	
	[self _setServerConnectedBlock:block];
	
	[self _obtainServerIpFromGeoServer:geoServerDomainName withBlock:^ {
		[self _connectToServer];
	}];
}

-(void)disconnect
{
	if ([self isConnected])
	{
		rakClient_->Shutdown(100);
		RakNetworkFactory::DestroyRakPeerInterface(rakClient_);
		rakClient_ = 0;
		
		if (connectedPlayersBlock_) 
			[self _setConnectedPlayersBlock:nil];
		if (countdownToGameBlock_) 
			[self _setCountdownToGameBlock:nil];
		if (fightInfoBlock_) 
			[self _setFightInfoBlock:nil];
		if (jumpInfoBlock_) 
			[self _setJumpInfoBlock:nil];
		
	}
}

-(void)reconnect
{
	if ([self isConnected]) {
		[self disconnect];
	}
	[self connect:serverIp_ withBlock:nil];
}

-(BOOL)isConnected
{
	return rakClient_ && rakClient_->IsActive();
}

-(void)requestRoomListForDevice:(NSString*)deviceId withBlock:(RoomsInfoBlock)block;
{
	[self _setRoomsInfoBlock:block];
	
	RakNet::BitStream outStream;
	outStream.Write((unsigned char)cptRoomsInfo);
	outStream.Write([deviceId UTF8String]);
	rakClient_->Send(&outStream, HIGH_PRIORITY, RELIABLE_ORDERED, 0, UNASSIGNED_SYSTEM_ADDRESS, true);
}

-(void)connectToRoom:(int)roomId forDevice:(NSString*)deviceId withPlayerName:(NSString*)playerName withBlock:(RoomConnectedBlock)block
{
	[self _setRoomConnectedBlock:block];
	
	RakNet::BitStream outStream;
	outStream.Write((unsigned char)cptConnectToRoom);
	outStream.Write([deviceId UTF8String]);
	outStream.Write(roomId);
	outStream.Write([playerName UTF8String]);

	rakClient_->Send(&outStream, HIGH_PRIORITY, RELIABLE_ORDERED, 0, UNASSIGNED_SYSTEM_ADDRESS, true);
}

-(void)waitConnectedPlayersWithBlock:(ConnectedPlayersBlock)block
{
	[self _setConnectedPlayersBlock:block];
}

-(void)waitCountdownToGameWithBlock:(CountdownToGameBlock)block
{
	[self _setCountdownToGameBlock:block];
}

-(void)sendJumpControls:(float)accelX
{
	if (![self isConnected])
		return;

	RakNet::BitStream outStream;
	outStream.Write((unsigned char)cptJumpControls);
	outStream.Write(accelX);
	rakClient_->Send(&outStream, HIGH_PRIORITY, RELIABLE_ORDERED, 0, UNASSIGNED_SYSTEM_ADDRESS, true);
}

-(void)waitJumpInfoWithBlock:(JumpInfoBlock)block
{
	[self _setJumpInfoBlock:block];
}

-(void)sendFightControls:(BOOL)toLeft andRight:(BOOL)toRight andHit:(BOOL)hit
{
	if (![self isConnected])
		return;

	RakNet::BitStream outStream;
	outStream.Write((unsigned char)cptFightControls);
	outStream.Write((int)toLeft);
	outStream.Write((int)toRight);
	outStream.Write((int)hit);
	rakClient_->Send(&outStream, HIGH_PRIORITY, RELIABLE_ORDERED, 0, UNASSIGNED_SYSTEM_ADDRESS, true);
}

-(void)waitFightInfoWithBlock:(FightInfoBlock)block
{
	[self _setFightInfoBlock:block];
}

-(void)waitGameOverWithBlock:(GameOverBlock)block
{
	[self _setGameOverBlock:block];
}

-(void)waitDisconnectedPlayerWithBlock:(PlayerDisconnectedBlock)block
{
	[self _setPlayerDisconnectedBlock:block];
}

-(void)waitServerDisconnectedWithBlock:(ServerDisconnectedBlock)block
{
	[self _setServerDisconnectedBlock:block];
}

-(void)sendPause:(BOOL)isPause
{
	if (![self isConnected])
		return;

	RakNet::BitStream outStream;
	
	outStream.Write((unsigned char)cptPause);
	outStream.Write((int)isPause);
	
	rakClient_->Send(&outStream, HIGH_PRIORITY, RELIABLE_ORDERED, 0, UNASSIGNED_SYSTEM_ADDRESS, true);
	
	NSLog(isPause ? @"send pause" : @"send resume");
}

-(void)listen
{
	if (!rakClient_)
		return;

	for (Packet *p=rakClient_->Receive(); p; rakClient_->DeallocatePacket(p), p=rakClient_->Receive())
	{
		unsigned char packetIdentifier = [self _getPacketIdentifier:p];
		
		switch (packetIdentifier)
		{
			case ID_CONNECTION_REQUEST_ACCEPTED:
				NSLog(@"Connected to server");
				if (serverConnectedBlock_)
				{
					serverConnectedBlock_(YES);
					[self _setServerConnectedBlock:nil];
				}
				break;
				
			case ID_CONNECTION_ATTEMPT_FAILED:
				NSLog(@"Connection failed");
				if (serverConnectedBlock_) 
				{
					serverConnectedBlock_(NO);
					[self _setServerConnectedBlock:nil];
				}
				break;
				
				
			case ID_DISCONNECTION_NOTIFICATION:
				[self disconnect];
				if (serverDisconnectedBlock_) {
					serverDisconnectedBlock_();
				}
				return;
				
			case ID_NEW_INCOMING_CONNECTION:
				// Somebody connected.  We have their IP now
				NSLog(@"ID_NEW_INCOMING_CONNECTION");
				break;
				
			case ID_INCOMPATIBLE_PROTOCOL_VERSION:
				NSLog(@"ID_INCOMPATIBLE_PROTOCOL_VERSION");
				break;
				
			case ID_MODIFIED_PACKET:
				// Cheater!
				//printf("ID_MODIFIED_PACKET\n");
				break;
				
			case ID_REMOTE_CONNECTION_LOST:
				[self disconnect];
				if (serverDisconnectedBlock_) {
					serverDisconnectedBlock_();
				}
				return;
				
			case ID_CONNECTION_LOST:
				[self disconnect];
				if (serverDisconnectedBlock_) {
					serverDisconnectedBlock_();
				}
				return;
			default:
				[self _processCustomPacket: p];

				break;
		}
		
		if (![self isConnected])
			return;
	}
}

-(void)_obtainServerIpFromGeoServer:(NSString*)geoServerDomainName withBlock:(VoidBlock)block
{
	if (ipExpirationTime_ != nil && serverIp_ != nil &&
		[[NSDate date] compare:ipExpirationTime_] == NSOrderedAscending)
	{
		NSLog(@"Use stored server ip = %@", serverIp_);
		block();
		return;
	}
	
	NSString *url = [NSString stringWithFormat:@"http://%@/ServerByIp.ashx", geoServerDomainName];
	[SimpleHttpClient requestUrl:url 
					   withBlock:^(NSString *response) {
						   NSLog(@"Server Ip is obtained = %@", response);
						   serverIp_ = [response retain];
						   ipExpirationTime_ = [[NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval)1*60*60] retain]; //1 hour
						   block();
					   }
				   andErrorBlock:^(NSError *error) {
					   NSLog(@"Error when trying to obtain Server Ip - %@. Use default server ip - %@", error, DEFAULT_SERVER_IP);
					   serverIp_ = DEFAULT_SERVER_IP; 
					   block();
				   }];
}

-(void)_connectToServer
{
	rakClient_ = RakNetworkFactory::GetRakPeerInterface();
	SocketDescriptor socketDescriptor(0, 0);
	rakClient_->Startup(8, 10, &socketDescriptor, 1);
	rakClient_->SetOccasionalPing(true);
	rakClient_->SetTimeoutTime(10000,UNASSIGNED_SYSTEM_ADDRESS);
	BOOL isConnected = rakClient_->Connect([serverIp_ UTF8String], SERVER_PORT, CONNECTION_PASSWORD, strlen(CONNECTION_PASSWORD));	
	
	if (isConnected)
		NSLog(@"Attempting connection");
	else
	{
		NSLog(@"Bad connection attempt.  Terminating.");
		serverConnectedBlock_(false);
	}
	
	NSLog(@"My IP is %s", rakClient_->GetLocalIP(0));
	NSLog(@"My GUID is %s", rakClient_->GetGuidFromSystemAddress(UNASSIGNED_SYSTEM_ADDRESS).ToString());	
}

-(unsigned char) _getPacketIdentifier: (Packet*) p
{
	if (p==0)
		return 255;
	
	if ((unsigned char)p->data[0] == ID_TIMESTAMP)
	{
		assert(p->length > sizeof(unsigned char) + sizeof(unsigned long));
		return (unsigned char) p->data[sizeof(unsigned char) + sizeof(unsigned long)];
	}
	else
		return (unsigned char) p->data[0];
}

-(void) _processCustomPacket:(Packet*)p
{
	RakNet::BitStream inStream(p->data, p->length, false); 
	unsigned char pkgID;

	inStream.Read(pkgID);
	//NSLog(@"A packet with type = %d has been received", pkgID);
	switch (pkgID){
		case sptRoomsInfo:
			[self _processRoomsInfoPacket:inStream];
			break;
			
		case sptConnectToRoom:
			if (roomsInfoBlock_)
				[self _setRoomsInfoBlock:nil];

			[self _processConnectedToRoomPacket:inStream];
			break;
			
		case sptWaitingPlayers:
			[self _processWaitingPlayersPacket:inStream];
			break;
			
		case sptCountdownToGame:
			int countDownTime;
			inStream.Read(countDownTime); 
			if (countdownToGameBlock_) 
				countdownToGameBlock_(countDownTime);
			break;

		case sptJumpInfo:
			
			[self _processJumpInfoPacket:inStream];
			break;

		case sptFightInfo:
			[self _processFightInfoPacket:inStream];
			break;
			
		case sptGameOver:
			if (playerDisconnectedBlock_) {
				[self _setPlayerDisconnectedBlock:nil];
			}
			
			[self _processGameOverPacket:inStream];
			break;
			
		case sptPlayerDesconnected:
			int playerId;
			
			inStream.Read(playerId);
			
			if (playerDisconnectedBlock_) {
				playerDisconnectedBlock_(playerId);
			}
		break;
		
	}
			
}

-(void)_copyPlayerName:(char*)dest source:(const char*)source
{
	if(strlen(source) > PLAYER_NAME_MAX_LENGTH)
	{
		memcpy(dest, source, PLAYER_NAME_MAX_LENGTH);
		dest[PLAYER_NAME_MAX_LENGTH] = 0;
	}else 
	{		
		strcpy(dest, source);
	}
}

-(void)_processRoomsInfoPacket:(RakNet::BitStream&)inStream
{
	int numberOfRooms;
	SDRoomInfo rooms[MAX_NUMBER_OF_ROOMS];

	inStream.Read(numberOfRooms);
	NSAssert(numberOfRooms < MAX_NUMBER_OF_ROOMS, @"max number of rooms is exceeded");

	for (int i=0; i<numberOfRooms; i++) {
		inStream.Read(rooms[i].roomId);
		inStream.Read(rooms[i].maxNumClients);
		inStream.Read(rooms[i].time);
		inStream.Read(rooms[i].currentNumClients);
	}
	
	int canRejoin;
	inStream.Read(canRejoin);
	NSLog(@"can rejoin = %d", canRejoin);
	
	if (roomsInfoBlock_)
		roomsInfoBlock_(numberOfRooms, rooms, canRejoin);

}

-(void)_processConnectedToRoomPacket:(RakNet::BitStream&)inStream
{
	int resultCode;
	int roomCapacity;
	int roundTime;
	int clientId;
	inStream.Read(resultCode);
	inStream.Read(roomCapacity);
	inStream.Read(roundTime);
	inStream.Read(clientId);
	
	if (roomConnectedBlock_)
	{
		roomConnectedBlock_(resultCode, roomCapacity, roundTime/60, clientId);
		[self _setRoomConnectedBlock:nil];
	}
	
}

-(void)_processWaitingPlayersPacket:(RakNet::BitStream&)inStream
{
	int roomCapacity;
	int numberOfPlayers;
	RakNet::RakString playerName;
	SDConnectedPlayerInfo players[MAX_NUMBER_OF_PLAYERS];
		
	inStream.Read(roomCapacity);
	inStream.Read(numberOfPlayers);
	NSAssert(numberOfPlayers < MAX_NUMBER_OF_PLAYERS, @"max number of players is exceeded");

	for(int i=0; i<numberOfPlayers; i++){
		inStream.Read(players[i].playerId);
		inStream.Read(playerName);
		[self _copyPlayerName: players[i].playerName source:playerName];
		inStream.Read(players[i].posX);
		inStream.Read(players[i].posY);
		inStream.Read(players[i].platformTime);
	}
	
	if (connectedPlayersBlock_) 
		connectedPlayersBlock_(roomCapacity, numberOfPlayers, players);
}

-(void)_processJumpInfoPacket:(RakNet::BitStream&)inStream
{
	int numberOfPlayers;
	int timeToGameOver;
	SDJumperInfo jumpers[MAX_NUMBER_OF_PLAYERS];
	int playerIds[MAX_NUMBER_OF_PLAYERS];

	inStream.Read(numberOfPlayers);
	NSAssert(numberOfPlayers < MAX_NUMBER_OF_PLAYERS, @"max number of players is exceeded");
	
	inStream.Read(timeToGameOver);

	for(int i=0; i < numberOfPlayers; i++) {
		inStream.Read(jumpers[i].playerId);
		inStream.Read(jumpers[i].xDirection);
		inStream.Read(jumpers[i].posX);
		inStream.Read(jumpers[i].posY);
		inStream.Read(jumpers[i].velX);
		inStream.Read(jumpers[i].velY);
		inStream.Read(jumpers[i].accelX);
		inStream.Read(jumpers[i].accelY);
		inStream.Read(jumpers[i].rotation);
		inStream.Read(jumpers[i].rotationVel);
		inStream.Read(jumpers[i].isFallen);
		inStream.Read(jumpers[i].collisionState);
		inStream.Read(jumpers[i].pingTime);
		inStream.Read(jumpers[i].isPaused);
		
		playerIds[i] = jumpers[i].playerId;
	}
	
	if (jumpInfoBlock_) 
		jumpInfoBlock_(numberOfPlayers, timeToGameOver, playerIds, jumpers);
}

-(void)_processFightInfoPacket:(RakNet::BitStream&)inStream
{
	int numberOfPlayers;
	int timeToGameOver;
	SDFighterInfo fighters[MAX_NUMBER_OF_PLAYERS];
	int playerIds[MAX_NUMBER_OF_PLAYERS];

	inStream.Read(numberOfPlayers);
	NSAssert(numberOfPlayers < MAX_NUMBER_OF_PLAYERS, @"max number of players is exceeded");
	
	inStream.Read(timeToGameOver);
	
	for(int i=0; i < numberOfPlayers; i++) {
		inStream.Read(fighters[i].playerId);
		inStream.Read(fighters[i].posX);
		inStream.Read(fighters[i].posY);
		inStream.Read(fighters[i].isHitting);
		inStream.Read(fighters[i].hitResult);
		inStream.Read(fighters[i].direction);
		inStream.Read(fighters[i].hitFromSide);
		inStream.Read(fighters[i].platformTime);
		inStream.Read(fighters[i].pingTime);
		inStream.Read(fighters[i].isPaused);
		
		playerIds[i] = fighters[i].playerId;
	}
	
	if (fightInfoBlock_) 
		fightInfoBlock_(numberOfPlayers, timeToGameOver, playerIds, fighters);
}	

-(void)_processGameOverPacket:(RakNet::BitStream&)inStream
{
	int numberOfPlayers;
	int roundTime;
	RakNet::RakString playerName;
	SDPlayerScoreInfo players[MAX_NUMBER_OF_PLAYERS];
	
	inStream.Read(numberOfPlayers);
	NSAssert(numberOfPlayers < MAX_NUMBER_OF_PLAYERS, @"max number of players is exceeded");
	
	inStream.Read(roundTime);
	
	for (int i = 0; i < numberOfPlayers; i++) {
		inStream.Read(players[i].playerId);
		inStream.Read(playerName);
		[self _copyPlayerName: players[i].playerName source:playerName];
		inStream.Read(players[i].score);
		inStream.Read(players[i].punches);
		inStream.Read(players[i].isWinner);
	}

	if (gameOverBlock_) 
		gameOverBlock_(numberOfPlayers, roundTime/60, players);
}

-(void)_setServerConnectedBlock:(ServerConnectedBlock)block
{
	_Block_release(serverConnectedBlock_);
	serverConnectedBlock_ = (ServerConnectedBlock)_Block_copy(block);
}
-(void)_setRoomsInfoBlock:(RoomsInfoBlock)block
{
	_Block_release(roomsInfoBlock_);
	roomsInfoBlock_ = (RoomsInfoBlock)_Block_copy(block);
}
-(void)_setRoomConnectedBlock:(RoomConnectedBlock)block
{
	_Block_release(roomConnectedBlock_);
	roomConnectedBlock_ = (RoomConnectedBlock)_Block_copy(block);
}
-(void)_setConnectedPlayersBlock:(ConnectedPlayersBlock)block
{
	_Block_release(connectedPlayersBlock_);
	connectedPlayersBlock_ = (ConnectedPlayersBlock)_Block_copy(block);
}
-(void)_setCountdownToGameBlock:(CountdownToGameBlock)block
{
	_Block_release(countdownToGameBlock_);
	countdownToGameBlock_ = (CountdownToGameBlock)_Block_copy(block);
}
-(void)_setJumpInfoBlock:(JumpInfoBlock)block
{
	_Block_release(jumpInfoBlock_);
	jumpInfoBlock_ = (JumpInfoBlock)_Block_copy(block);
}
-(void)_setFightInfoBlock:(FightInfoBlock)block
{
	_Block_release(fightInfoBlock_);
	fightInfoBlock_ = (FightInfoBlock)_Block_copy(block);
}
-(void)_setGameOverBlock:(GameOverBlock)block
{
	_Block_release(gameOverBlock_);
	gameOverBlock_ = (GameOverBlock)_Block_copy(block);
}
-(void)_setPlayerDisconnectedBlock:(PlayerDisconnectedBlock)block
{
	_Block_release(playerDisconnectedBlock_);
	playerDisconnectedBlock_ = (PlayerDisconnectedBlock)_Block_copy(block);
}
-(void)_setServerDisconnectedBlock:(ServerDisconnectedBlock)block
{
	_Block_release(serverDisconnectedBlock_);
	serverDisconnectedBlock_ = (ServerDisconnectedBlock)_Block_copy(block);
}
-(void)dealloc
{
	_Block_release(serverConnectedBlock_);
	_Block_release(roomsInfoBlock_);
	_Block_release(roomConnectedBlock_);
	_Block_release(connectedPlayersBlock_);
	_Block_release(countdownToGameBlock_);
	_Block_release(jumpInfoBlock_);
	_Block_release(fightInfoBlock_);
	_Block_release(gameOverBlock_);
	_Block_release(playerDisconnectedBlock_);
	_Block_release(serverDisconnectedBlock_);
	[serverIp_ release];
	[super dealloc];
}

@end
