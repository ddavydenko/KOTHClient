//
//  RootViewController.m
//  KOTH
//
//  Created by Denis Davydenko on 10/19/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//


#import "cocos2d.h"

#import "Cocos2dViewController.h"
#import "GameConfig.h"

@implementation Cocos2dViewController

static Cocos2dViewController *currentController;

+(Cocos2dViewController*)currentController
{
	@synchronized(self)
	{
		if (currentController == nil) {
			currentController = [[Cocos2dViewController alloc] initWithNibName:nil bundle:nil];
			currentController.wantsFullScreenLayout = YES;
		}
	}
	return currentController;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {

    [super dealloc];
}


@end
