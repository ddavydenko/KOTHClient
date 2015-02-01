//
//  SceneWithAd.h
//  KOTH
//
//  Created by denis davydenko on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "OAIAdManager.h"

#define USE_BURSTLY

@interface SceneWithAd : CCLayer
{

@private
	OAIAdManager *manager_;
	
}

-(CGPoint)getAnchorPoint;
-(void)hideAd;
-(NSString*)getZone;

@end
