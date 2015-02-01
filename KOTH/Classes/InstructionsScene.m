//
//  InstructionsScene.m
//  KOTH
//
//  Created by denis davydenko on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InstructionsScene.h"
#import "HomeScene.h"
#import "CCLabelTTFx.h"

@interface InstructionsScene(Private)

-(void)_returnToMainMenu;

@end

@implementation InstructionsScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	InstructionsScene *layer = [InstructionsScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"InstructionsBackground.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
		CCMenuItem *quitIcon = [CCMenuItemImage itemFromNormalImage:@"home_button.png" 
													  selectedImage:@"home_button_pressed.png" target:self selector:@selector(_returnToMainMenu)];
		quitIcon.anchorPoint = ccp(0,0);
		CCMenu *quitButton = [CCMenu menuWithItems:quitIcon,nil];
		quitButton.position = ccp(0,0);
		[self addChild:quitButton];
		
		self.isTouchEnabled = YES;
	}
	return self;
}

-(void)_returnToMainMenu
{
	[self hideAd];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInB transitionWithDuration:0.5 scene:[HomeScene scene]]];	
}

@end
