//
//  LobbyScene.m
//  Jumper_iOS3
//
//  Created by svp on 04.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LobbyScene.h"
#import "HomeScene.h"

#import "Server.h"
#import "GameController.h"
#import "GameOptions.h"

@interface LobbyScene(Private)

-(void)_serviceUpdate;
-(void)_updateState:(int)numberOfRooms withRooms:(SDRoomInfo*)rooms andRejoinAbility:(BOOL)canRejoin;
-(void)_handleConnectionResult:(BOOL)isConnected;
-(void)_handleConnectToRoomResult:(BOOL)isConnected 
					 roomCapacity:(int)roomCapacity roomTimeInMins:(int)roomTimeInMins 
						 playerId:(int)playerId errorMessage:(NSString*)message;
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)_returnToMainMenu;
-(void)_requestState;
-(void)_selectRoom:(int)roomId withErrorMessage:(NSString*)message;
-(void)_selectRoomMenuItem : (CCMenuItem*) menuItem;
-(void)_quickStart;
-(void)_rejoin;
-(NSString*)_deviceId;

@end


@implementation LobbyScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LobbyScene *layer = [LobbyScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

#define MAIN_MESSAGE_TAG 100

-(id) init
{
	if( (self=[super init] )) {

		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"LobbyBackground.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
		
		CCMenuItem *quitIcon = [CCMenuItemImage itemFromNormalImage:@"home_button.png" 
													  selectedImage:@"home_button_pressed.png" target:self selector:@selector(_returnToMainMenu)];
		quitIcon.anchorPoint = ccp(0,0);
		CCMenu *quitButton = [CCMenu menuWithItems:quitIcon,nil];
		quitButton.position = ccp(0,0);
		[self addChild:quitButton];
		
		// add Label - Connecting...
		connectingLabel_ = [[CCLabelTTFx labelWithString:@"Connecting..." fontName:@"Marker Felt" fontSize:40] retain];
		CGSize size = [[CCDirector sharedDirector] winSize];
		connectingLabel_.position =  ccp( size.width /2 , size.height/2 );
		connectingLabel_.tag = MAIN_MESSAGE_TAG;
		[self  addChild: connectingLabel_];
		
		//Connect to server
		[[Server srv] connect:[GameOptions mainServerDomainName] withBlock:^(BOOL isConnected)
		 { 
			 [self _handleConnectionResult:isConnected];
		 }];
		
		//process incoming packets each frame
		[self schedule:@selector(_serviceUpdate)];
	}
	return self;
}

-(void)_handleConnectionResult:(BOOL)isConnected
{
//request room list
	CCLabelTTFx* connectingLabel = (CCLabelTTFx*)[self getChildByTag:MAIN_MESSAGE_TAG];
	[connectingLabel setString: isConnected ? @"Connected" : @"Failed. Please try again later."];
	if (isConnected)
	{
		[GameController createNewGame];
		//request rooms info each 5 seconds
		[self _requestState];
		[self schedule:@selector(_requestState) interval: 5];
	}
	else {
		[self schedule:@selector(_returnToMainMenu) interval: 2];
	}

}

-(void)_returnToMainMenu
{
	[self unscheduleAllSelectors];
	[self hideAd];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:GAME_SCENE_PAGE_TURN_TIME 
																					 scene:[HomeScene scene] backwards:YES]];	
}

-(void)_serviceUpdate
{
	[[Server srv] listen];
}

-(void)_requestState
{
	if (![[Server srv] isConnected]) {
		[[Server srv] reconnect];
	}
	
	[[Server srv] requestRoomListForDevice:[self _deviceId] withBlock:^(int numberOfRooms, SDRoomInfo *rooms, BOOL canRejoin)
	 {
		 [self _updateState:numberOfRooms withRooms:rooms andRejoinAbility:canRejoin];
	 }];
}

-(void)_updateState:(int)numberOfRooms withRooms:(SDRoomInfo*)rooms andRejoinAbility:(BOOL)canRejoin
{
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	[CCMenuItemFont setFontName:@"Marker Felt"];
	[CCMenuItemFont setFontSize:27];
	
	if (connectingLabel_) {
		[connectingLabel_ removeFromParentAndCleanup:YES];
		[connectingLabel_ release];
		connectingLabel_ = nil;
		
		CCMenu *startMenu = [CCMenu menuWithItems:nil];
		if (canRejoin) {
			CCMenuItem *rejoinMenuItem = [CCMenuItemFont itemFromString:@"Re-enter" target:self selector:@selector(_rejoin)];
			[startMenu addChild:rejoinMenuItem];
		}
		CCMenuItem *startMenuItem = [CCMenuItemFont itemFromString:@"Quickplay" target:self selector:@selector(_quickStart)];
		[startMenu addChild:startMenuItem];
		startMenu.position=ccp(size.width*0.5, size.height*0.23);
		[startMenu alignItemsHorizontallyWithPadding:20];
		[self addChild:startMenu];
	}
	
	NSLog(@"roomNumber", numberOfRooms);
	
	if (roomsMenu_ != nil) {
		[roomsMenu_ removeFromParentAndCleanup:YES];
		[roomsMenu_ release];
	}
	roomsMenu_ = [[CCMenu menuWithItems:nil] retain];
	roomsMenu_.position=ccp(size.width*0.5, size.height*0.55);
	for (int i = 0; i < numberOfRooms; i++) 
	{
		SDRoomInfo room = rooms[i];
		NSString *menuText = [NSString stringWithFormat:@"%d players (%@)", room.maxNumClients, 
							  room.maxNumClients > 1  ? 
							  [NSString stringWithFormat:@"%d", room.currentNumClients] : @"practice" ];
		NSLog(@"menuItemText = %@", menuText);
		CCMenuItem *menuItem = [CCMenuItemFont itemFromString: menuText target:self selector:@selector(_selectRoomMenuItem:)];
		menuItem.tag = room.roomId;
		[roomsMenu_ addChild: menuItem];
	}
	[roomsMenu_ alignItemsVerticallyWithPadding:10];
	[self addChild:roomsMenu_];
}

-(void)_quickStart
{
	[self _selectRoom: -1 withErrorMessage:@"Sorry, this room has already been filled. Select please another one."];
}

-(void)_rejoin
{
	[self _selectRoom: -2 withErrorMessage:@"Sorry, this room is no longer available."];
}

-(void)_selectRoomMenuItem:(CCMenuItem*)menuItem
{
	[self _selectRoom: menuItem.tag withErrorMessage:@"Unknown error."];
}

-(void)_selectRoom:(int)roomId withErrorMessage:(NSString*)message
{
	[[Server srv] connectToRoom:roomId 
					  forDevice:[self _deviceId] withPlayerName:[GameOptions localPlayerName] 
					  withBlock:^(BOOL isConnected, int roomCapacity, int roomTimeInMins, int playerId)
	 {
		 [self _handleConnectToRoomResult:isConnected roomCapacity:roomCapacity roomTimeInMins:roomTimeInMins playerId:playerId errorMessage:message];
	 }];
}

-(void)_handleConnectToRoomResult:(BOOL)isConnected roomCapacity:(int)roomCapacity 
				   roomTimeInMins:(int)roomTimeInMins playerId:(int)playerId
				errorMessage:(NSString*)message
{
	if (isConnected)
	{
		[self unscheduleAllSelectors];
		[self hideAd];
		[[GameController game] startWithPlayerId:playerId numberOfPlayers:roomCapacity andGameTimeInMins:roomTimeInMins];
	}else
	{
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@""
				message:message delegate:self cancelButtonTitle:@"Refresh" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self _requestState];
}

-(NSString*)_deviceId
{
	UIDevice *device = [UIDevice currentDevice];
	return [device uniqueIdentifier];
}

-(void)dealloc
{
	[connectingLabel_ release];
	[roomsMenu_ release];
	[super dealloc];
}

#pragma mark SceneWithAd overrides

-(NSString*)getZone {
	return @"0557947379042204545";
}

-(CGPoint)getAnchorPoint
{
	return CGPointMake(0.54, 0);
}

@end
