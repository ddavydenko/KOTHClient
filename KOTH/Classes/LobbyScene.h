//
//  LobbyScene.h
//  Jumper_iOS3
//
//  Created by svp on 04.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLabelTTFx.h"
#import "SceneWithAd.h"

@interface LobbyScene : SceneWithAd {

	CCLabelTTFx* connectingLabel_;
	CCMenu *roomsMenu_;
}

+(id) scene;

@end
