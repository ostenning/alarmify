//
//  Alarmify
//  Licensed under the Mozilla Public License 2.0
//

#import "SpotifyAutoplayer.h"

@implementation SpotifyAutoplayer

/**
 * Returns the apple script needed to automatically launch spotify and play the selected URI
 */
+ (NSString *)templateScript
{
    return (
        @"set volume 0\n"
        @"tell application \"Spotify\"\n"
            @"open location \"SPOTIFY_URI\"\n"
            @"set the sound volume to 100\n"
            @"play track \"SPOTIFY_URI\"\n"
        @"end tell\n"
        @"repeat with index from 0 to SOUND_VOLUME by 8\n"
            @"set volume output volume index\n"
            @"if output volume of (get volume settings) is greater than SOUND_VOLUME then exit repeat\n"
            @"delay SOUND_VELOCITY\n"
        @"end repeat\n"
    );
}

/**
 * Validates the Uri that its all good
 */
+ (bool) validateUri:(NSString *)spotifyUri
{
    if (!spotifyUri.length) return false;
    if (![spotifyUri hasPrefix:@"spotify:"]) return false;
    return true;
}

/**
 * Begin playing spotify with the specified URI, volume and sound velocity
 */
+ (void) beginPlaying:(NSString *)spotifyUri
       andSoundVolume:(NSInteger)soundVolume
     andSoundVeloctiy:(NSInteger)soundVelocity
{
    // Build the AppleScript with parameters (the URI)
    NSString *appleScriptContent =
    [[[[self templateScript]
       stringByReplacingOccurrencesOfString:@"SPOTIFY_URI" withString:spotifyUri]
      stringByReplacingOccurrencesOfString:@"SOUND_VOLUME" withString:[NSString stringWithFormat:@"%d", (int)soundVolume]]
     stringByReplacingOccurrencesOfString:@"SOUND_VELOCITY" withString:[NSString stringWithFormat:@"%d", (int)soundVelocity]];
    
    NSLog(@"%@", appleScriptContent);
    
    // Run the AppleScript in new thread to start spotify
    [NSThread detachNewThreadWithBlock:^{
        NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:appleScriptContent];
        [scriptObject executeAndReturnError:nil];
    }];
}

@end
