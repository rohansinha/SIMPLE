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
@synthesize musicPlayer;

#pragma mark - Intial Load
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

#pragma mark - Catching event notifications
- (void) registerMediaPlayerNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
	[notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: musicPlayer];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
    
    [notificationCenter addObserver: self
						   selector: @selector (handle_VolumeChanged:)
							   name: MPMusicPlayerControllerVolumeDidChangeNotification
							 object: musicPlayer];
    
	[musicPlayer beginGeneratingPlaybackNotifications];
}

- (void) handle_NowPlayingItemChanged: (id) notification
{
   	MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
	UIImage *artworkImage = [UIImage imageNamed:@"noArtworkImage.png"];
	MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
	
	if (artwork) artworkImage = [artwork imageWithSize: CGSizeMake (200, 200)];
	
    [artworkView setImage:artworkImage];
    
    NSString *titleString = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    if (titleString)
        titleLabel.text = [NSString stringWithFormat:@"Title: %@",titleString];
    else titleLabel.text = @"Title: Unknown title";
    
    NSString *artistString = [currentItem valueForProperty:MPMediaItemPropertyArtist];
    if (artistString) artistLabel.text = [NSString stringWithFormat:@"Artist: %@", artistString];
    else artistLabel.text = @"Artist: Unknown artist";
    
    NSString *albumString = [currentItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    if (albumString) albumLabel.text = [NSString stringWithFormat:@"Album: %@", albumString];
    else albumLabel.text = @"Album: Unknown album";
}


- (void) handle_PlaybackStateChanged: (id) notification
{
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
	if (playbackState == MPMusicPlaybackStatePaused)
        [playPauseButton setTitle:@"|>" forState:UIControlStateNormal];
    else if (playbackState == MPMusicPlaybackStatePlaying)
        [playPauseButton setTitle:@"||" forState:UIControlStateNormal];
	else if (playbackState == MPMusicPlaybackStateStopped) {
        [playPauseButton setTitle:@"|>" forState:UIControlStateNormal];
		[musicPlayer stop];
    }
}

- (void) handle_VolumeChanged: (id) notification
{
    [volumeSlider setValue:[musicPlayer volume]];
}



@end