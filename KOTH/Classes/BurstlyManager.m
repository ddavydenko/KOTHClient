//
//  BurstlyManager.m
//  KOTH
//
//  Created by denis davydenko on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BurstlyManager.h"
#import "BurstlyDelegateItem.h"

@implementation BurstlyManager

static BurstlyManager* instance_ = nil;

+(BurstlyManager*)instance
{
	@synchronized(self)
	{
		if (!instance_) {
			instance_ = [[self alloc] init];
		}
	}
	return instance_;
}

-(id)init
{
	if ((self = [super init])) {
		
		adManagers_ = [[NSMutableDictionary alloc] init];
		adDelegates_ = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(OAIAdManager*)getManager:(NSString*)zoneId withAnchor:(CGPoint)anchor
{
	OAIAdManager* result = [adManagers_ objectForKey:zoneId];
	if (result == nil)
	{
		BurstlyDelegateItem* bitem = [[BurstlyDelegateItem alloc] initWithZoneId:zoneId andWithAnchor:anchor];
		result = [[OAIAdManager alloc] initWithDelegate:bitem];
		[adManagers_ setObject:result forKey:zoneId];
		[adDelegates_ setObject:bitem forKey:zoneId];
	}
	
	return result;
}

-(void)dealloc
{
	[adManagers_ release];
	[adDelegates_ release];
	[super dealloc];
}

@end
