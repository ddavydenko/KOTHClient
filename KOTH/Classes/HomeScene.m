//
//  HomeScene.m
//  Jumper_iOS3
//
//  Created by Igor Nikolaev on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HomeScene.h"
#import "GameController.h"
#import "LobbyScene.h"
#import "OpenFeintEx.h"
#import "CCLabelTTFx.h"
#import "Server.h"
#import "NSArrayEx.h"
#import	"OptionsScene.h"
#import "InstructionsScene.h"
#import "SoundManager.h"
#import "GameOptions.h"
#import "SimpleHttpClient.h"
#import "Cocos2dViewController.h"

@interface HomeScene(Private)

-(void)_play;
-(void)_showLeaderboards;
-(void)_showInstructions;
-(void)_checkOpenFeintViewType;
-(void)_initOpenFeint;

@end


@implementation HomeScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HomeScene *layer = [HomeScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init 
{
	if( (self=[super init] )) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"TitlepageBackground.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];

		CCMenuItem *playButton = [CCMenuItemImage itemFromNormalImage:@"play_button.png" 
														selectedImage:@"play_button_pressed.png" 
														target:self selector:@selector(_play)];
		playButton.anchorPoint = ccp(0, 1);
		playButton.position = ccp(1, -2);

		CCMenuItem *optionsButton = [CCMenuItemImage itemFromNormalImage:@"options_button.png" 
														selectedImage:@"options_button_pressed.png" 
															   target:self selector:@selector(_options)];
		optionsButton.anchorPoint = ccp(0, 1);
		optionsButton.position = ccp(1, -33);
		
		CCMenu *menu = [CCMenu menuWithItems:playButton, optionsButton, nil];
		menu.anchorPoint = ccp(0, 0);
		menu.position = ccp(0, winSize.height);
		
		CCMenuItem *leaderboardsButton = [CCMenuItemImage itemFromNormalImage:@"leaderboards_button.png" 
																selectedImage:@"leaderboards_button_pressed.png"
																	   target:self 
																	 selector:@selector(_showLeaderboards)];
		leaderboardsButton.anchorPoint = ccp(0, 1);
		leaderboardsButton.position = ccp(1, -64);
		[menu addChild:leaderboardsButton];

		[self addChild:menu];
		
		CCMenuItem *instructionsIcon = [CCMenuItemImage itemFromNormalImage:@"instructions_button.png" 
													  selectedImage:@"instructions_button_pressed.png" target:self selector:@selector(_showInstructions)];
		instructionsIcon.anchorPoint = ccp(0,0);
		CCMenu *instructionsButton = [CCMenu menuWithItems:instructionsIcon,nil];
		instructionsButton.position = ccp(5,5);
		[self addChild:instructionsButton];
			
		[[SoundManager sounds] playBackgroundMusic:bmtHomeMusic];
		
		[self schedule:@selector(_initOpenFeint) interval:1.5];
	}
	return self;
}

-(void)_showLeaderboards
{
	[[OpenFeintEx of] showDefaultLeaderboard];
}

-(void)_showInstructions
{
	[self hideAd];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInB transitionWithDuration:0.5 scene:[InstructionsScene scene]]];	
}

-(void)_play
{
	[self hideAd];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:GAME_SCENE_PAGE_TURN_TIME scene:[LobbyScene scene]]];
}

-(void)_options
{
	[self hideAd];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInT transitionWithDuration:0.5 scene:[OptionsScene scene]]];
}

-(void)_initOpenFeint
{	
	[self unschedule:@selector(_initOpenFeint)];
	[[OpenFeintEx of] initializeWithProductKey:@"VEe5Pc3QIyLzG890gJGA"
									 andSecret:@"LBHaOD5w6yRX7iuFyZ6qgbwbVY3Dxql9NsGaLazho5c"
								andDisplayName:@"Doodle Rams Multiplayer" 
						   andShortDisplayName:@"Doodle Rams"
							  andUIOrientation:UIInterfaceOrientationLandscapeRight 
				   andGameCenterViewController:[Cocos2dViewController currentController]
							 withCompleteBlock:^{
								 if ([OpenFeintEx of].viewType == ofvtNone) {
									 if ([GameOptions openFeintViewType] == ofvtNone) {
										 [[OpenFeintEx of] askViewTypeWithBlock:^(OpenFeintViewType viewType) {
											 [GameOptions setOpenFeintViewType:viewType];
										 }];
									 }else {
										 [OpenFeintEx of].viewType = [GameOptions openFeintViewType];
									 }
								 }
							 }];
	[[OpenFeintEx of] waitUserLogsInWithBlock:^(NSString *userName)
	 {
		 [GameOptions setLocalPlayerName:userName];
	 }];
}

-(void)dealloc
{
	[super dealloc];
}

#pragma mark SceneWithAd overrides

-(NSString*)getZone {
	return @"0255947679042204545";
}

@end
