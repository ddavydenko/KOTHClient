//
//  GameScene.m
//  KOTH
//
//  Created by Denis Davydenko on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "Server.h"

@interface GameScene(Private)

-(void)_requestGameState;
-(void)_checkNewPlayers;
-(void)_updateBoard;

@end


@implementation GameScene

-(id)init
{
	if( (self=[super init] )) {

		[self addGameLayouts];
		
		[self schedule:@selector(_requestGameState)];
		[self schedule:@selector(_checkNewPlayers)];		
		[self schedule:@selector(_update:)];
	}
	return self;
}

-(GameSceneType)sceneType
{
	return gstNone;
}

-(void)addGameLayouts
{
	board_ = [[EnvironmentLayer node] retain];
	[self addChild:board_ z:1000];
}


-(void)_requestGameState
{
	[[Server srv] listen];
}

-(void)_checkNewPlayers
{
	[[GameController game] addNewPlayersToScene:self withType:[self sceneType]];
}

-(void)_update:(ccTime)dt
{
	[[GameController game] update:dt];
	
	[board_ update:[[GameController game] playerInfos] isConnecting:[GameController game].isConnecting];
	[board_ setRoundRemainingTime: [GameController game].roundRemainingTime];
	[board_ setGameMessage: [GameController game].gameState == gsCountdownToGame ?  
	 [NSString stringWithFormat:@"%d", [GameController game].countdownTime] : @"" ];
	[board_ setPlayerPingTime:[GameController game].localPlayerPingTime];
}

-(void)dealloc
{
	[board_ release];
	[super dealloc];
}

@end
