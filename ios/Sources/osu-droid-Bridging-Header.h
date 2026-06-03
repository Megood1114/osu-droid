//
//  osu-droid-Bridging-Header.h
//  osu!droid
//

#import "bass.h"
#import "bassmix.h"

// bass.h #undefs BOOL at the end when __OBJC__ is defined.
// Re-define it so bass_fx.h can use it.
#ifndef BOOL
#define BOOL int
#endif

#import "bass_fx.h"
