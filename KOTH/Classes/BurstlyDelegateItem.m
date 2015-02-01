//
//  BurstlyDelegateItem.m
//  KOTH
//
//  Created by denis davydenko on 1/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BurstlyDelegateItem.h"
#import "Cocos2dViewController.h"


@implementation BurstlyDelegateItem

-(id)initWithZoneId:(NSString*)zoneId andWithAnchor:(CGPoint)anchor
{
	if (( self = [super init] ))
	{
		zoneId_ = [zoneId copy];
		anchor_ = anchor;
	}
	return self;
}


#pragma mark OAIAdManagerDelegate protocol implementation

-(NSString*)publisherId {
	return @"RwP0lLuXo0KZYb754H7ztA";
}

-(NSString*)getZone {
	return zoneId_;
}

-(UIViewController*)viewControllerForModalPresentation {
	return [Cocos2dViewController currentController];
}

-(Anchor)anchor {
	return Anchor_Bottom;
}

-(CGPoint)anchorPoint {
	return CGPointMake([Cocos2dViewController currentController].view.bounds.size.width * anchor_.x, 
					   [Cocos2dViewController currentController].view.bounds.size.height * (1.0 - anchor_.y));
}

-(BOOL)respondsToInterfaceOrientation
{
	return NO;
}

-(UIInterfaceOrientation)currentOrientation
{
	return UIInterfaceOrientationLandscapeRight;
}

-(void)dealloc
{
	[zoneId_ release];
	[super dealloc];
}

@end
