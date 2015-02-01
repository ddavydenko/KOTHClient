//
//  SocialGamingProvider.m
//  KOTH
//
//  Created by Denis Davydenko on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OpenFeintEx.h"
#import "OpenFeint.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Dashboard.h"
#import "OpenFeint+GameCenter.h"
#import "GameCenter.h"
#import "OFHighScoreService.h"
#import "OFLeaderboard.h"


@interface OFCustomDelegate : NSObject<OpenFeintDelegate> {

@private
	
	id target_;
	SEL authChangedSelector_;
	SEL dashboardClosedSelector_;
	SEL gcAuthCompleteSelector_;
}

-(id)initWithAuthTarget:(id)target 
 andAuthChangedSelector:(SEL)authChangedSelector 
andDashboardClosedSelector:(SEL)dashboardClosedSelector
andGCAuthCompleteSelector:(SEL)gcAuthCompleteSelector;

- (void)dashboardWillAppear;
- (void)dashboardDidAppear;
- (void)dashboardWillDisappear;
- (void)dashboardDidDisappear;
- (void)offlineUserLoggedIn:(NSString*)userId;
- (void)userLoggedIn:(NSString*)userId;
- (void)userLoggedOut:(NSString*)userId;
- (BOOL)showCustomOpenFeintApprovalScreen;
- (BOOL)showCustomScreenForAnnouncement:(OFAnnouncement*)announcement;

@end  

@implementation OFCustomDelegate

-(id)initWithAuthTarget:(id)target 
 andAuthChangedSelector:(SEL)authChangedSelector 
andDashboardClosedSelector:(SEL)dashboardClosedSelector
andGCAuthCompleteSelector:(SEL)gcAuthCompleteSelector
{
	if ((self = [super init])) {
		target_ = target;
		authChangedSelector_ = authChangedSelector;
		dashboardClosedSelector_ = dashboardClosedSelector;
		gcAuthCompleteSelector_ = gcAuthCompleteSelector;
	}
	return self;
}


- (void)dashboardWillAppear
{
}

- (void)dashboardDidAppear
{
}

- (void)dashboardWillDisappear
{
}

- (void)dashboardDidDisappear
{
	[target_ performSelector:dashboardClosedSelector_];
}

- (void)offlineUserLoggedIn:(NSString*)userId
{
	NSLog(@"Open Feint user logged in, but OFFLINE. UserId: %@, name: %@", userId, [[OpenFeint localUser] name]);
	[target_ performSelector:authChangedSelector_];
}

- (void)userLoggedIn:(NSString*)userId
{
	NSLog(@"Open Feint user logged in. UserId: %@, name: %@", userId, [[OpenFeint localUser] name]);
	[target_ performSelector:authChangedSelector_];
}

- (void)userLoggedOut:(NSString*)userId
{
	NSLog(@"Open Feint user logged out");
	[target_ performSelector:authChangedSelector_];
}

- (BOOL)showCustomOpenFeintApprovalScreen
{
	return NO;
}

- (BOOL)showCustomScreenForAnnouncement:(OFAnnouncement*)announcement
{
	return NO;
}

-(void)gcAuthComplete
{
	NSLog(@"Game Center auth complete");
	[target_ performSelector:gcAuthCompleteSelector_];
}

@end

@interface OpenFeintEx(Private)

-(void)_initOpenFeint;
-(void)_initGameCenter:(UIViewController*)controller;
-(void)_invokeAskViewTypeBlock;
-(void)_checkLoggedUser;
-(NSString*)_OFLeaderboardIdByGCCategory:(NSString*)gcCategory;
-(void)_scoreWasSubmited;
-(void)_dashboardClosed;

@end


@implementation OpenFeintEx

static OpenFeintEx *instance_ = nil;

+(OpenFeintEx*)of 
{
	@synchronized(self)
	{
		if (instance_ == nil) {
			instance_ = [self new];
		}
	}
	return instance_;
}

-(id)init
{
	if ((self = [super init])) {
		viewType_ = ofvtNone;
		askViewTypeBlock_ = nil;
		userLogsInBlock_ = nil;
		ofIsInited_ = FALSE;
	}
	return self;
}

-(void)initializeWithProductKey:(NSString*)productKey
					  andSecret:(NSString*)secret
				 andDisplayName:(NSString*)displayName
			andShortDisplayName:(NSString*)shortDisplayName
			   andUIOrientation:(UIInterfaceOrientation)uiOrientation
	andGameCenterViewController:(UIViewController*)controller
			  withCompleteBlock:(VoidBlock)block
{
	if (ofIsInited_)
		return;
	
	productKey_ = productKey;
	secret_ = secret;
	displayName_ = displayName;
	shortDisplayName_ = shortDisplayName;
	uiOrientation_ = uiOrientation;
	
	initCompleteBlock_ = (VoidBlock)_Block_copy(block);
	
	[self _initOpenFeint];

	[self _initGameCenter:controller];

	ofIsInited_ = YES;
}

-(void)applicationWillResignActive
{
	[OpenFeint applicationWillResignActive];
}
-(void)applicationDidBecomeActive
{
	[OpenFeint applicationDidBecomeActive];
}
-(void)shutdown
{
	[OpenFeint shutdown];
}

-(bool)canReceiveCallbacksNow
{
	return true;
}

-(OpenFeintViewType)viewType
{
	return viewType_;
}

-(void)setViewType:(OpenFeintViewType)viewType
{	
	if (viewType_ != viewType && viewType != ofvtNone) {
		viewType_ = viewType;
		
		if (viewType_ == ofvtGameCenter && ![GameCenter gc].isEnabled) {
			viewType_ = ofvtOpenFeint;
		}
	} 
}

-(void)askViewTypeWithBlock:(AskViewTypeBlock)block
{
	NSAssert(!askViewTypeBlock_, @"askViewTypeBlock_ should be nil");
	askViewTypeBlock_ = (AskViewTypeBlock)_Block_copy(block);

	if (![self viewTypeSelectionIsAvailable]) {
		[self setViewType:ofvtOpenFeint];
		[self _invokeAskViewTypeBlock];
		return;
	}

	UIAlertView *askAlert = [[UIAlertView alloc] initWithTitle:@"Select Default View" message:@"Please select your preffered service for viewing Leaderboards. Data is still uploaded in both services." delegate:self 
											 cancelButtonTitle:@"OpenFeint" otherButtonTitles:@"Game Center", nil];
	[askAlert show];
	[askAlert release];
}

-(BOOL)viewTypeSelectionIsAvailable
{
	return [GameCenter gc].isEnabled;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self setViewType:buttonIndex == 0 ? ofvtOpenFeint : ofvtGameCenter];
	[self _invokeAskViewTypeBlock];
}

-(void)waitUserLogsInWithBlock:(UserLogsInBlock)block
{
	if (userLogsInBlock_) {
		_Block_release(userLogsInBlock_);
	}
	userLogsInBlock_ = (UserLogsInBlock)_Block_copy(block);
	
	[self _checkLoggedUser];
}

-(void)ensureApprovedWithBlock:(VoidBlock)block
{
	if (viewType_ == ofvtGameCenter) {
		[[GameCenter gc] ensureAuthenticatedWithBlock:block];
		return;
	}
	
	if ([OpenFeint hasUserApprovedFeint]) {
		block();
	}
	else {
		_Block_release(approvalResultBlock_);
		approvalResultBlock_ = (VoidBlock)_Block_copy(block);
		OFDelegate approvedDelegate(self, @selector(_OFApprovedResult));
		OFDelegate deniedDelegate(self, @selector(_OFDeniedResult));
		[OpenFeint presentUserFeintApprovalModal:approvedDelegate deniedDelegate:deniedDelegate];
	}
}

-(void)showDefaultLeaderboard
{
	if (viewType_ == ofvtGameCenter) {
		[[GameCenter gc] ensureAuthenticatedWithBlock:^{
			[[GameCenter gc] showLeaderboardForCategory:nil withBlock:nil];
		}];
	}else {
		[OpenFeint launchDashboardWithListLeaderboardsPage];
	}
}

-(void)showLeaderboardByCGCategory:(NSString*)category
{
	if (viewType_ == ofvtGameCenter) {
		[[GameCenter gc] ensureAuthenticatedWithBlock:^{
			[[GameCenter gc] showLeaderboardForCategory:category withBlock:nil];
		}];
	}else {
		NSString *ofLeaderboardId = [self _OFLeaderboardIdByGCCategory:category];
		[OpenFeint launchDashboardWithHighscorePage:ofLeaderboardId];
	}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
}

-(void)updateLocalPlayerScoreBy:(int)delta forGCCategory:(NSString*)categoryName withBlock:(VoidBlock)block
{
	[self loadScoreForLocalPlayerForGCCategory:categoryName withBlock:^(int64_t score){
		[self submitScore:score + delta forGCCategory:categoryName withBlock:block];
	}];
}

-(void)loadScoreForLocalPlayerForGCCategory:(NSString*)categoryName withBlock:(Int64Block)block
{
	if ([OpenFeint hasUserApprovedFeint]) {	
		OFHighScore *score = [[OFLeaderboard leaderboard:[self _OFLeaderboardIdByGCCategory:categoryName]] highScoreForCurrentUser];
		block(score.score);
	}else {
		if ([GameCenter gc].isAuthenticated) {
			[[GameCenter gc] loadScoreForLocalPlayerForCategory:categoryName withBlock:block];
		}
	}
}

-(void)submitScore:(int64_t)score forGCCategory:(NSString*)categoryName withBlock:(VoidBlock)block;
{
	if (submitScoreBlock_) 
		_Block_release(submitScoreBlock_);
	submitScoreBlock_ = (VoidBlock)_Block_copy(block);

	[OFHighScoreService setHighScore:score forLeaderboard:[self _OFLeaderboardIdByGCCategory:categoryName] silently:YES
							onSuccess:OFDelegate(self, @selector(_scoreWasSubmited)) onFailure:OFDelegate()];

	if ([OpenFeint hasUserApprovedFeint] && [GameCenter gc].isAuthenticated) {
		[[GameCenter gc] submitScore:score forCategory:categoryName withBlock:^ {
			if (viewType_ == ofvtGameCenter && block) {
				block();
			}
		}];
	}
}

-(void)_scoreWasSubmited
{
	if ([OpenFeint hasUserApprovedFeint] && [GameCenter gc].isAuthenticated && viewType_ == ofvtGameCenter) {
		return;
	}
	
	if (submitScoreBlock_) {
		submitScoreBlock_();
	}
}

-(void)_initOpenFeint
{	
	NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:uiOrientation_], OpenFeintSettingDashboardOrientation,
							  shortDisplayName_, OpenFeintSettingShortDisplayName,
							  [NSNumber numberWithBool:YES], OpenFeintSettingGameCenterEnabled,
							  nil
							  ];
	
	OFCustomDelegate *delegate = [[OFCustomDelegate alloc] initWithAuthTarget:self 
													   andAuthChangedSelector:@selector(_checkLoggedUser) 
												   andDashboardClosedSelector:@selector(_dashboardClosed)
													andGCAuthCompleteSelector:@selector(_gcAuthComplete)];
	
	[OpenFeint initializeWithProductKey:productKey_
							  andSecret:secret_
						 andDisplayName:displayName_
							andSettings:settings
						   andDelegates:[OFDelegatesContainer containerWithOpenFeintDelegate:delegate]];
}

-(void)_initGameCenter:(UIViewController*)controller
{
	NSLog([GameCenter gc].isEnabled ? @"Game Center is used" : @"Game Center isn't used");
	
	if ([GameCenter gc].isEnabled) {
		[[GameCenter gc] setController:controller];
		[[GameCenter gc] waitAuthenticationChangedWithBock:^(BOOL isAuthenticated){
			NSLog(@"Game Center auth changed. %@", 
				  isAuthenticated ? 
				  [NSString stringWithFormat:@"User %@ logged in", [GameCenter gc].playerName] : 
				  @"user logged out");
			
			[self _checkLoggedUser];
		}];
	}
	
	NSString* mappingPath = [[NSBundle mainBundle] pathForResource:@"OFGameCenter" ofType:@"plist"];
	OFToGCmappings_ = [[NSDictionary alloc] initWithContentsOfFile:mappingPath];
}

-(NSString*)_OFLeaderboardIdByGCCategory:(NSString*)gcCategory
{
	NSAssert(OFToGCmappings_,@"OFToGCmappings_ is nil");
	NSDictionary *leaderboardsMap = [OFToGCmappings_ objectForKey:@"Leaderboards"];
	NSArray *OFleaderboards = [leaderboardsMap allKeysForObject:gcCategory];
	if (!OFleaderboards || [OFleaderboards count] == 0)
		return nil;
	
	return [OFleaderboards objectAtIndex:0];
}

-(void)_checkLoggedUser
{
	if (userLogsInBlock_) {		
		if ((viewType_ == ofvtOpenFeint || viewType_ == ofvtNone) && [OpenFeint hasUserApprovedFeint]) {
			userLogsInBlock_([[OpenFeint localUser] name]);
			return;
		}
		
		if ([GameCenter gc].isEnabled && [GKLocalPlayer localPlayer].isAuthenticated) {
			userLogsInBlock_([[GKLocalPlayer localPlayer] alias]);
		}
	}
}

-(void)_dashboardClosed
{
	if (![OpenFeint isUsingGameCenter] && initCompleteBlock_) {
		initCompleteBlock_();
		_Block_release(initCompleteBlock_);
		initCompleteBlock_ = nil;
	}
}

-(void)_gcAuthComplete
{
	if ([OpenFeint isUsingGameCenter] && initCompleteBlock_) {
		initCompleteBlock_();
		_Block_release(initCompleteBlock_);
		initCompleteBlock_ = nil;
	}
}

-(void)_invokeAskViewTypeBlock
{
	if (askViewTypeBlock_)
	{
		askViewTypeBlock_(viewType_);
		_Block_release(askViewTypeBlock_);
		askViewTypeBlock_ = nil;
	}
}

-(void)_OFApprovedResult{
	if (approvalResultBlock_) {
		approvalResultBlock_();
		_Block_release(approvalResultBlock_);
		approvalResultBlock_ = nil;
	}
}

-(void)_OFDeniedResult{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Could not connect to OpenFeint." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)dealloc
{
	_Block_release(userLogsInBlock_);
	_Block_release(submitScoreBlock_);
	_Block_release(initCompleteBlock_);
	_Block_release(approvalResultBlock_);
	
	[OFToGCmappings_ release];
	[super dealloc];
}


@end
