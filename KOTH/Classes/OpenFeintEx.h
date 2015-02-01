//
//  SocialGamingProvider.h
//  KOTH
//
//  Created by Denis Davydenko on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tools.h"
#import "OFCallbackable.h"

typedef enum {
	ofvtNone = 0,
	ofvtOpenFeint = 1,
	ofvtGameCenter = 2
}OpenFeintViewType;

typedef void(^AskViewTypeBlock)(OpenFeintViewType viewType);
typedef void(^UserLogsInBlock)(NSString* userName);

@interface OpenFeintEx : NSObject<OFCallbackable> {

@private
	NSString *productKey_;
	NSString *secret_;
	NSString *displayName_;
	NSString *shortDisplayName_;
	UIInterfaceOrientation uiOrientation_;
	BOOL ofIsInited_;
	
	OpenFeintViewType viewType_;
	AskViewTypeBlock askViewTypeBlock_;
	UserLogsInBlock userLogsInBlock_;
	VoidBlock submitScoreBlock_;
	VoidBlock initCompleteBlock_;
	VoidBlock approvalResultBlock_;
	
	NSDictionary *OFToGCmappings_;
}

@property (nonatomic) OpenFeintViewType viewType;

+(OpenFeintEx*)of;

-(void)initializeWithProductKey:(NSString*)productKey 
					  andSecret:(NSString*)secret 
				 andDisplayName:(NSString*)displayName
			andShortDisplayName:(NSString*)shortDisplayName 
			   andUIOrientation:(UIInterfaceOrientation)uiOrientation 
	andGameCenterViewController:(UIViewController*)controller 
			  withCompleteBlock:(VoidBlock)block;

-(void)applicationWillResignActive;
-(void)applicationDidBecomeActive;
-(void)shutdown;
-(bool)canReceiveCallbacksNow;

-(void)askViewTypeWithBlock:(AskViewTypeBlock)block;
-(void)waitUserLogsInWithBlock:(UserLogsInBlock)block;
-(void)ensureApprovedWithBlock:(VoidBlock)block;

-(void)showDefaultLeaderboard;
-(void)showLeaderboardByCGCategory:(NSString*)category;

-(void)updateLocalPlayerScoreBy:(int)delta forGCCategory:(NSString*)categoryName withBlock:(VoidBlock)block;
-(void)loadScoreForLocalPlayerForGCCategory:(NSString*)categoryName withBlock:(Int64Block)block;
-(void)submitScore:(int64_t)score forGCCategory:(NSString*)categoryName withBlock:(VoidBlock)block;

-(BOOL)viewTypeSelectionIsAvailable;

@end
