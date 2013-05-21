//
//  ViewController.m
//  SIMPLE
//
//  Created by Rohan Sinha on 21/05/13.
//  Copyright (c) 2013 Rohan Sinha. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    
    [volumeSlider setValue:[musicPlayer volume]];
    
	if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying)
        [playPauseButton setTitle:@"||" forState:UIControlStateNormal];
    else [playPauseButton setTitle:@"|>" forState:UIControlStateNormal];
    
    [self registerMediaPlayerNotifications];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end