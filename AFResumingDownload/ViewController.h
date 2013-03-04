//
//  ViewController.h
//  Animusic
//
//  Created by sban@netspectrum.com on 9/21/12.
//  Copyright (c) 2012 Netspectrum Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AudioPlayer.h"
@interface ViewController : UIViewController
{
    NSOperationQueue    *quene;
    UIProgressView  *proView;
}
@end
