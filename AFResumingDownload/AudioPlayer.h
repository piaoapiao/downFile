// AudioPlayer.h
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum{
    PlayerTypeNone,
    PlayerTypeNetwork,
    PlayerTypeLocal
}PlayerType;

typedef enum {
    DataSourceTypeLocal,
    DataSourceTypeNetwork
}DataSourceType;

typedef void (^FinishBlock)(BOOL finished);

@class AudioStreamer;

@interface AudioPlayer : NSObject <AVAudioPlayerDelegate>{
    AudioStreamer *streamer;
    AVAudioPlayer  *localPlayer;
    NSURL *url;
    NSTimer *timer;
    
    FinishBlock finishBlock;
}

@property (nonatomic, retain)   NSURL *url;
@property (nonatomic, readonly) PlayerType currentPlayerType;
@property (nonatomic, readonly) BOOL isPyaerPlaying;


+ (id)sharePlayer;

- (void)playWithDataSourceType:(DataSourceType)type withURLString:(NSString*)aUrlStr;
- (void)pausePlay;
- (void)stopPlay;
- (void)setPlayToEndHandle:(FinishBlock)finish;
@end
