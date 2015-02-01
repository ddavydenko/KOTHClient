//
//  GameOverLayer.h
//  Jumper_iOS3
//
//  Created by Denis Davydenko on 10/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PlayerColor.h"
#import "SceneWithAd.h"

@interface GameOverScene : SceneWithAd {
	NSString *winsCategoryName_;
	NSString *punchesCategoryName_;
	NSString *timeCategoryName_;
	int gameLengthInMins_;
	int roomCapacity_;
	int localPlayerTime_;
	int localPlayerPunches_;
	BOOL localPlayerIsWinner_;
	BOOL winsIsSubmited_;
	BOOL scoresIsSubmited_;
}

+(id)sceneWithTime:(int)gameLengthInMins andRoomCapacity:(int)roomCapacity
	andWinnerName:(NSString*)winnerName andWinnerColor:(PlayerColor)winnerColor 
	andWinnerTime:(int)winnerTime andWinnerPunches:(int)winnerPunches 
	andLocalPlayerTime:(int)localPlayerTime andLocalPlayerPunches:(int)localPlayerPunches 
	localPlayerIsWinner:(BOOL)localPlayerIsWinner;

-(id)initWithTime:(int)gameLengthInMins andRoomCapacity:(int)roomCapacity
	andWinnerName:(NSString*)winnerName andWinnerColor:(PlayerColor)winnerColor 
	andWinnerTime:(int)winnerTime andWinnerPunches:(int)winnerPunches 
	andLocalPlayerTime:(int)localPlayerTime andLocalPlayerPunches:(int)localPlayerPunches 
	localPlayerIsWinner:(BOOL)localPlayerIsWinner;


@end
