#import "MusicHandler.h"

static NSString *WATER_EFFECT = @"splash2.mp3";
//static NSString *WATER_EFFECT = @"gong.wav";
static NSString *BOUNCE_EFFECT = @"boing.wav";
static NSString *TARGET1_HIT_EFFECT = @"break.wav";
static NSString *TARGET2_HIT_EFFECT = @"explosion.mp3";//not sure if working
static NSString *TARGET3_HIT_EFFECT = @"ice.wav";
static NSString *TARGET4_HIT_EFFECT = @"gong.wav";

@interface MusicHandler()
	+(void) playEffect:(NSString *)path;
@end


@implementation MusicHandler

+(void) preload{
	SimpleAudioEngine *engine = [SimpleAudioEngine sharedEngine];
	if (engine) {
		[engine preloadEffect:WATER_EFFECT];
		[engine preloadEffect:BOUNCE_EFFECT];
		[engine preloadEffect:TARGET1_HIT_EFFECT];
		[engine preloadEffect:TARGET2_HIT_EFFECT];
		[engine preloadEffect:TARGET3_HIT_EFFECT];
		[engine preloadEffect:TARGET4_HIT_EFFECT];
	}
}

+(void) playWater{
	[MusicHandler playEffect:WATER_EFFECT];	
}
+(void) playBounce{
	[MusicHandler playEffect:BOUNCE_EFFECT];	
}
+(void) playWall{
  [MusicHandler playEffect:TARGET4_HIT_EFFECT];	
}

+(void) playEffect: (NSString *) path{
	[[SimpleAudioEngine sharedEngine] playEffect:path];
}
@end
