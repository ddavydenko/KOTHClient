//
//  GameOptions.m
//  KOTH
//
//  Created by Denis Davydenko on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameOptions.h"
#import "SimpleAudioEngine.h"
#import "Tools.h"

@implementation GameOptions

+(void)setMainServerDomainName:(NSString *)mainServerDomainName
{ 
	[[NSUserDefaults standardUserDefaults] setObject:mainServerDomainName forKey:@"mainServerDomainName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString*)mainServerDomainName
{
	NSString *mainServerDomainName = [[NSUserDefaults standardUserDefaults] objectForKey:@"mainServerDomainName"];
	if (mainServerDomainName == nil || mainServerDomainName == @"") {
		mainServerDomainName = @"www.kotmonline.com";
		[self setMainServerDomainName: mainServerDomainName];
	}
	return mainServerDomainName;
}

+(void)setLocalPlayerName:(NSString*)playerName
{
	[[NSUserDefaults standardUserDefaults] setObject:playerName forKey:@"playerName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString*)localPlayerName
{
	NSString *playerName = [[NSUserDefaults standardUserDefaults] objectForKey:@"playerName"];
	if (playerName == nil || playerName == @"") {
		playerName = [NSString stringWithFormat:@"player%d", randomIntFromMinToMax(10000, 99999)];
		[self setLocalPlayerName:playerName];
	}
	return playerName;
}

+(void)setSoundEnabled:(BOOL)enabled
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:enabled] forKey:@"soundEnabled"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[SimpleAudioEngine sharedEngine] setEffectsVolume: enabled? 1.f : 0.f];
}

+(BOOL)soundEnabled
{
	NSNumber *enabled = [[NSUserDefaults standardUserDefaults] objectForKey:@"soundEnabled"];
	if (enabled == nil) {
		[self setSoundEnabled:YES];
		return YES;
	}
	return [enabled boolValue];
}

+(void)setMusicEnabled:(BOOL)enabled
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:enabled] forKey:@"musicEnabled"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: enabled? 1.f : 0.f];
}

+(BOOL)musicEnabled
{
	NSNumber *enabled = [[NSUserDefaults standardUserDefaults] objectForKey:@"musicEnabled"];
	if (enabled == nil) {
		[self setMusicEnabled:YES];
		return YES;
	}
	return [enabled boolValue];
}

+(void)setPingEnabled:(BOOL)enabled
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:enabled] forKey:@"pingEnabled"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)pingEnabled
{
	NSNumber *enabled = [[NSUserDefaults standardUserDefaults] objectForKey:@"pingEnabled"];
	if (enabled == nil) {
		[self setPingEnabled:YES];
		return YES;
	}
	return [enabled boolValue];
}

+(void)setOpenFeintViewType:(OpenFeintViewType)viewType
{
	NSNumber *viewTypeNumber = [NSNumber numberWithInt:(int)viewType];
	[[NSUserDefaults standardUserDefaults] setObject:viewTypeNumber forKey:@"openFeintViewType"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(OpenFeintViewType)openFeintViewType
{
	NSNumber *viewTypeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"openFeintViewType"];
	if (viewTypeNumber == nil) {
		return ofvtNone;
	}
	return (OpenFeintViewType)[viewTypeNumber intValue];
}


@end
