//
//  TargetedAction.h
//  KOTH
//
//  Created by denis davydenko on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface TargetedAction : CCActionInterval
{
	id forcedTarget;
	CCFiniteTimeAction* action;
}

+ (id) actionWithTarget:(id) target action:(CCFiniteTimeAction*) action;

- (id) initWithTarget:(id) target action:(CCFiniteTimeAction*) action;

@end
