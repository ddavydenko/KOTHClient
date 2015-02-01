//
//  LoadingScene.m
//  KOTH
//
//  Created by Denis Davydenko on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoadingScene.h"
#import "HomeScene.h"
#import "GameOptions.h"
#import "SoundManager.h"
#import "Cocos2dViewController.h"
#import "PartnersScene.h"

@interface LoadingScene(Private)

-(void)_loadAndRun;
-(void)_preloadBackgrounds;

@end


@implementation LoadingScene

+(id)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LoadingScene *layer = [LoadingScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init
{
	if( (self=[super init] )) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"LoadingBackground.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
		
		[self schedule:@selector(_loadAndRun) interval:2.0];
	}
	
	return self;
}

-(void)_loadAndRun
{		
	[[SoundManager sounds] preloadSounds];

	[self _preloadBackgrounds];

	[GameOptions setSoundEnabled:[GameOptions soundEnabled]];	
	[GameOptions setMusicEnabled:[GameOptions musicEnabled]];	

	[self unscheduleAllSelectors];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.5 scene:[HomeScene scene]]];		
}

-(void)_preloadBackgrounds
{
	[[CCTextureCache sharedTextureCache] addImage:@"TitlepageBackground.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"OptionsBackground.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"LobbyBackground.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"GameoverBackground.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"JumpBackground.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"FightBackground.png"];
}


-(void)dealloc
{
	[super dealloc];
}

@end
