//
//  OptionsScene.h
//  KOTH
//
//  Created by Denis Davydenko on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLabelTTFx.h"
#import "SceneWithAd.h"

@interface OptionsScene : SceneWithAd<UITextFieldDelegate> {

@private
	
	CCLabelTTFx *soundLabel_;
	CCLabelTTFx *musicLabel_;
	CCLabelTTFx *pingLabel_;
	UITextField *ipText_;
	UITextField *nameText_;
	
	CCSprite *nameTextBackground_;
	CCLabelTTFx *nameLabel_;

	CCSprite *ipTextBackground_;
	CCLabelTTFx *ipLabel_;

}

+(id) scene;

@end
