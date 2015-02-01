//
//  BurstlyManager.h
//  KOTH
//
//  Created by denis davydenko on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAIAdManager.h"

@interface BurstlyManager : NSObject {

@private
	NSMutableDictionary* adManagers_;
	NSMutableDictionary* adDelegates_;
}

+(BurstlyManager*)instance;

-(OAIAdManager*)getManager:(NSString*)zoneId withAnchor:(CGPoint)anchor;
@end
