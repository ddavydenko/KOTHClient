//
//  GameScene.h
//  KOTH
//
//  Created by Denis Davydenko on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>
#import	"GameController.h"
#import "EnvironmentLayer.h"
#import "Player.h"

@interface GameScene : CCLayer {

	EnvironmentLayer *board_;

}

-(GameSceneType)sceneType;
-(void)addGameLayouts;

@end
