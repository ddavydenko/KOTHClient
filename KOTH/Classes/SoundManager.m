//
//  SoundManager.m
//  KOTH
//
//  Created by Denis Davydenko on 11/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"
#import "NSArrayEx.h"

@interface SoundManager(Private)

-(NSString*)_effectFileByType:(SoundEffectType)effectType;
-(NSString*)_musicFileByType:(BackgroundMusicType)musicType;

@end


@implementation SoundManager

static SoundManager* instance_ = nil;

+(SoundManager*)sounds
{
	@synchronized(self)
	{
		if (!instance_) {
			instance_ = [[self alloc] init];
		}
	}
	return instance_;
}

-(id)init
{
	if ((self = [super init])) {
		
		effects_ = [[NSMutableArray arrayWithObjects:
					@"jump sound.mp3", 
					@"ram_hit sound.mp3",
					@"ram_miss sound.mp3",
					@"jumping collission sound.mp3",
					@"ram_fall sound.mp3",
					@"eating sound.mp3",
					nil] retain];
		
		musics_ = [[NSMutableArray arrayWithObjects:
				   @"main screen and all screens bg music.mp3",
				   @"jumping scene bg music.mp3",
				   @"fight scene bg music.mp3",
				   @"game over - lost bg music.mp3",
				   @"game over - win bg music.mp3",
				   nil] retain];

		currentMusic_ = -1;
	}
	return self;
}

-(void)preloadSounds
{
	[effects_ enumerate:^(id obj)
	 {
		 [[SimpleAudioEngine sharedEngine] preloadEffect:obj];
	 }];
	[musics_ enumerate:^(id obj)
	 {
		 [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:obj];
	 }];
}

-(void)playSoundEffect:(SoundEffectType)effectType
{
//	NSString *effectFileName = [self _effectFileByType:effectType];
//	NSLog(@"playEffect - %@", effectFileName);
//	[[SimpleAudioEngine sharedEngine] playEffect:effectFileName];
	[self playSoundEffect:effectType loop:FALSE];
}

-(ALuint)playSoundEffect:(SoundEffectType)effectType loop:(BOOL)isLoop
{
	NSString *effectFileName = [self _effectFileByType:effectType];
	NSLog(@"playEffect - %@, loop - @", effectFileName, isLoop);
	return [[SimpleAudioEngine sharedEngine] playEffect:effectFileName loop:isLoop];
}

-(void)stopSoundEffect:(ALuint)soundId
{
	[[SimpleAudioEngine sharedEngine] stopEffect:soundId];
}

-(void)playBackgroundMusic:(BackgroundMusicType)musicType
{
	if (currentMusic_ != musicType) {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:[self _musicFileByType:musicType]];
		currentMusic_ = musicType;
	}
}

-(NSString*)_effectFileByType:(SoundEffectType)effectType
{
	return [effects_ objectAtIndex:(int)effectType];
}

-(NSString*)_musicFileByType:(BackgroundMusicType)musicType
{
	return [musics_ objectAtIndex:(int)musicType];
}

-(void)dealloc
{
	[effects_ release];
	[musics_ release];
	[super dealloc];
}

@end
