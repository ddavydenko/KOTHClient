//
//  JumperScene.m
//  Jumper_Threads
//
//  Created by Igor Nikolaev on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JumpScene.h"
#import "Platform.h"
#import "Server.h"
#import	"GameController.h"
#import "SoundManager.h"


#define MAX_X_ACCEL_SPEED 700.f
#define X_ACCEL_SPEED_STEP 120.f

@interface JumpScene(Private)

-(void)_sendLocalControls;

@end


@implementation JumpScene

+(id)scene:(BOOL)switchFromFight
{
	CCScene *scene = [CCScene node];
	JumpScene *layer = [[[JumpScene alloc] init:switchFromFight] autorelease];
	[scene addChild: layer];
	return scene;
}

-(id)init:(BOOL)switchFromFight
{
	if( (self=[super init] )) {

		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 /40)];
		self.isAccelerometerEnabled =YES;
        self.isTouchEnabled =YES;
		
		sendAccelX_ = 0.f;
		
		[self schedule:@selector(_sendLocalControls) interval:0.1f];
		[self schedule:@selector(_followLocalJumper)];
		
		[[SoundManager sounds] playBackgroundMusic:bmtJumpMusic];
		
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		
		if (switchFromFight)
			[platform_ toTheTop];
	}
	return self;
}

-(void)_followLocalJumper
{	
	Jumper *localJumper = [[GameController game] localJumper];
	if (!localJumper) 
		return;
	
	float y = localJumper.posY - [platform_ offset];
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	float delta = 0.0f;
	int topY = winSize.height / 2;
	int bottomY = [Jumper halfHeight] + 17;
		
	//upwards
	if(y>topY && ![platform_ isAtTheTop])
	{
		delta = y - winSize.height/2;
		y = winSize.height/2;
	}
	//downwards
	if(y <= bottomY && ![platform_ isAtTheBottom])
	{
		delta = y - bottomY;
		y = bottomY;
	}
		
	if (delta != 0.0f)
		[platform_ addOffset:delta];

//	[localJumper updateViewPosition:viewPosition withOffset:[platform_ offset]];

	for (Jumper *jumper in [[GameController game] allPlayers]) {
		[jumper setYOffset: y - localJumper.posY];
	}
}

-(void)_sendLocalControls
{
	if ([GameController game].gameState == gsJumping) {
		[[Server srv] sendJumpControls:sendAccelX_];
	}
}

-(GameSceneType)sceneType
{
	return gstJumpScene;
}

-(void)addGameLayouts
{	
	platform_ = [[Platform alloc] init];

	[self addChild:platform_.backGroundPlatform];
		
	[super addGameLayouts];	
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration{
	static float  prevY = 0;
	float accel = acceleration.y;
	if (fabs(accel) < 0.05f)
		accel=0;
	
	float accelY = prevY + ((accel * MAX_X_ACCEL_SPEED) - prevY) * 0.5f;
 	prevY = accelY;
	sendAccelX_ = accelY*-1;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint cLoc = [[CCDirector sharedDirector] convertToGL: location];	
	CGSize size = [[CCDirector sharedDirector] winSize];

	if(cLoc.x > size.width/2)
		sendAccelX_ += X_ACCEL_SPEED_STEP;
	else
		
		sendAccelX_ -= X_ACCEL_SPEED_STEP;
}

- (void) dealloc
{
	[platform_ release];
	[super dealloc];
}

@end
