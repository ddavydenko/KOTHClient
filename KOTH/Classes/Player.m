//
//  Player.m
//  KOTH
//
//  Created by Denis Davydenko on 10/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Player.h"

#define PING_FROZEN_BLINK_ACTION_TAG 999

@interface Player(Private)

-(void)_initValues;

@end


@implementation Player

@synthesize playerId = playerId_;
@synthesize playerName = playerName_;
@synthesize isLocalPlayer = isLocalPlayer_;
@synthesize posX = posX_;
@synthesize posY = posY_;
@synthesize srvPosX = srvPosX_;
@synthesize srvPosY = srvPosY_;
@synthesize srvDirection = srvDirection_;
@synthesize srvRotation	= srvRotation_;
@synthesize isDisplayed = isDisplayed_;
@synthesize isFrozen = isFrozen_;

-(id)init
{
	if ((self = [super init])) 
	{
		[self _initValues];
	}
	return self;
}

-(id)initWithId:(int)playerId name:(NSString*)name color:(PlayerColor)color position:(CGPoint)position
{
	if	((self = [super init]))
	{
		[self _initValues];
		
		playerId_ = playerId;
		playerName_ = [name retain];
		srvPosX_ = posX_ = position.x;
		srvPosY_ = posY_ = position.y;
		color_ = color;
	}
	return self;
}

-(void)addToScene:(CCLayer*)scene
{
#ifdef SHOW_SERVER_VIEW			
	[scene addChild:serverView_];
#endif
	
	isDisplayed_ = YES;
	if ([self respondsToSelector:@selector(update:)])
	{
		[self schedule:@selector(update:)];
	}
}

-(void)update:(ccTime)dt
{
#ifdef SHOW_SERVER_VIEW
	serverView_.position = ccp(srvPosX_, srvPosY_);
	serverView_.rotation = srvRotation_;
#endif
}

-(void)removeFromScene
{
#ifdef SHOW_SERVER_VIEW			
	[serverView_ removeFromParentAndCleanup:YES];
#endif
	
	[self unscheduleAllSelectors];
	isDisplayed_ = NO;
}

-(void)schedule:(SEL)selector
{
	[self schedule:selector interval:0];
}

-(void)schedule:(SEL)selector interval:(ccTime)interval
{
	NSAssert( selector != nil, @"Argument must be non-nil");
	NSAssert( interval >=0, @"Arguemnt must be positive");
	
	[[CCScheduler sharedScheduler] scheduleSelector:selector forTarget:self interval:interval paused:NO];
}

-(void)unschedule:(SEL)selector
{
	if (selector == nil)
		return;
	
	[[CCScheduler sharedScheduler] unscheduleSelector:selector forTarget:self];
}

-(void)unscheduleAllSelectors
{
	[[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
}

-(CCNode*)currentView
{
	NSLog(@"[Player currentView] needs to be overriten");
	return nil;
}

-(void)setIsPaused:(BOOL)isPaused
{
	if (!isPaused_ && isPaused)
	{
		NSLog(@"Player %@: set isPaused", playerName_);
		CCAction *blink = [CCRepeatForever actionWithAction:[CCBlink actionWithDuration:1.0f blinks:2]];
		blink.tag = PING_FROZEN_BLINK_ACTION_TAG;
		[[self currentView] runAction:blink];
	}
	
	if (isPaused_ && !isPaused) {
		NSLog(@"Player %@: clear isPaused", playerName_);
		[[self currentView] stopActionByTag:PING_FROZEN_BLINK_ACTION_TAG];
		[self currentView].visible = YES;
	
	}
	
	isPaused_ = isPaused;
}

-(void)_initValues
{	
	playerId_ = 0;
	playerName_ = nil;
	playerNameLabel_ = nil;
	
	isLocalPlayer_ = NO;
	isDisplayed_ = NO;
	
	srvPosX_ = posX_ = 0;
	srvPosY_ = posY_ = 0;
	srvDirection_ = direction_ = NO;
	srvRotation_ = rotation_ = 0.f;
	isPaused_ = NO;
	
#ifdef SHOW_SERVER_VIEW				
	serverView_ = nil;
#endif
	
	color_ = pcGray;
	
}

-(void)dealloc
{
#ifdef SHOW_SERVER_VIEW			
	[serverView_ release];
#endif
	[playerName_ release];
	[super dealloc];
}

@end

