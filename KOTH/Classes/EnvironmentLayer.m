//
//  BoardLayer.m
//  KOTH
//
//  Created by Denis Davydenko on 11/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EnvironmentLayer.h"
#import "PlayerColor.h"
#import "NSArrayEx.h"
#import "Tools.h"
#import "GameOptions.h"

#define FACE_TAG 1
#define WINNER_FACE_TAG 2

@implementation BoardPlayerInfo

@synthesize nameLabel = nameLabel_;
@synthesize timeLabel = timeLabel_;
@synthesize faceSprite = faceSprite_;

-(id)initWithPlayerInfo:(PlayerInfo*)info
{
	if ((self = [super init])) {
		playerInfo_ = [info copy];
	
		CCSprite *face = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_face.png", getColorFilePrefix(info.color)]];
		CCSprite *winner_face = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_winner_face.png", getColorFilePrefix(info.color)]];
		faceSprite_ = [[CCMultiSprite node] retain];
		[faceSprite_ addChild:face tag:FACE_TAG];
		[faceSprite_ addChild:winner_face tag:WINNER_FACE_TAG];
		faceSprite_.currentSpriteTag = info.isWinner ? WINNER_FACE_TAG : FACE_TAG;
		faceSprite_.position = ccp(0, 0);
		[self addChild:faceSprite_];
		
		disconnectedIcon_ = [[CCSprite spriteWithFile:@"disconnect_icon.png"] retain];
		disconnectedIcon_.position = ccp(8, -4);
		disconnectedIcon_.visible = NO;
		[self addChild:disconnectedIcon_];
		
		NSString *truncatedName = [info.name truncatedStringToWidth:45 withFont:[UIFont fontWithName:@"Arial" size:12]];
		nameLabel_ = [[CCLabelTTFx labelWithString:truncatedName fontName:@"Arial" fontSize:12] retain];
		nameLabel_.color = ccBLACK;
		nameLabel_.position = ccp(0, 0 - [face contentSize].height/2 - 7);
		[self addChild:nameLabel_];

		timeLabel_ = [[CCLabelTTFx labelWithString:@"" fontName:@"Arial" fontSize:12] retain];
		timeLabel_.color = ccBLACK;
		timeLabel_.position = ccp(0, 0 - [face contentSize].height/2 - 19);
		[self addChild:timeLabel_];
	}
	return self;
}

-(void)updateWithPlayerInfo:(PlayerInfo*)info
{
	playerInfo_.time = !info.isDisconnected ? info.time : 0;
	NSString *timeText = (playerInfo_.time > 0) ? 
				[NSString stringWithFormat:@"%d:%02d", playerInfo_.time/60, playerInfo_.time%60] : 
				@"";
	[timeLabel_ setString:timeText];
	
	if (info.isWinner != playerInfo_.isWinner) {
		faceSprite_.currentSpriteTag = info.isWinner ? WINNER_FACE_TAG : FACE_TAG;
		playerInfo_.isWinner = info.isWinner;
	}
	
	disconnectedIcon_.visible = info.isPaused || info.isDisconnected;
	playerInfo_.isPaused = info.isPaused;
	playerInfo_.isDisconnected = info.isDisconnected;
}

-(BOOL)disconnectedIconVisible
{
	return disconnectedIcon_.visible;
}

-(void) setDisconnectedIconVisible:(BOOL)isVisible
{
	disconnectedIcon_.visible = isVisible;
}

-(int) playerId
{
	return playerInfo_.playerId;
}

-(BOOL) isLocalPlayer
{
	return playerInfo_.isLocalPlayer;
}

-(void)dealloc
{
	[faceSprite_ release];
	[timeLabel_ release];
	[nameLabel_ release];
	[playerInfo_ release];
	[disconnectedIcon_ release];
	[super dealloc];
}

@end


@interface EnvironmentLayer(Private)

-(BoardPlayerInfo*)_createNewBoardInfo:(PlayerInfo*)info;
-(void)_askQuit:(id)sender;
-(void)_checkDisconnection;

@end


@implementation EnvironmentLayer

-(id)init
{
	if ((self = [super init])) {
		playerInfos_ = [[NSMutableArray array] retain];
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		roundRemainingTimeLabel_ = [[CCLabelTTFx labelWithString:@"" fontName:@"Arial" fontSize:22] retain]; 
		roundRemainingTimeLabel_.color = ccBLACK;
		roundRemainingTimeLabel_.position = ccp(winSize.width - 35, winSize.height - 20);
		[self addChild:roundRemainingTimeLabel_];		
		[roundRemainingTimeLabel_ setShadowWithColor:ccBLACK andOpacity:80 andOffset:CGSizeMake(2, -2)];
		
		gameMessageLabel_ = [[CCLabelTTFx labelWithString:@"" fontName:@"Marker Felt" fontSize:55] retain];
		gameMessageLabel_.color = ccWHITE;
		gameMessageLabel_.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:gameMessageLabel_];
		[gameMessageLabel_ setShadowWithColor:ccBLACK andOpacity:150 andOffset:CGSizeMake(1, -1)];
		
		playerPingLabel_ = [[CCLabelTTFx labelWithString:@"ping: 0" fontName:@"Arial" fontSize:13] retain];
		playerPingLabel_.position=ccp(winSize.width - 95, 10);
		playerPingLabel_.color=ccc3(0,0,0);
		if ([GameOptions pingEnabled])
			[self addChild:playerPingLabel_];
		
		gameConnectingLabel_ = [[CCLabelTTFx labelWithString:@"Connecting..." fontName:@"Arial" fontSize:14] retain];
		gameConnectingLabel_.position=ccp(10, winSize.height - 62);
		gameConnectingLabel_.color=ccc3(0,0,0);
		gameConnectingLabel_.visible = NO;
		gameConnectingLabel_.anchorPoint = ccp(0, 0.5);
		[self addChild:gameConnectingLabel_];
				
		CCMenuItem *quitIcon = [CCMenuItemImage itemFromNormalImage:@"home_button.png" 
													  selectedImage:@"home_button_pressed.png" target:self selector:@selector(_askQuit)];
		quitIcon.anchorPoint = ccp(0,0);
		CCMenu *quitButton = [CCMenu menuWithItems:quitIcon,nil];
		quitButton.position = ccp(0,0);
		[self addChild:quitButton];

		[self schedule:@selector(_checkDisconnection)];
		
		alertIsOpen_ = NO;
	}
	
	return self;
}

-(void)update:(NSMutableArray*)playerInfos isConnecting:(BOOL)isConnecting
{ 
	[playerInfos_ syncronizeWithArray:playerInfos 
					withCompareBlock:^(id dest, id source) { return (BOOL)([dest playerId] == [source playerId]); } 
					onAddBlock:^(id source) { return (id)[self _createNewBoardInfo: source]; } 
					onUpdateBlock:^(id dest, id source) { [dest updateWithPlayerInfo:source]; } 
					onDeleteBlock:^(id dest) { [ dest removeFromParentAndCleanup:YES]; return YES; }
	 ];

	gameConnectingLabel_.visible = isConnecting;
	if (isConnecting) {
		for (BoardPlayerInfo *playerInfo in playerInfos_) {
			if (playerInfo.isLocalPlayer) {
				playerInfo.disconnectedIconVisible = YES;
			}
		}
	}
}

-(void)setRoundRemainingTime:(int)time
{
	[roundRemainingTimeLabel_ setString:[NSString stringWithFormat:@"%d:%02d", time/60, time%60]];
}

-(void)setGameMessage:(NSString*)message
{
	[gameMessageLabel_ setString:message];
}

-(void)setPlayerPingTime:(int)pingTime
{
	[playerPingLabel_ setString:[NSString stringWithFormat:@"ping:%d", pingTime]];	
}
												
-(BoardPlayerInfo*)_createNewBoardInfo:(PlayerInfo*)info
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	BoardPlayerInfo *boardInfo = [[[BoardPlayerInfo alloc] initWithPlayerInfo:info] autorelease];
	boardInfo.position = ccp(40 + (info.color - 1) * 45, winSize.height - 20);
	
	[self addChild:boardInfo];

	return boardInfo;
}

-(void)_checkDisconnection
{
	if ([GameController game].gameState == gsWaitDisconnection && !alertIsOpen_) {
		[self unschedule:@selector(_checkDisconnection)];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You have been disconnected" 
													   delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
		alertIsOpen_ = YES;
		[alert show];
		[alert release];	
	}
}

-(void)_askQuit
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@""
														message:@"Are you sure you want to quit?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
	alertIsOpen_ = YES;
	[alertView show];
	[[GameController game] pause];
	[alertView release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) { //YES
		[[GameController game] quit];
	} else {
		[[GameController game] resume];
	}
	alertIsOpen_ = NO;
}


-(void)dealloc
{
	[playerInfos_ release];
	[roundRemainingTimeLabel_ release];
	[gameMessageLabel_ release];
	[playerPingLabel_ release];
	[gameConnectingLabel_ release];
	[super dealloc];
}

@end
