//
//  OptionsScene.m
//  KOTH
//
//  Created by Denis Davydenko on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OptionsScene.h"
#import "HomeScene.h"
#import "GameOptions.h"
#import "Tools.h"
#import "OpenFeintEx.h"

@interface OptionsScene(Private) 

-(void)_returnToMainMenu;
-(void)_switchSound;
-(void)_switchMusic;
-(void)_switchPing;
//-(void)_showCredits;
-(void)_addNameTextField;
-(void)_addIpTextField;
-(NSString*)_soundLabelText;
-(NSString*)_musicLabelText;
-(NSString*)_pingLabelText;
-(NSString*)_localPlayerName;
-(NSString*)_serverIpAddress;
-(void)_selectOFViewType;

@end

@implementation OptionsScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	OptionsScene *layer = [OptionsScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {

		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"OptionsBackground.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
		
		CCLabelTTFx* titleLabel = [CCLabelTTFx labelWithString:@"Options" fontName:@"Marker Felt" fontSize:40];
		titleLabel.color = ccWHITE;
		titleLabel.position = ccp( winSize.width/2 , winSize.height*0.85);
		[self addChild:titleLabel z:100];
		[titleLabel setShadowWithColor:ccBLACK andOpacity:150 andOffset:CGSizeMake(1, -1)];
		
		soundLabel_ = [[CCLabelTTFx labelWithString:[self _soundLabelText] fontName:@"Marker Felt" fontSize:27] retain];
		CCMenuItemLabel *soundMenuItem = [CCMenuItemLabel itemWithLabel:soundLabel_ target:self selector:@selector(_switchSound)];
		
		musicLabel_ = [[CCLabelTTFx labelWithString:[self _musicLabelText] fontName:@"Marker Felt" fontSize:27] retain];
		CCMenuItemLabel *musicMenuItem = [CCMenuItemLabel itemWithLabel:musicLabel_ target:self selector:@selector(_switchMusic)];

		pingLabel_ = [[CCLabelTTFx labelWithString:[self _pingLabelText] fontName:@"Marker Felt" fontSize:27] retain];
		CCMenuItemLabel *pingMenuItem = [CCMenuItemLabel itemWithLabel:pingLabel_ target:self selector:@selector(_switchPing)];
		
		//CCLabelTTFx *creditsLabel_ = [CCLabelTTFx labelWithString:@"Credits" fontName:@"Marker Felt" fontSize:27];
		//CCMenuItemLabel *creditsMenuItem = [CCMenuItemLabel itemWithLabel:creditsLabel_ target:self selector:@selector(_showCredits)];
		CCMenu *menu = [CCMenu menuWithItems:soundMenuItem, musicMenuItem, pingMenuItem, /*creditsMenuItem,*/ nil];
		menu.position = ccp(winSize.width/2, winSize.height*0.32);
		[menu alignItemsVerticallyWithPadding:8];
		[self addChild:menu];
		
		CCMenuItem *quitIcon = [CCMenuItemImage itemFromNormalImage:@"home_button.png" 
													  selectedImage:@"home_button_pressed.png" target:self selector:@selector(_returnToMainMenu)];
		quitIcon.anchorPoint = ccp(0,0);
		CCMenu *quitButton = [CCMenu menuWithItems:quitIcon,nil];
		quitButton.position = ccp(0,0);
		[self addChild:quitButton];
		
		[self _addNameTextField];
		[self _addIpTextField];
		
		if ([[OpenFeintEx of] viewTypeSelectionIsAvailable]) {
			CCMenuItem *ofIcon = [CCMenuItemImage itemFromNormalImage:@"OFLogoTopCornerLeft57.png" 
														  selectedImage:@"OFLogoTopCornerLeft57.png" target:self selector:@selector(_selectOFViewType)];
			ofIcon.anchorPoint = ccp(0, 1);
			CCMenu *ofButton = [CCMenu menuWithItems:ofIcon,nil];
			ofButton.position = ccp(0, winSize.height);
			[self addChild:ofButton];			
		}
		
		self.isTouchEnabled = YES;
	}
	return self;
}

-(void)_selectOFViewType
{
	[[OpenFeintEx of] askViewTypeWithBlock:^(OpenFeintViewType viewType) {
		[GameOptions setOpenFeintViewType:viewType];
	}];
}

-(void)_addNameTextField
{
	
	CCLabelTTFx* label = [CCLabelTTFx labelWithString:@"Player name: " fontName:@"Marker Felt" fontSize:27];
	label.position =  ccp(232, 208);
	label.anchorPoint = ccp(1, 0);
	[self addChild: label];

	nameTextBackground_ = [[CCSprite node] retain];
	nameTextBackground_.color = ccBLACK;
	nameTextBackground_.opacity = 20;
	nameTextBackground_.textureRect = CGRectMake(0, 0, 206, 30);
	nameTextBackground_.anchorPoint = ccp(0,0);
	nameTextBackground_.position = label.position;
	[self addChild:nameTextBackground_];
	
	nameLabel_ = [[CCLabelTTFx labelWithString:[self _localPlayerName] fontName:@"Marker Felt" fontSize:27] retain];
	nameLabel_.color = ccWHITE;
	nameLabel_.position =  label.position;
	nameLabel_.anchorPoint = ccp(0, 0);
	[self addChild: nameLabel_];
	
	nameText_ = [[[UITextField alloc] initWithFrame:CGRectMake(120, 320, 206, 30)] retain];
	[nameText_ setDelegate:self];
	[nameText_ setText:[GameOptions localPlayerName]];
	[nameText_ setFont:[UIFont fontWithName:@"Marker Felt" size:27]];
	[nameText_ setTextColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0]];
	[[[[CCDirector sharedDirector] openGLView] window] addSubview:nameText_];
	nameText_.transform = CGAffineTransformConcat(nameText_.transform, CGAffineTransformMakeRotation(M_PI_2));
	nameText_.hidden = YES;
	
	//120 + 103 - 15 = 208 ; 320 + 15 - 103 = 232
}

-(void)_addIpTextField
{
	CCLabelTTFx* label = [CCLabelTTFx labelWithString:@"Geo domain: " fontName:@"Marker Felt" fontSize:27];
	label.position =  ccp(172, 168);
	label.anchorPoint = ccp(1, 0);
	[self addChild: label];

	ipTextBackground_ = [[CCSprite node] retain];
	ipTextBackground_.color = ccBLACK;
	ipTextBackground_.opacity = 20;
	ipTextBackground_.textureRect = CGRectMake(0, 0, 206, 30);
	ipTextBackground_.anchorPoint = ccp(0, 0);
	ipTextBackground_.position = label.position;
	[self addChild:ipTextBackground_];
	
	ipLabel_ = [[CCLabelTTFx labelWithString:[self _serverIpAddress] fontName:@"Marker Felt" fontSize:27] retain];
	ipLabel_.color = ccWHITE;
	ipLabel_.position =  label.position;
	ipLabel_.anchorPoint = ccp(0, 0);
	[self addChild: ipLabel_];
	
	ipText_ = [[[UITextField alloc] initWithFrame:CGRectMake(80, 260, 206, 30)] retain];
	[ipText_ setDelegate:self];
	[ipText_ setFont:[UIFont fontWithName:@"Marker Felt" size:27]];
	[ipText_ setText:[GameOptions mainServerDomainName]];
	[ipText_ setTextColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0]];
	[[[[CCDirector sharedDirector] openGLView] window] addSubview:ipText_];
	ipText_.transform = CGAffineTransformConcat(ipText_.transform, CGAffineTransformMakeRotation(M_PI_2));	
	ipText_.hidden = YES;

	//80 + 103 - 15 = 168; 260 + 15 - 103 = 172
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint cLoc = [[CCDirector sharedDirector] convertToGL: location];
	
	if (CGRectContainsPoint([nameTextBackground_ boundingBox], cLoc) ) {
		nameLabel_.visible = NO;
		nameText_.hidden = NO;
		[nameText_ becomeFirstResponder];
	}

	if (CGRectContainsPoint([ipTextBackground_ boundingBox], cLoc) ) {
		ipLabel_.visible = NO;
		ipText_.hidden = NO;
		[ipText_ becomeFirstResponder];
	}
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [ipText_ resignFirstResponder];
	[nameText_ resignFirstResponder];
	
	[GameOptions setLocalPlayerName:nameText_.text];
	[nameLabel_ setString:[self _localPlayerName]];
	nameLabel_.visible = YES;
	nameText_.hidden = YES;
	
	[GameOptions setMainServerDomainName:ipText_.text];
	[ipLabel_ setString:[self _serverIpAddress]];
	ipLabel_.visible = YES;
	ipText_.hidden = YES;
	
	return YES;
}
	 
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 20) ? NO : YES;
}

-(void)_switchSound
{
	[GameOptions setSoundEnabled:![GameOptions soundEnabled]];
	[soundLabel_ setString:[self _soundLabelText]];
}

-(void)_switchMusic
{
	[GameOptions setMusicEnabled:![GameOptions musicEnabled]];
	[musicLabel_ setString:[self _musicLabelText]];
}

-(void)_switchPing
{
	[GameOptions setPingEnabled:![GameOptions pingEnabled]];
	[pingLabel_ setString:[self _pingLabelText]];
}


//-(void)_showCredits
//{
//}

-(NSString*)_localPlayerName
{
	return [[GameOptions localPlayerName] truncatedStringToWidth:206 
														   withFont:[UIFont fontWithName:@"Marker Felt" size:27]];
}	 

-(NSString*)_serverIpAddress
{
	return [[GameOptions mainServerDomainName] truncatedStringToWidth:206 
														   withFont:[UIFont fontWithName:@"Marker Felt" size:27]];
}	 

-(void)_returnToMainMenu
{
	[self hideAd];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInB transitionWithDuration:0.5 scene:[HomeScene scene]]];	
}

-(NSString*)_soundLabelText
{
	return [NSString stringWithFormat:@"FX Sound %@", [GameOptions soundEnabled] ? @"On" : @"Off"];
}

-(NSString*)_musicLabelText
{
	return [NSString stringWithFormat:@"Music %@", [GameOptions musicEnabled] ? @"On" : @"Off"];
}

-(NSString*)_pingLabelText
{
	return [NSString stringWithFormat:@"Ping %@", [GameOptions pingEnabled] ? @"On" : @"Off"];
}

-(void)dealloc
{
	[ipText_ release];
	[nameText_ release];
	[soundLabel_ release];
	[pingLabel_ release];
	[nameTextBackground_ release];
	[nameLabel_ release];
	[ipTextBackground_ release];
	[ipLabel_ release];

	[super dealloc];
}

#pragma mark SceneWithAd overrides

-(NSString*)getZone {
	return @"0457947379042204545";
}

-(CGPoint)getAnchorPoint
{
	return CGPointMake(0.54, 0);
}

@end
