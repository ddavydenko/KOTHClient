//
//  GameCenter.h
//  KOTH
//
//  Created by Denis Davydenko on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameKit/GameKit.h"
#import "Tools.h"

@interface GameCenter : NSObject<GKLeaderboardViewControllerDelegate> {

@private
	bool enabled_;
	bool authenticated_;
	NSString *playerId_;
	NSString *playerName_;
	
	UIViewController *controller_;
	VoidBlock showLeaderboardBlock_;
	BOOLBlock authChangedBock_;
	
}

+(GameCenter*) gc;

@property(nonatomic, readonly, getter=isEnabled)  bool enabled;
@property(nonatomic, readonly, getter=isAuthenticated)  bool authenticated; // Authentication state
@property(nonatomic, readonly) NSString* playerId;
@property(nonatomic, readonly) NSString* playerName;
@property(nonatomic, retain) UIViewController *controller;


-(void)authenticateWithBlock:(BOOLBlock)block;
-(void)ensureAuthenticatedWithBlock:(VoidBlock)block;
-(void)waitAuthenticationChangedWithBock:(BOOLBlock)block;
-(void)submitScore:(int64_t)score forCategory:(NSString*)categoryName withBlock:(VoidBlock)block;
-(void)showLeaderboardForCategory:(NSString*)categoryName withBlock:(VoidBlock)block;
-(void)loadScoreForLocalPlayerForCategory:(NSString*)categoryName withBlock:(Int64Block)block;
-(void)waitAuthenticationChangedWithTarget:(id)target andSelector:(SEL)selector;

@end
