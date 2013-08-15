//
//  ViewController.h
//  SIMPLE
//
//  Created by Rohan Sinha on 21/05/13.
//  Copyright (c) 2013 Rohan Sinha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController <MPMediaPickerControllerDelegate>
{
    MPMusicPlayerController *musicPlayer;
    
    IBOutlet UIImageView *artworkView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *artistLabel;
    IBOutlet UILabel *albumLabel;
    IBOutlet UIButton *playPauseButton;
    IBOutlet UIImageView *bg;
    //IBOutlet UISlider *playPosition;
    //IBOutlet UIProgressView *playPosition;
}

@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;

- (IBAction)showMediaPicker:(id)sender;
- (IBAction)prevSong:(id)sender;
- (IBAction)playPause:(id)sender;
- (IBAction)nextSong:(id)sender;
- (void) registerMediaPlayerNotifications;

@end