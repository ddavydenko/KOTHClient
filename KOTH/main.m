//
//  main.m
//  KOTH
//
//  Created by Denis Davydenko on 10/19/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
	srand(time(NULL));

	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	int retVal = UIApplicationMain(argc, argv, nil, @"KOTHAppDelegate");
	[pool release];
	return retVal;
}
