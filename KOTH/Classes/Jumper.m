//
//  Jumper.m
//  KOTH
//
//  Created by Denis Davydenko on 10/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"

#import "Jumper.h"
#import "Platform.h"
#import "Tools.h"

#define JUMPING_START_SPEED 501.f
#define JUMPER_BLINK_ACTION_TAG 9

@interface Jumper(Private)

-(void)_initValues;
-(void)_initView;
-(void)_updateView;
-(void)_updateViewPosition;
-(void)_updateNamePosition;
-(void)_updateModel:(ccTime)dt;
-(void)_wanderNext;

@end

@implementation Jumper

@synthesize velX = velX_;
@synthesize velY = velY_;
@synthesize accelX = accelX_;
@synthesize accelY = accelY_;
@synthesize rotationVel = rotationVel_;
@synthesize isWandering = isWandering_;

+(id)jumperWithId:(int)playerId name:(NSString*)name color:(PlayerColor)color 
		 position:(CGPoint)position isLocalPlayer:(BOOL)isLocalPlayer
{
	return [[[Jumper alloc] initWithId:playerId name:name color:color position:position isLocalPlayer:isLocalPlayer] autorelease];
}

+(float)halfWidth
{
	return 16.f;
}

+(float)halfHeight
{
	return 17.f;
}

-(id)initWithId:(int)playerId name:(NSString*)name color:(PlayerColor)color 
	   position:(CGPoint)position isLocalPlayer:(BOOL)isLocalPlayer
{
	if	((self = [super initWithId:playerId name:name color:color position:position]))
	{
		self.isLocalPlayer = isLocalPlayer;
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
	[scene addChild:fallenView_];
	
//	[scene addChild:playerNameLabel_];
	
	NSLog(@"Player %@ is added to jump scene", playerName_);
}

-(void)removeFromScene
{
	[view_ removeFromParentAndCleanup:YES];
	[fallenView_ removeFromParentAndCleanup:YES];
	
//	[playerNameLabel_ removeFromParentAndCleanup:YES];
	
	[super removeFromScene];
	
	NSLog(@"Player %@ is removed from jump scene", playerName_);
}

-(void)update:(ccTime)dt
{
	if (!isWandering_) {
		if (!isFrozen_) {
			[self _updateModel:dt];
		}
		[super update:dt];
		[self _updateView];
	}
	[self _updateNamePosition];
}

-(void)setSrvPosX:(float)x
{
	[super setSrvPosX:x];
	
	posX_ = x;
}

-(void)setSrvPosY:(float)y
{
	[super setSrvPosY:y];

	posY_ = y;
}

-(void)setSrvDirection:(BOOL)dir
{
	[super setSrvDirection:dir];
	direction_ = dir;
}

-(void)setSrvRotation:(float)r
{
	[super setSrvRotation:r];
	rotation_ = r;
}

-(void)setIsFallen:(BOOL)isFallen
{
	if (isPaused_)
		return;
	
	if (isFallen && !isFallen_)
	{
		NSLog(@"Player %@ fell on jump scene", playerName_);

		fallenView_.position = ccp(view_.position.x, view_.position.y-10);
		fallenView_.flipX = view_.flipX;
		view_.visible = NO;
		fallenView_.visible = YES;
		
		[[SoundManager sounds] playSoundEffect:seftFallSound];
	}
	if (!isFallen && isFallen_)
	{
		NSLog(@"Player %@ got up on jump scene", playerName_);
		view_.visible = YES;
		fallenView_.visible = NO;
	}
	
	isFallen_ = isFallen;
}

-(void)setCollisionState:(JumperCollisionState)state
{
	if (collisionState_ != state) {
		if (state == jcsCollisionWinner) {
			[[SoundManager sounds] playSoundEffect:seftCollisionSound];
		}
		collisionState_ = state;
	}
}

-(void)setVelY:(float)srvVelY
{
	if (srvVelY_ < 0 && srvVelY >= 0 && !isFallen_) {
		[[SoundManager sounds] playSoundEffect:seftJumpSound];
	}

	srvVelY_ = srvVelY;
	velY_ = srvVelY;
}

-(void)setYOffset:(float)yOffset
{
	view_.position = ccp(view_.position.x, posY_ + yOffset);
}

#define WANDERING_SPEED 50.f
-(void)startWanderingFromLeftX:(float)leftX toRigthX:(float)rightX
{
	isWandering_ = YES;
	leftXBoundForWandering_ = leftX;
	rightXBoundForWandering_ = rightX;
	startXPosition_ = view_.position.x;

	NSLog(@"Player - %@ starts wandering from leftx=%2.1f to rightX=%2.1f with startX=%2.1f", 
		  playerName_, leftX, rightX, startXPosition_);
	
	[self performSelector:@selector(_wanderNext) withObject:nil afterDelay:1.5f];
}

-(void)toStartPositionForMaxTime:(int)timeToStart
{
	float time  = fabs(view_.position.x - startXPosition_)/WANDERING_SPEED;
	if (time > timeToStart) {
		time = timeToStart;
	}
	
	view_.flipX = (view_.position.x > startXPosition_);
	[view_ stopAllActions];
	[view_ runAction:[CCSequence actions:
					  [CCMoveTo actionWithDuration:time position:ccp(startXPosition_, view_.position.y)],
					  [CCCallFunc actionWithTarget:self selector:@selector(stopWandering)], 
					  nil]];
}

-(CCNode*)currentView
{
	return view_;
}

//-------------------PRIVATE---------------

-(void)_initValues
{
	view_ = fallenView_ = nil;
	
	prevPosY_ = 0.f;
	velX_ = 0.f;
	velY_ = 0.f;
	prevVelY_ = 0.f;
	srvVelY_ = 0.f;
	accelX_ = 0.f;
	accelY_ = 0.f;
	rotationVel_ = 0.f;
	
	isFallen_ = NO; 
	isWandering_ = NO;
	leftXBoundForWandering_ = 0;
	rightXBoundForWandering_ = 0;
	startXPosition_ = 0;
	yOffset_ = 0;
}

-(void)_initView
{
	view_ = [[CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_jumper.png", getColorFilePrefix(color_)]] retain];
	fallenView_ = [[CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_jumper_fall.png", getColorFilePrefix(color_)]] retain];
	fallenView_.visible = NO;
	
#ifdef SHOW_SERVER_VIEW			
	serverView_ = [[CCSprite node] retain];
	serverView_.textureRect = CGRectMake(0, 0, view_.contentSize.width, view_.contentSize.height);
	serverView_.color = ccWHITE;
#endif
	
	playerNameLabel_ = [[CCLabelTTFx labelWithString:playerName_ fontName:@"Arial" fontSize:12] retain];
	[playerNameLabel_ setColor:ccc3(0,0,0)];
}

-(void)_updateModel:(ccTime)dt
{
	prevPosY_ = posY_;
//	float nearestPlatformY = [[Platform pl] nearestPlatformPositionForX:posX_ andY:posY_];
	
	/*if (prevVelY_ < 0 && velY_ > 0 && posY_ > nearestPlatformY && velY_ > JUMPING_START_SPEED/2) // fix undershoots
	{
		NSLog(@"Player %@: undershoot correction y=%2.1f plY=%2.1f dY=%2.1f vy=%2.1f  prVy = %2.1f", 
			  playerName_, posY_, nearestPlatformY, posY_ - nearestPlatformY, velY_, prevVelY_);		
		posY_ = nearestPlatformY;
	} else //regular aproximation*/
	{
		velX_ += accelX_*dt;
		velY_ += accelY_*dt;
		posX_ += velX_*dt;
		posY_ += velY_*dt;
		rotation_ += rotationVel_*dt;
		
		float nearestPlatformY = [Platform nearestPlatformPositionForX:posX_ andY:prevPosY_];
		if(posY_ < nearestPlatformY) // fix overshoots
		{
			NSLog(@"Player %@: overshoot correction x=%2.1f y=%2.1f plY=%2.1f dY=2.1f", 
				  playerName_, posX_, posY_, nearestPlatformY, posY_ - nearestPlatformY);
			posY_ = nearestPlatformY;
			velY_ = JUMPING_START_SPEED;
		}
	}

	prevVelY_ = velY_;

}

-(void)_updateView
{
	[self _updateViewPosition];
	view_.flipX = direction_;
	view_.rotation = rotation_;		
}

-(void)_updateViewPosition
{	
#ifdef SHOW_SERVER_VIEW
	serverView_.position = ccp(serverView_.position.x, serverView_.position.y + yOffset_);
#endif
	
	view_.position = ccp(posX_, view_.position.y);
	if (isFallen_)
		fallenView_.position = ccp(view_.position.x, view_.position.y - 10);
			
	if (isLocalPlayer_ && view_.position.y < [Jumper halfHeight] + 17)
		NSLog(@"less then bottom by %2.1f", [Jumper halfHeight] + 17 - view_.position.y);
}


-(void)_updateNamePosition
{
	playerNameLabel_.position = ccp(view_.position.x, view_.position.y + view_.contentSize.height/2+10);
}

-(void)_wanderNext
{
	if (!isWandering_)
		return;

	BOOL direction = randomBOOL(); //YES -to left
	if (direction && (view_.position.x - leftXBoundForWandering_) < 20)
		direction = NO;
	if (!direction && (rightXBoundForWandering_ - view_.position.x) < 20)
		direction = YES;

	float range = rightXBoundForWandering_ - leftXBoundForWandering_;
	float distance = randomFromMinToMax(range/4, range);
	float destinationX = view_.position.x + distance * (direction? -1.f : 1.f);
	
	if (direction && destinationX < leftXBoundForWandering_)
		destinationX = leftXBoundForWandering_;
	if (!direction && destinationX > rightXBoundForWandering_)
		destinationX = rightXBoundForWandering_;
	
	float time = fabs(destinationX - view_.position.x)/WANDERING_SPEED;
	
	view_.flipX = direction;
	[view_ runAction:[CCSequence actions:
					  [CCMoveTo actionWithDuration:time position:ccp(destinationX, view_.position.y)],
					  [CCDelayTime actionWithDuration:randomFromMinToMax(0.7f, 1.5f)],
					  [CCCallFunc actionWithTarget:self selector:@selector(_wanderNext)],
					  nil]];
}

-(void)stopWandering
{
	[view_ stopAllActions];
	isWandering_ = NO;
}

-(void)dealloc
{
	[view_ release];
	[fallenView_ release];
	[playerNameLabel_ release];
	[super dealloc];
}

@end
