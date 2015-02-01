//
//  TargetedAction.m
//  KOTH
//
//  Created by denis davydenko on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TargetedAction.h"

@implementation TargetedAction

+ (id) actionWithTarget:(id) target action:(CCFiniteTimeAction*) action
{
	return [[[self alloc] initWithTarget:target action:action] autorelease];
}

- (id) initWithTarget:(id) targetIn action:(CCFiniteTimeAction*) actionIn
{
	if(nil != (self = [super initWithDuration:actionIn.duration]))
	{
		forcedTarget = [targetIn retain];
		action = [actionIn retain];
	}
	return self;
}

- (void) dealloc
{
	[forcedTarget release];
	[action release];
	[super dealloc];
}

- (void) startWithTarget:(id)aTarget
{
	[super startWithTarget:forcedTarget];
	[action startWithTarget:forcedTarget];
}

- (void) stop
{
	[action stop];
	[super stop];
}

- (void) update:(ccTime) time
{
	[action update:time];
}

@end
