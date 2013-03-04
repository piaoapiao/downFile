// AudioPlayer.m
//
// Copyright (c) 2012 Scott Ban (sban@netspectrum.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AudioPlayer.h"
#import "AudioStreamer.h"

@interface AudioPlayer ()
- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)isProcessing;

- (void)playLocalFile;
- (void)pausePlayLocalFile;
- (void)stopPlayLocalFile;
@end

@implementation AudioPlayer

@synthesize  url;
@synthesize currentPlayerType,isPyaerPlaying;

+ (id)sharePlayer{
    static AudioPlayer *_audioPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _audioPlayer = [[self alloc] init];
    });
    return _audioPlayer;
}

- (id)init {
    self = [super init];
    if (self) {
        //支持avaudioplayer播放
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    return self;
}

- (BOOL)isProcessing {
    return [streamer isPlaying] || [streamer isWaiting] || [streamer isFinishing] ;
}

- (void)play {        
    if (!streamer) {
        
        streamer = [[AudioStreamer alloc] initWithURL:self.url];
        
        // register the streamer on notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackStateChanged:)
                                                     name:ASStatusChangedNotification
                                                   object:streamer];
    }
    
    if ([streamer isPlaying]) {
        [streamer pause];
    } else {
        [streamer start];
    }
}

- (void)pause{
    if (streamer && [streamer isPlaying]) {
        [streamer pause];
    }
}

- (void)stop {    
    // release streamer
	if (streamer)
	{        
		[streamer stop];
		streamer = nil;
        
        // remove notification observer for streamer
		[[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:ASStatusChangedNotification
                                                      object:streamer];		
	}
}

- (void)playLocalFile{
    if ([streamer isPlaying]) {
        [streamer stop];
    }
    
    if (!localPlayer) {
        localPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        localPlayer.delegate = self;
    }
    
    if ([localPlayer isPlaying]) {
        [localPlayer pause];
    } else {
        [localPlayer prepareToPlay];
        [localPlayer play];
    }
}

- (void)pausePlayLocalFile{
    if (localPlayer && [localPlayer isPlaying]) {
        [localPlayer pause];
    }
}

- (void)stopPlayLocalFile{
    [localPlayer stop];
    localPlayer.delegate = nil;
    localPlayer = nil;
}
#pragma mark - setter/getter

- (PlayerType)currentPlayerType{
    if (streamer && [streamer isPlaying]) {
        return PlayerTypeNetwork;
    }else if (localPlayer && [localPlayer isPlaying]) {
        return PlayerTypeLocal;
    }else {
        return PlayerTypeNone;
    }
}

#pragma mark - public api

- (void)playWithDataSourceType:(DataSourceType)type withURLString:(NSString*)aUrlStr{
    //stop
    [self stopPlay];
    
    switch (type) {
        case DataSourceTypeNetwork:
        {
            //new player
            streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:aUrlStr]];
            
            // register the streamer on notification
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playbackStateChanged:)
                                                         name:ASStatusChangedNotification
                                                       object:streamer];
            
            [streamer start];
        }
            break;
            
        default:{
            NSData *data = [NSData dataWithContentsOfFile:aUrlStr];
            NSLog(@"data length is %i",[data length]);
            
            NSError *error = nil;
            localPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
            
            if (error) {
                NSLog(@"Error occur with info %@",[error localizedDescription]);
                
                [self stopPlay];
            }else {
                localPlayer.volume = 0.7;
                localPlayer.numberOfLoops = 0;
                localPlayer.delegate = self;
                [localPlayer setMeteringEnabled:YES];

                [localPlayer prepareToPlay];
                [localPlayer play];
            }
        }
            break;
    }
}

- (void)pausePlay{
    if (streamer && [streamer isPlaying]) {
        [streamer pause];
    }
    
    if (localPlayer && [localPlayer isPlaying]) {
        [localPlayer pause];
    }
}

- (void)stopPlay{
    if (localPlayer && [localPlayer isPlaying]) {
        [localPlayer stop];
        localPlayer.delegate = nil;
        localPlayer = nil;
    }
    
    if (streamer && [streamer isPlaying]) {
        [streamer stop];
        streamer = nil;
    }
}

- (BOOL)isPyaerPlaying{
    if (streamer && localPlayer) {
        return [streamer isPlaying] || [localPlayer isPlaying];
    }
    return NO;
}

#pragma mark - handle notifications

/*
 *  observe the notification listener when loading an audio
 */
- (void)playbackStateChanged:(NSNotification *)notification {
	if ([streamer isWaiting])
	{

    } else if ([streamer isIdle]) {
		[self stop];
        if (finishBlock) {
            finishBlock(YES);
        }
	} else if ([streamer isPaused]) {
        
    } else if ([streamer isPlaying] || [streamer isFinishing]) {
        
        if (finishBlock) {
            finishBlock(YES);
        }
	} else {
        
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"local player finish playing");
    [self stopPlay];
    
    if (finishBlock) {
        finishBlock(YES);
    }    
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"local player error occur with error %@",error);
    
    [self stopPlay];
}

- (void)setPlayToEndHandle:(FinishBlock)finish{
    finishBlock = finish;
}


@end
