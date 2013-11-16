//
//  ViewController.h
//  SIMPLE
//
//  Created by Rohan Sinha on 21/05/13.
//  Copyright (c) 2013 Rohan Sinha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "QueueViewController.h"

@class ReflectionView;

@interface PlayerController : UIViewController <MPMediaPickerControllerDelegate>
{
    MPMusicPlayerController *musicPlayer;
    
    IBOutlet UIImageView *artworkView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *artistLabel;
    IBOutlet UILabel *albumLabel;
    IBOutlet UILabel *currentPlayTime;
    IBOutlet UILabel *remainingPlayTime;
    IBOutlet UIButton *playPauseButton;
    IBOutlet UIButton *prevButton;
    IBOutlet UIButton *nextButton;
    IBOutlet UIImageView *bg;
    //IBOutlet UISlider *playPosition;
    IBOutlet UIProgressView *playPosition;
    
    //UIImageView *_imageView;
    ReflectionView *_reflectionView;
}

@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;
@property (nonatomic, retain) MPMediaItemCollection *nowPlayingQueue;
@property (nonatomic, retain) IBOutlet ReflectionView *reflectionView;
//@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (IBAction)showMediaPicker:(id)sender;
- (IBAction)prevSong:(id)sender;
- (IBAction)playPause:(id)sender;
- (IBAction)nextSong:(id)sender;
- (void) registerMediaPlayerNotifications;
- (void) handle_tap:(NSSet *)touches;

@end