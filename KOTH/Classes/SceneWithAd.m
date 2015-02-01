//
//  SceneWithAd.m
//  KOTH
//
//  Created by denis davydenko on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BurstlyManager.h"
#import "SceneWithAd.h"
#import "Cocos2dViewController.h"

@interface SceneWithAd(Private)

-(void)_addAdView:(UIView*) view;

@end


@implementation SceneWithAd

-(id)init
{
	if (( self = [super init] ))
	{
#ifdef USE_BURSTLY
		manager_ = [[BurstlyManager instance] getManager:[self getZone] withAnchor:[self getAnchorPoint]];
		[self performSelector:@selector(_addAdView:) withObject:manager_.view afterDelay:.8f];
		[manager_ setPaused:NO];
		[manager_ requestRefreshAd];
#endif
	}
	
	return self;
}

/*
 This method should be overriden in children
 to adjust positioning of ads on individual screens
 */
-(CGPoint)getAnchorPoint
{
	return CGPointMake(0.63, 0);
}

-(void)hideAd
{
#ifdef USE_BURSTLY
	[manager_ setPaused:YES];
	[manager_.view removeFromSuperview];
#endif
}

/* 
 This method has to be overriden in children 
 to use different zones for every individual screen of the game.
 See burstly.com admin tool for available zones
*/
-(NSString*)getZone {
	return @"0255947679042204545"; // this is default zone
}

//---------PRIVATE----------

-(void)_addAdView:(UIView*) view
{
	[[Cocos2dViewController currentController].view addSubview:view];
}

-(void)dealloc
{
	[super dealloc];
}

@end
