//
//  SoundManager.h
//  KOTH
//
//  Created by Denis Davydenko on 11/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"


typedef enum {
	seftJumpSound = 0,
	seftPunchSound = 1,
	seftMissSound = 2,
	seftCollisionSound = 3,
	seftFallSound = 4,
	seftEatSound = 5,
} SoundEffectType;

typedef enum {
	bmtHomeMusic = 0,
	bmtJumpMusic = 1,
	bmtFightMusic = 2,
	bmtLostMusic = 3,
	bmtWinMusic = 4,
} BackgroundMusicType;


@interface SoundManager : NSObject {

@private
	BackgroundMusicType currentMusic_;
	
	NSMutableArray *effects_;
	NSMutableArray *musics_;
}

+(SoundManager*)sounds;

-(void)preloadSounds;
-(void)playSoundEffect:(SoundEffectType)effectType;
-(ALuint)playSoundEffect:(SoundEffectType)effectType loop:(BOOL)loop;
-(void)stopSoundEffect:(ALuint) soundId;
-(void)playBackgroundMusic:(BackgroundMusicType)musicType;

@end
