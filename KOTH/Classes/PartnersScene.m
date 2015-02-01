//
//  PartnersScene.m
//  KOTH
//
//  Created by Denis Davydenko on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PartnersScene.h"
#import "LoadingScene.h"
#import "HomeScene.h"

@implementation PartnersScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PartnersScene *layer = [PartnersScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init 
{
	if( (self=[super init] )) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"PartnersBackground.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
		background.opacity = 0;
		[background runAction:[CCFadeIn actionWithDuration:1.0]];
		
		[self schedule:@selector(_runLoadingScene) interval:2.5];
	}
	return self;
}

-(void)_runLoadingScene
{
	[self unscheduleAllSelectors];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.5 scene:[LoadingScene scene]]];		
}

-(void)dealloc
{
	[super dealloc];
}


@end
