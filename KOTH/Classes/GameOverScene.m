//
//  GameOverLayer.m
//  Jumper_iOS3
//
//  Created by Denis Davydenko on 10/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameOverScene.h"
#import "OpenFeintEx.h"
#import "GameController.h"
#import "CCLabelTTFx.h"
#import "HomeScene.h"
#import "Tools.h"
#import "SoundManager.h"

@interface GameOverScene(Private)

-(void)_submitScoreOnInit;
-(void)_onSubmitScoreClick;
-(void)_returnToMainMenu;

@end


@implementation GameOverScene


+(id)sceneWithTime:(int)gameLengthInMins andRoomCapacity:(int)roomCapacity
	andWinnerName:(NSString*)winnerName andWinnerColor:(PlayerColor)winnerColor 
	andWinnerTime:(int)winnerTime andWinnerPunches:(int)winnerPunches 
	andLocalPlayerTime:(int)localPlayerTime andLocalPlayerPunches:(int)localPlayerPunches 
	localPlayerIsWinner:(BOOL)localPlayerIsWinner
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameOverScene *layer = [[[GameOverScene alloc] initWithTime:gameLengthInMins andRoomCapacity:roomCapacity
						andWinnerName:winnerName  andWinnerColor:winnerColor andWinnerTime:winnerTime andWinnerPunches:winnerPunches
						andLocalPlayerTime:localPlayerTime andLocalPlayerPunches:localPlayerPunches
						localPlayerIsWinner:localPlayerIsWinner] autorelease];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)initWithTime:(int)gameLengthInMins andRoomCapacity:(int)roomCapacity
		andWinnerName:(NSString*)winnerName andWinnerColor:(PlayerColor)winnerColor 
		andWinnerTime:(int)winnerTime andWinnerPunches:(int)winnerPunches 
		andLocalPlayerTime:(int)localPlayerTime andLocalPlayerPunches:(int)localPlayerPunches 
		localPlayerIsWinner:(BOOL)localPlayerIsWinner
{
	if ((self=[super init])) 
	{
		gameLengthInMins_ = gameLengthInMins;
		roomCapacity_ = roomCapacity;
		localPlayerTime_ = localPlayerTime;
		localPlayerPunches_ = localPlayerPunches;
		localPlayerIsWinner_ = localPlayerIsWinner;
		winsIsSubmited_ = NO;
		scoresIsSubmited_ = NO;
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"GameoverBackground.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
	
		CCMenuItem *quitIcon = [CCMenuItemImage itemFromNormalImage:@"home_button.png" 
													  selectedImage:@"home_button_pressed.png" target:self selector:@selector(_returnToMainMenu)];
		quitIcon.anchorPoint = ccp(0,0);
		CCMenu *quitButton = [CCMenu menuWithItems:quitIcon,nil];
		quitButton.position = ccp(0,0);
		[self addChild:quitButton];
		
		if (winnerName)
		{
			CCSprite *winnerFace = [CCSprite spriteWithFile:
									[NSString stringWithFormat:@"%@_winner_big_face.png", getColorFilePrefix(winnerColor)]];
			winnerFace.position = ccp(295, 185);
			[self addChild:winnerFace];
			
			NSString *winnerTruncatedName = [winnerName truncatedStringToWidth:140 withFont:[UIFont fontWithName:@"Marker Felt" size:25]];
			CCLabelTTFx *winnerLabel = [CCLabelTTFx labelWithString:winnerTruncatedName fontName:@"Marker Felt" fontSize:25];
			winnerLabel.color = ccWHITE;
			winnerLabel.anchorPoint = ccp(0, 0);
			winnerLabel.position = ccp(330, 165);
			[self addChild:winnerLabel z:100];
			[winnerLabel setShadowWithColor:ccBLACK andOpacity:150 andOffset:CGSizeMake(1,-1)];
		}else {
			CCLabelTTFx *winnerLabel = [CCLabelTTFx labelWithString:@"TIE!" fontName:@"Marker Felt" fontSize:35];
			winnerLabel.color = ccWHITE;
			winnerLabel.anchorPoint = ccp(0, 0);
			winnerLabel.position = ccp(265, 165);
			[self addChild:winnerLabel z:100];
			[winnerLabel setShadowWithColor:ccBLACK andOpacity:150 andOffset:CGSizeMake(1,-1)];
		}

		CCLabelTTFx *localPlayerTimeLabel = [CCLabelTTFx 
										labelWithString:[NSString stringWithFormat:@"%d:%02d", localPlayerTime/60, localPlayerTime%60] 
										fontName:@"Marker Felt" fontSize:35];
		localPlayerTimeLabel.color = ccWHITE;
		localPlayerTimeLabel.position = ccp(270, 127);
		localPlayerTimeLabel.anchorPoint = ccp(0, 0);
		[self addChild:localPlayerTimeLabel z:100];
		[localPlayerTimeLabel setShadowWithColor:ccBLACK andOpacity:150 andOffset:CGSizeMake(1,-1)];
		
		CCLabelTTFx *localPlayerPunchesLabel = [CCLabelTTFx 
										   labelWithString:[NSString stringWithFormat:@"%d", localPlayerPunches] 
										   fontName:@"Marker Felt" fontSize:35];
		localPlayerPunchesLabel.color = ccWHITE;
		localPlayerPunchesLabel.position = ccp(275, 90);
		localPlayerPunchesLabel.anchorPoint = ccp(0, 0);
		[self addChild:localPlayerPunchesLabel z:100];
		[localPlayerPunchesLabel setShadowWithColor:ccBLACK andOpacity:150 andOffset:CGSizeMake(1,-1)];
		
		[[SoundManager sounds] playBackgroundMusic:localPlayerIsWinner ? bmtWinMusic : bmtLostMusic];
		
		if(roomCapacity_ > 1) {
			CCMenu *menu = [CCMenu menuWithItems:nil];
			CCMenuItem *submitScoreButton = [CCMenuItemImage itemFromNormalImage:@"submit_button.png" 
																   selectedImage:@"submit_button_pressed.png"
																		  target:self 
																		selector:@selector(_onSubmitScoreClick)];
			[menu addChild:submitScoreButton];
			menu.position = ccp(350, 75);
			[self addChild:menu];
	
			[self _submitScoreOnInit];
		}		
	}
	return self;
}

-(void)_submitScoreOnInit
{
	winsCategoryName_ = [[NSString stringWithFormat:@"drwins__%d", roomCapacity_] retain];
	punchesCategoryName_ = [[NSString stringWithFormat:@"drpunches__%d", roomCapacity_] retain];
	timeCategoryName_ = [[NSString stringWithFormat:@"drtime__%d", roomCapacity_] retain];
	
	if (localPlayerIsWinner_) {
		[[OpenFeintEx of] updateLocalPlayerScoreBy:1 forGCCategory:winsCategoryName_ withBlock:^ {
			 winsIsSubmited_ = YES;
		 }];
	}
}

-(void)_onSubmitScoreClick
{
	[[OpenFeintEx of] ensureApprovedWithBlock:^ {
		if (localPlayerPunches_ > 0 && !scoresIsSubmited_) {
			[[OpenFeintEx of] updateLocalPlayerScoreBy:localPlayerPunches_ forGCCategory:punchesCategoryName_ withBlock:nil];
		}
		if (localPlayerTime_ > 0 && !scoresIsSubmited_) {
			[[OpenFeintEx of] updateLocalPlayerScoreBy:localPlayerTime_ forGCCategory:timeCategoryName_ withBlock:nil];
		}
		if (!winsIsSubmited_ && !scoresIsSubmited_ && localPlayerIsWinner_) {
			[[OpenFeintEx of] updateLocalPlayerScoreBy:1 forGCCategory:winsCategoryName_ withBlock:^{
				[[OpenFeintEx of] showLeaderboardByCGCategory:winsCategoryName_];
			}];
		}else {
			[[OpenFeintEx of] showLeaderboardByCGCategory:winsCategoryName_];
		}
		scoresIsSubmited_ = YES;
	}];
}

-(void)_returnToMainMenu 
{
	[self hideAd];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:GAME_SCENE_PAGE_TURN_TIME 
																					 scene:[HomeScene scene] backwards:YES]];
}

-(void)dealloc 
{
	[winsCategoryName_ release];
	[punchesCategoryName_ release];
	[timeCategoryName_ release];
	[super dealloc];
}

#pragma mark SceneWithAd overrides

-(NSString*)getZone {
	return @"0057947279042204545";
}

-(CGPoint)getAnchorPoint
{
	return CGPointMake(0.54, 0);
}

@end
