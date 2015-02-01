//
// http://www.cocos2d-iphone.org
//

#import "FightScene.h"
#import "Fighter.h"
#import "Server.h"
#import "GameController.h"
#import "SoundManager.h"

@interface FightScene(Private)
	
-(void)_makeHit:(id)sender;
-(void)_moveTo:(BOOL)direction; //YES - to the left; NO - to the right
-(void)_stopMoving;

@end

@implementation FightScene

+(id)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	FightScene *layer = [FightScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init
{
	if( (self=[super init] )) {
		
		self.isTouchEnabled = YES;
		
		isMovingToLeft_ = NO;
		isMovingToRight_ = NO;
		
		[[SoundManager sounds] playBackgroundMusic:bmtFightMusic];
	}
	return self;
}


-(GameSceneType)sceneType
{
	return gstFightScene;
}

-(void)addGameLayouts
{
	CGSize size  = [[CCDirector sharedDirector] winSize];

	CCSprite *background = [CCSprite spriteWithFile:@"FightBackground.png"];
	background.position=ccp(size.width/2, size.height/2);
	background.scaleX = size.width/((background.position.x+background.contentSize.width/2)-(background.position.x-background.contentSize.width/2));
	background.scaleY = size.height/((background.position.y+background.contentSize.height/2)-(background.position.y-background.contentSize.height/2));
	[self addChild:background];
	
	leftArrow_ = [[CCSprite spriteWithFile:@"moveleft_button.png"] retain];
	rightArrow_ = [[CCSprite spriteWithFile:@"moveright_button.png"] retain];
	
	leftArrow_.position=ccp(leftArrow_.contentSize.width/2, size.height/1.5);
	rightArrow_.position=ccp(size.width-leftArrow_.contentSize.width/2, size.height/1.5);
	
	CCMenuItem *fightItem = [CCMenuItemImage itemFromNormalImage:@"punch_button.png" 
												   selectedImage:@"punch_button_pressed.png" 
														  target:self selector:@selector(_makeHit:)];
	
	fightButton_ = [[CCMenu menuWithItems:fightItem,nil] retain];
	fightButton_.position = ccp(425, 50);
		
	[self addChild:leftArrow_];
	[self addChild:rightArrow_];
	[self addChild:fightButton_];

	[super addGameLayouts];
}

-(void)_makeHit:(id)sender
{
	[[Server srv] sendFightControls:NO andRight:NO andHit:YES];
}

-(void)_moveTo:(BOOL)direction
{
	if (direction) {
		if (!isMovingToLeft_) {
			isMovingToRight_ = NO;
			isMovingToLeft_ = YES;

			[[[GameController game] localFighter] moveOnClientToDirection:YES];
			[[Server srv] sendFightControls:YES andRight:NO andHit:NO];
		}
	}
	else {
		if (!isMovingToRight_) {
			isMovingToRight_ = YES;
			isMovingToLeft_ = NO;

			[[[GameController game] localFighter] moveOnClientToDirection:NO];
			[[Server srv] sendFightControls:NO andRight:YES andHit:NO];
		}
	}
}

-(void)_stopMoving
{
	isMovingToRight_ = NO;
	isMovingToLeft_ = NO;
	
	[[Server srv] sendFightControls:NO andRight:NO andHit:NO];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint cLoc = [[CCDirector sharedDirector] convertToGL: location];
	//	NSLog(@"touch - (x=%2.1f y=%2.1f)", cLoc.x, cLoc.y);
	
	if (CGRectContainsPoint([leftArrow_ boundingBox], cLoc) ) {
		[leftArrow_ setTexture:[[CCTextureCache sharedTextureCache] addImage:@"moveleft_button_pressed.png"]];
		[self _moveTo:YES];
	}
	if (CGRectContainsPoint([rightArrow_ boundingBox], cLoc) ) {
		[rightArrow_ setTexture:[[CCTextureCache sharedTextureCache] addImage:@"moveright_button_pressed.png"]];
		[self _moveTo:NO];
	}
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[leftArrow_ setTexture:[[CCTextureCache sharedTextureCache] addImage:@"moveleft_button.png"]];
	[rightArrow_ setTexture:[[CCTextureCache sharedTextureCache] addImage:@"moveright_button.png"]];
	[self _stopMoving];
}

- (void) dealloc
{
	[leftArrow_ release];
	[rightArrow_ release];
	[fightButton_ release];
	[super dealloc];
}

@end
