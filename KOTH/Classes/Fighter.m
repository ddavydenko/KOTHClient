//
//  Fighter.m
//  KOTH
//
//  Created by Denis Davydenko on 10/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Fighter.h"
#import "SoundManager.h"
#import "TargetedAction.h"

#define MOVING_SPEED 200.0f
#define SLOW_MOVING_SPEED 100.0f
#define MOVING_STEP 30.f

typedef enum {
	fvtRegular,
	fvtEating,
} FighterViewType;


@interface Fighter(Private)

-(void)_initValues;
-(void)_initView;
-(void)_updateView;
-(void)_updateNamePosition;
-(void)_modelState:(ccTime)dt;
-(void)_localMovement:(ccTime)dt;
-(void)_followServerMovement:(ccTime)dt;
-(void)_moveToX:(float)targetX withSpeed:(float)speed andTime:(ccTime)dt;
-(void)_setToServerData;
-(void)_stopHitting;
-(void)_stopCrashing;
-(void)_stopActionMovement;
-(void)_startEatingGrass;
-(void)_stopEatingGrass;

@end

@implementation Fighter

float spriteHeight_, spriteWidth_;

+(id)fighterWithId:(int)playerId name:(NSString*)name color:(PlayerColor)color position:(CGPoint)position
{
	return [[[Fighter alloc] initWithId:playerId name:name color:color position:position] autorelease];
}

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
	if	((self = [super initWithId:playerId name:name color:color position:position]))
	{
		[self _initView];

		[self update:0];
	}
	
	return self;
}

-(void)addToScene:(CCLayer*)scene
{
	NSAssert(scene, @"scene can't be nil");
	
	[super addToScene:scene];

	[scene addChild:view_];
	[scene addChild:collisionSprite_ z:16];

//	[scene addChild:playerNameLabel_];
	
	NSLog(@"Player %@ is added to fight scene to pos:(x=%2.1f; y=%2.1f)", playerName_, view_.position.x, view_.position.y);
}

-(void)removeFromScene
{
	if (eatSoundId_ !=0 )
		[[SoundManager sounds] stopSoundEffect:eatSoundId_];
	
	[view_ removeFromParentAndCleanup:YES];
	[collisionSprite_ removeFromParentAndCleanup:YES];
	
	[super removeFromScene];

	NSLog(@"Player %@ is remover from fight scene", playerName_);
}

-(void)update:(ccTime)dt
{
	[self _modelState:dt];
	[self _updateView];
	[self _updateNamePosition];
	[super update:dt];
}

-(void)moveOnClientToDirection:(BOOL)direction
{
	if (!isDisplayed_)
		return;

	if (state_ == fsStanding)
	{
		NSLog(@"Player %@ starts local movement to the %@", playerName_, direction ? @"left" : @"right");
		
		direction_ =  direction;
		state_ = fsClientMovement;
		localXTarget_ = posX_ + (direction ? -MOVING_STEP : MOVING_STEP);
	}
}


/*
-(void)setIsHitting:(BOOL)isHitting hitResult:(FighterHitResult)hitResult
{
	if (!isDisplayed_)
		return;
	
	NSLog(@"setIsHitting... isHitting : %d\thitResult : %d", isHitting, hitResult);
	
	if (isHitting && !srvIsHitting_ && state_ != fsHitting)
	{
		NSLog(@"Player %@ makes hit", playerName_);
		state_ = fsHitting;
		isActionMovement_ = YES;
		[self _stopEatingGrass];

		[view_ runAction:[CCSequence actions:
						  [CCRotateBy actionWithDuration:0.08f angle:(direction_ ? -1.f : 1.f) * 20.f],
						  [CCSpawn actions:
						   [CCRotateBy actionWithDuration:0.05f angle:(direction_ ? -1.f : 1.f) * 10.f],
						   [CCMoveBy actionWithDuration:0.05f position:ccp((direction_ ? -1.f : 1.f) * 10.f, 0)],
						   nil],
						  [CCDelayTime actionWithDuration:0.15f],
						  [CCRotateTo actionWithDuration:0.02f angle:0],
						  [CCCallFunc actionWithTarget:self selector:@selector(_stopHitting)],
						  nil]];
	}
	
	srvIsHitting_ = isHitting;
}
*/

-(void)setIsHitting:(BOOL)isHitting hitResult:(FighterHitResult)hitResult
{
	if (!isDisplayed_)
		return;
	
//	NSLog(@"setIsHitting... isHitting : %d\thitResult : %d", isHitting, hitResult);
	
	if (isHitting && !srvIsHitting_ && state_ != fsHitting)
	{
		//NSLog(@"Player %@ makes hit STAGE 1", playerName_);
		state_ = fsHitting;
		isActionMovement_ = YES;
		[self _stopEatingGrass];
		
		[view_ runAction: [CCSequence actions:
						   [CCRotateBy actionWithDuration:.08f angle:(direction_ ? -1.f : 1.f) * 20.f],
						   [CCCallBlock actionWithBlock:^{isWaitingForServerHitResult_ = YES;}],
						   nil]];
	}
	
	srvIsHitting_ = isHitting;
	
	if (awaitedAttackerHitResult_ == fhrNone && hitResult != fhrNone)
	{
		//NSLog(@"Player %@ hit result: %d", playerName_, hitResult);
		awaitedAttackerHitResult_ = hitResult;
	}
	
	if (isWaitingForServerHitResult_ && awaitedAttackerHitResult_ != fhrNone)
	{
		//NSLog(@"Player %@ makes hit STAGE 2. AwaitedHitResult: %d", playerName_, awaitedAttackerHitResult_);
		
		CCFiniteTimeAction* spriteAction;
		if ((awaitedAttackerHitResult_&fhrHit) == fhrHit)
		{
			collisionSprite_.position = ccp(posX_ + (direction_ ? -1.f : 1.f) * (10.f + spriteWidth_ / 2.f), posY_ + spriteHeight_ / 3.f);
			spriteAction = [CCSequence actions:
							[CCShow action],
							[CCBlink actionWithDuration:.25f blinks:1],
							[CCHide action],
							nil];
			[view_ runAction:[CCSequence actions:
							  [CCSpawn actions:
							   [TargetedAction actionWithTarget:collisionSprite_ action:spriteAction],
							   [CCRotateBy actionWithDuration:.05f angle:(direction_ ? -1.f : 1.f) * 10.f],
							   [CCMoveBy actionWithDuration:.05f position:ccp((direction_ ? -1.f : 1.f) * 10.f, 0)],
							   nil],
							  [CCRotateTo actionWithDuration:.02f angle:0],
							  nil]];
		}
		else {
			[view_ runAction:[CCSequence actions:
							  [CCSpawn actions:
							   [CCRotateBy actionWithDuration:.05f angle:(direction_ ? -1.f : 1.f) * 10.f],
							   [CCMoveBy actionWithDuration:.05f position:ccp((direction_ ? -1.f : 1.f) * 10.f, 0)],
							   nil],
							  [CCRotateTo actionWithDuration:.02f angle:0],
							  nil]];
		}
	

		
		isWaitingForServerHitResult_ = NO;
		awaitedAttackerHitResult_ = fhrNone;
		[self _stopHitting];
	}
	
}

-(void)setHitResult:(FighterHitResult)hitResult hitToSide:(BOOL)hitSide //YES - to the left; NO - to the right
{
	if (!isDisplayed_)
		return;
		
	if ((hitResult&fhrCrash) == fhrCrash && (hitResult_&fhrCrash) != fhrCrash && state_ != fsCrashing)
	{
		//NSLog(@"Player %@ starts crashing", playerName_);
		state_ = fsCrashing;
		isActionMovement_ = YES;
		
		[view_ runAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:.1f],
						  [CCSpawn actions:
						   [CCJumpBy actionWithDuration:.5f position:ccp((hitSide ? 1.f : -1.f) * 128.f, 0) height:50 jumps:1],
						   [CCRotateBy actionWithDuration:.5f angle:(hitSide ? 1.f : -1.f) * 90.f],
						   nil],
						  [CCBlink actionWithDuration:1.f blinks:2],
						  [CCShow action],
						  [CCCallFunc actionWithTarget:self selector:@selector(_stopCrashing)],
						  nil]];
	}

	if ((hitResult&fhrFightComplete) == fhrFightComplete) {
		//NSLog(@"Player %@ fight result - %d", playerName_, hitResult);
		[[SoundManager sounds] playSoundEffect: ((hitResult&fhrHit) == fhrHit) ? seftPunchSound : seftMissSound];
	}
	
	hitResult_ = hitResult;
	awaitedAttackerHitResult_ = fhrNone;
}

-(void)_stopEatingGrass {
	if (eatSoundId_ != 0)
	{
		[[SoundManager sounds] stopSoundEffect:eatSoundId_];
		eatSoundId_ = 0;
	}
	view_.currentSpriteTag = fvtRegular;
	[self unschedule:@selector(_startEatingGrass)];

}
-(void)setIsAlone:(BOOL)isAlone
{
	if (!isAlone_ && isAlone)
	{
		[self schedule:@selector(_startEatingGrass) interval:6.f];
	}
	if (isAlone_ && !isAlone) {
		isEatingGrass_ = NO;
		[self _stopEatingGrass];

	}
	
	isAlone_ = isAlone;
}

-(CCNode*)currentView
{
	return view_;
}

-(void)setIsPaused:(BOOL)isPaused
{
	if (!isPaused_ && isPaused) {
		state_ = fsFrozen;
	}
	
	if (isPaused_ && !isPaused) {
		state_ = fsStanding;
	}
	
	[super setIsPaused:isPaused];
}

 //--------------------------PRIVATE----------------------
-(void)_initValues
{
	view_ = nil;
		
	state_ = fsStanding;
	
	localXTarget_ = 0.f;
	
	srvIsHitting_ = NO;
	hitResult_ = fhrNone;
	awaitedAttackerHitResult_ = fhrNone;
	isActionMovement_ = NO;
	
	isAlone_ = NO;
	isEatingGrass_ = NO;
}

-(void)_initView
{
	collisionSprite_ = [[CCSprite spriteWithFile:@"collision.png"] retain];
	collisionSprite_.visible = NO;
	
	CCSprite *regularView_ = [[CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_fighter.png", getColorFilePrefix(color_)]] retain];
	spriteWidth_ = regularView_.contentSize.width;
	spriteHeight_ = regularView_.contentSize.height;
	
#ifdef SHOW_SERVER_VIEW			
	serverView_ = [[CCSprite node] retain];
	serverView_.textureRect = CGRectMake(0, 0, view_.contentSize.width, view_.contentSize.height);
	serverView_.color = ccWHITE;
#endif
	
	playerNameLabel_ = [[CCLabelTTFx labelWithString:playerName_ fontName:@"Arial" fontSize:15] retain];
	[playerNameLabel_ setColor:ccc3(0,0,0)];
			
	CCSprite *eatingView_ = [[CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_eat1.png", getColorFilePrefix(color_)]] retain];
	CCAnimation *eatingAnimation = [CCAnimation animationWithName:[NSString stringWithFormat:@"%@_eating", getColorFilePrefix(color_)]];
	[eatingAnimation addFrameWithFilename:[NSString stringWithFormat:@"%@_eat1.png", getColorFilePrefix(color_)]];
	[eatingAnimation addFrameWithFilename:[NSString stringWithFormat:@"%@_eat2.png", getColorFilePrefix(color_)]];
	[eatingView_ runAction:[CCRepeatForever actionWithAction:
								[CCAnimate actionWithDuration:0.5f animation:eatingAnimation restoreOriginalFrame:NO]]];

	view_ = [[CCMultiSprite node] retain];
	[view_ addChild:regularView_ tag:fvtRegular];
	[view_ addChild:eatingView_ tag:fvtEating];
	view_.currentSpriteTag = fvtRegular;
}

-(void)_setToServerData
{
	posX_ = srvPosX_;
	posY_ = srvPosY_;
	direction_ = srvDirection_;
	rotation_ = 0;
	
	[self _updateView];
}

-(void)_modelState:(ccTime)dt
{
	if (!isDisplayed_)
		return;

	switch (state_) {
		case fsStanding:
			direction_ = srvDirection_;
			if (posX_ != srvPosX_)
				state_ = fsFollowServerMovement;
			break;
		case fsClientMovement:
			[self _localMovement:dt];
			break;
		case fsFollowServerMovement:
			[self _followServerMovement:dt];
			break;

		default:
			break;
	}
}

-(void)_localMovement:(ccTime)dt
{
	[self _moveToX:localXTarget_ withSpeed:SLOW_MOVING_SPEED andTime:dt];
	NSLog(@"Player %@: localMovement: x=%2.2f srvX=%2.2f", playerName_, posX_, srvPosX_);
	
	if ((!srvDirection_ && !direction_ && srvPosX_ > posX_) 
		|| (srvDirection_ && direction_ && srvPosX_ < posX_)
		|| (posX_ == srvPosX_)
		)
	{
		state_ = fsStanding;
		NSLog(@"Player %@: stop local movement by server reason.", playerName_);
	}
}

-(void)_followServerMovement:(ccTime)dt
{
	direction_ = srvDirection_;
	
	[self _moveToX:srvPosX_ withSpeed:MOVING_SPEED andTime:dt];
	
	if(posX_ != srvPosX_)
		NSLog(@"Player %@: followServer: x=%2.2f srvX=%2.2f", playerName_, posX_, srvPosX_);
	else 
	{
		state_ = fsStanding;
		NSLog(@"Player %@: reached server position.", playerName_);
	}
	
}

-(void)_updateView
{	
	if (isActionMovement_)
	{
		posX_ = view_.position.x;
		posY_ = view_.position.y;
		direction_ = view_.flipX;
		rotation_ = view_.rotation;
	} else {
		view_.position = ccp(posX_, posY_);
		view_.flipX = direction_;
		view_.rotation = rotation_;
	}
}

-(void)_updateNamePosition
{
	playerNameLabel_.position = ccp(view_.position.x, view_.position.y + 16 + 10);;
}

-(void) _moveToX:(float)targetX withSpeed:(float)speed andTime:(ccTime)dt
{
	if (posX_ != targetX) 
	{
		if (direction_)//YES - to the left; NO - to the right
		{
			posX_ -= speed * dt;
			//			NSLog(@"move left by %2.1f", speed * dt);
			if (posX_ < targetX)
			{
				//				NSLog(@"correcting to %2.1f", targetX);
				posX_ = targetX;
			}
		}else 
		{
			posX_ += speed * dt;
			//			NSLog(@"move right by %2.1f", speed * dt);
			if (posX_ > targetX)
			{
				//				NSLog(@"correcting to %2.1f", targetX);
				posX_ = targetX;
			}
		}
	}
}

-(void)_stopHitting
{
	NSLog(@"Player %@ stops hitting", playerName_);
	if (isEatingGrass_)
		[self schedule:@selector(_startEatingGrass) interval:6.0f];

	[self _stopActionMovement];
}

-(void)_stopCrashing
{
	NSLog(@"Player %@ stops crashing", playerName_);
	[self _stopActionMovement];
}

-(void)_stopActionMovement
{
	isActionMovement_ = NO;
	[self _setToServerData];
	state_ = fsStanding;
}

-(void)_startEatingGrass
{
	eatSoundId_ = [[SoundManager sounds] playSoundEffect:seftEatSound loop:YES];
	view_.currentSpriteTag = fvtEating;
	isEatingGrass_ = YES;
	[self unschedule:@selector(_startEatingGrass)];
}

-(void)dealloc
{
	[view_ release];
	[collisionSprite_ release];
	[playerNameLabel_ release];
	[super dealloc];
}

@end