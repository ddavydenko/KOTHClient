//
//  KOTHAppDelegate.m
//  KOTH
//
//  Created by Denis Davydenko on 10/19/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "cocos2d.h"

#import "KOTHAppDelegate.h"
#import "GameConfig.h"
#import "PartnersScene.h"
#import "Cocos2dViewController.h"
#import "OpenFeintEx.h"
#import "Server.h"
#import "GameController.h"
#import "GameOptions.h"
#import "SoundManager.h"

@interface KOTHAppDelegate(Private)

-(void)_initOpenFeint;

@end


@implementation KOTHAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	NSLog(@"managed code started");
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
		
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0];						// GL_DEPTH_COMPONENT16_OES
							//preserveBackbuffer:NO];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// To enable Hi-Red mode (iPhone4)
	//if (![director enableRetinaDisplay:YES])
	//	CCLOG(@"Retina is not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//

//	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	[director setAnimationInterval:1.0/60];
//	[director setDisplayFPS:YES];
//	[((CCDirectorIOS*)director) setDepthBufferFormat:kCCDepthBuffer16];
	
	// make the OpenGLView a child of the view controller
	[[Cocos2dViewController currentController] setView:glView];
	
	// make the View CBontroller a child of the main window
	[window addSubview: [Cocos2dViewController currentController].view];
	
	[window makeKeyAndVisible];
		
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
					
	[[CCDirector sharedDirector] runWithScene: [PartnersScene scene]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
	
	[[OpenFeintEx of] applicationWillResignActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];

	[[OpenFeintEx of] applicationDidBecomeActive];
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];	
	[[GameController game] pause];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[GameController game] resume];
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
		
	[window release];
	
	[director end];	
	
	[[Server srv] disconnect];
	
	[[OpenFeintEx of] shutdown];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
