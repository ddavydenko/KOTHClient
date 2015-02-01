//
//  JumperScene.h
//  Jumper_Threads
//
//  Created by Igor Nikolaev on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScene.h"
#import "Platform.h"

@interface JumpScene : GameScene {

@private
	
	float sendAccelX_;
	Platform *platform_;
}

+(id)scene:(BOOL)switchFromFight;

-(id)init:(BOOL)switchFromFight;

@end
