//
//  GameOptions.h
//  KOTH
//
//  Created by Denis Davydenko on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenFeintEx.h"

@interface GameOptions : NSObject

+(void)setMainServerDomainName:(NSString *)mainServerDomainName;
+(NSString*)mainServerDomainName;
+(void)setLocalPlayerName:(NSString*)name;
+(NSString*)localPlayerName;
+(void)setSoundEnabled:(BOOL)enabled;
+(BOOL)soundEnabled;
+(void)setMusicEnabled:(BOOL)enabled;
+(BOOL)musicEnabled;
+(void)setPingEnabled:(BOOL)enabled;
+(BOOL)pingEnabled;
+(void)setOpenFeintViewType:(OpenFeintViewType)viewType;
+(OpenFeintViewType)openFeintViewType;

@end
