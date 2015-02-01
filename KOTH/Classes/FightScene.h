
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GameScene.h"
#import <Foundation/Foundation.h>

@interface FightScene : GameScene
{

@private
	
	CCSprite *leftArrow_;
	CCSprite *rightArrow_;
	CCMenu *fightButton_;

	BOOL isMovingToLeft_;
	BOOL isMovingToRight_;
}

+(id) scene;

@end
