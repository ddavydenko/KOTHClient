//
//  PlayerColor.h
//  KOTH
//
//  Created by Denis Davydenko on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	pcNone = 0,
	pcGray = 1,
	pcBlue = 2,
	pcRed = 3,
	pcBlack = 4,
}PlayerColor;

static inline
NSString* getColorFilePrefix(PlayerColor color)
{
	switch (color) {
		case pcGray:
			return @"gray";
		case pcBlue:
			return @"blue";
		case pcRed:
			return @"red";
		case pcBlack:
			return @"black";
		default:
			break;
	}
	return nil;
}