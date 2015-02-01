//
//  GameCenter.m
//  KOTH
//
//  Created by Denis Davydenko on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameCenter.h"
#import "cocos2d.h"

@interface GameCenter(Private)

-(BOOL)_isGameCenterAvailable;
-(void)_authenticationChanged;
-(void)_updateOrientation;

@end

@implementation GameCenter

@synthesize enabled = enabled_;
@synthesize authenticated = authenticated_;
@synthesize playerId = playerId_;
@synthesize playerName = playerName_;
@synthesize controller = controller_;

static GameCenter *gameCenter;

+(GameCenter*) gc
{
	if (!gameCenter) {
		@synchronized(self)
		{
			if (!gameCenter) {
				gameCenter = [[GameCenter alloc] init];
			}
		}
	}
	return gameCenter;
}

-(id)init
{
	if ((self = [super init]))
	{
		enabled_ = [self _isGameCenterAvailable];
		if (enabled_) {
			[self waitAuthenticationChangedWithTarget:self andSelector:@selector(_authenticationChanged)];
		}
	}
	return self;
}

-(void)authenticateWithBlock:(BOOLBlock)block;
{
	if (!enabled_)
		return;

	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
		if (error == nil)
		{
			[self _authenticationChanged];	
			NSLog(@"Game Center: Player Authenticated!");

			if (block) {
				block(YES);
			}
		}
		else
		{
			NSLog(@"Game Center: Authentication Failed!");
			if (block) {
				block(NO);
			}
		}
	}];	
}

-(void)waitAuthenticationChangedWithTarget:(id)target andSelector:(SEL)selector
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:target selector:selector name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}

-(void)waitAuthenticationChangedWithBock:(BOOLBlock)block
{
	if (authChangedBock_) {
		_Block_release(authChangedBock_);
	}
	authChangedBock_ = _Block_copy(block);
}

-(void)ensureAuthenticatedWithBlock:(VoidBlock)block
{
	if (authenticated_)
	{
		block();
	}
	else {
		[self authenticateWithBlock:^(BOOL result)
		 {
			 if (result) {
				 block();
			 }else {
				 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Could not connect to Game Center server." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
				 [alert show];
				 [alert release];
			 }
		 }];
	}
}

-(void)submitScore:(int64_t)score forCategory:(NSString*)categoryName withBlock:(VoidBlock)block
{
	if (!enabled_ && !authenticated_)
		return;
	
	NSAssert(categoryName, @"categoryName is nil");
	
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:categoryName] autorelease];
    scoreReporter.value = score;
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
		if (error)
		{
            NSLog(@"Failed to submit score - %d to Game Center for category - %@", (int)score, categoryName);
        }else 
		{
			NSLog(@"Submit score %d for player %@ to category %@", (int)score, playerName_, categoryName);
			if (block) {
				block();
			}
		}
    }];
}

-(void)loadScoreForLocalPlayerForCategory:(NSString*)categoryName withBlock:(Int64Block)block
{
	if (!enabled_ && !authenticated_)
		return;

	GKLeaderboard *leaderboardRequest = [[[GKLeaderboard alloc] initWithPlayerIDs: 
										  [NSMutableArray arrayWithObjects: playerId_, nil]] autorelease];
	
    if (leaderboardRequest != nil)
    {
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardRequest.category = categoryName;
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) 
		{
            if (error != nil) {
				NSLog(@"Failed to load score for player %@ for category %@ from Game Center", playerName_, categoryName);
			}else {
				if (scores != nil && [scores count] > 0) {
					GKScore *score = [scores objectAtIndex:0];
					if (block) {
						block(score.value);
					};
				}else {
					block(0);
				}
			}
		}];
    }
}

-(void)showLeaderboardForCategory:(NSString*)categoryName withBlock:(VoidBlock)block
{
	if (!enabled_)
		return;
	
	NSAssert(controller_, @"specify controller property at first");	
	
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil)
    {
		if (block) {
			showLeaderboardBlock_ = _Block_copy(block);
		}
        leaderboardController.leaderboardDelegate = self;
		leaderboardController.category = categoryName;
        [controller_ presentModalViewController: leaderboardController animated: YES];
    }
}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
	NSAssert(controller_, @"specify controller property at first");
    [controller_ dismissModalViewControllerAnimated:YES];
//	[self _updateOrientation];
	if (showLeaderboardBlock_) {
		showLeaderboardBlock_();
		_Block_release(showLeaderboardBlock_);
		showLeaderboardBlock_ = nil;
	}
}

-(void)_updateOrientation
{
	ccDeviceOrientation orientation = [[CCDirector sharedDirector] deviceOrientation]; 
	switch( orientation) {
		case CCDeviceOrientationPortrait:
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated:NO];
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			[[UIApplication sharedApplication] setStatusBarOrientation: UIDeviceOrientationPortraitUpsideDown animated:NO];
			break;
		case CCDeviceOrientationLandscapeLeft:
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated:NO];
			break;
		case CCDeviceOrientationLandscapeRight:
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft animated:NO];
			break;
		}
}

-(void)_authenticationChanged
{
	authenticated_ = [GKLocalPlayer localPlayer].isAuthenticated;
	
	if (authenticated_) {
		[playerId_ release];
		playerId_ = [[GKLocalPlayer localPlayer].playerID retain];	
		[playerName_ release];
		playerName_ = [[GKLocalPlayer localPlayer].alias retain];
	}
	
	if (authChangedBock_) {
		authChangedBock_(authenticated_);
	}
}

-(BOOL)_isGameCenterAvailable
{
    // Check for presence of GKLocalPlayer API.	
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
    return (gcClass && osVersionSupported);
}

-(void)dealloc
{
	[playerId_ release];
	[playerName_ release];
	[controller_ release];
	_Block_release(authChangedBock_);
	[super dealloc];
}

@end
