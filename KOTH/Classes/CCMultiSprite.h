//
//  CCMultiSprite.h
//  KOTH
//
//  Created by Denis Davydenko on 11/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface CCMultiSprite : CCSprite {

@private
	CCSprite *currentSprite_;
	
}

@property (nonatomic) int currentSpriteTag;
@property (nonatomic, readonly) CCSprite *currentSprite;

-(void)addChild:(CCSprite *)child tag:(int)aTag;

@end
