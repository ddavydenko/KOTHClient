//
//  BurstlyDelegateItem.h
//  KOTH
//
//  Created by denis davydenko on 1/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAIAdManager.h"
#import "OAIAdManagerDelegateProtocol.h"


@interface BurstlyDelegateItem : NSObject<OAIAdManagerDelegate> {

@private
	NSString* zoneId_;
	CGPoint anchor_;
}

-(id)initWithZoneId:(NSString*)zoneId andWithAnchor:(CGPoint)anchor;

@end
