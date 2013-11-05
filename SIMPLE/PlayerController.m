//
//  ViewController.m
//  SIMPLE
//
//  Created by Rohan Sinha on 21/05/13.
//  Copyright (c) 2013 Rohan Sinha. All rights reserved.
//

#import "PlayerController.h"
#import <sqlite3.h>

@implementation PlayerController
@synthesize musicPlayer;

#pragma mark - Intial Load

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"simple_data.sqlite"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
	if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying){
        [playPauseButton setTitle:@"||" forState:UIControlStateNormal];
        //[playPosition setValue:[musicPlayer currentPlaybackTime]];
    }
    else [playPauseButton setTitle:@"|>" forState:UIControlStateNormal];
    
    [self registerMediaPlayerNotifications];
    //[playPosition setValue:[musicPlayer currentPlaybackTime]];
    
    //*****-=-=-=-Gestures Stuff-=-=-=-*****
    /*UISwipeGestureRecognizer *horizontal =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalSwipe:)];
    horizontal.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:horizontal];*/
    
    UISwipeGestureRecognizer *vertical =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportVerticalSwipe:)];
    vertical.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:vertical];
    
    [self initializeDatabase];
}

#pragma mark - Database Stuff
- (void)initializeDatabase
{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS FIELDS "
    "(ROW INTEGER PRIMARY KEY, FIELD_DATA TEXT);";
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    NSString *query = @"SELECT ROW, FIELD_DATA FROM FIELDS ORDER BY ROW";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //int row = sqlite3_column_int(statement, 0);
            //char *rowData = (char *)sqlite3_column_text(statement, 1);
            //NSString *fieldValue = [[NSString alloc] initWithString:rowData];
            //UITextField *field = self.lineFields[row];
            //field.text = fieldValue;
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:app];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)!= SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    for (int i = 0; i < 4; i++)
    {
        // UITextField *field = self.lineFields[i];
        // Once again, inline string concatenation to the rescue:
        char *update = "INSERT OR REPLACE INTO FIELDS (ROW, FIELD_DATA) "
        "VALUES (?, ?);";
        char *errorMsg = NULL;
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK)
        {
            sqlite3_bind_int(stmt, 1, i);
        //  sqlite3_bind_text(stmt, 2, [field.text UTF8String], -1, NULL);
        }
        if (sqlite3_step(stmt) != SQLITE_DONE)
            NSAssert(0, @"Error updating table: %s", errorMsg);
        sqlite3_finalize(stmt);
    }
    sqlite3_close(database);
    
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
    
	[musicPlayer beginGeneratingPlaybackNotifications];
}

- (void) handle_NowPlayingItemChanged: (id) notification
{
   	MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
    //[playPosition setValue:[musicPlayer currentPlaybackTime]];
	UIImage *artworkImage = [UIImage imageNamed:@"noArtworkImage.png"];
    UIImage *background = [UIImage imageNamed:@"noBG.jpg"];
	MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
	if (artwork) artworkImage = [artwork imageWithSize:CGSizeMake(320, 320)];
	NSString *genre = [currentItem valueForProperty: MPMediaItemPropertyGenre];
    
    if([genre isEqualToString:@"Rock"])
        background = [UIImage imageNamed:@"SIMPLE-bg_purple.jpg"];
    else if([genre isEqualToString:@"Alternative"])
        background = [UIImage imageNamed:@"SIMPLE-bg_blue.jpg"];
    else if([genre isEqualToString:@"Pop"]) background = [UIImage imageNamed:@"SIMPLE-bg_green.jpg"];
    else if([genre isEqualToString:@"Metal"]) background = [UIImage imageNamed:@"SIMPLE-bg_red.jpg"];
    else background = [UIImage imageNamed:@"noBG.jpg"];
    
    [artworkView setImage:artworkImage];
    [bg setImage:background];
    
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

#pragma mark - Media Picker

- (IBAction)showMediaPicker:(id)sender
{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    mediaPicker.delegate = self;
    mediaPicker.showsCloudItems = NO;
    mediaPicker.prompt = @"Select song to play";
    
    [self presentViewController:mediaPicker animated:YES completion:NO];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        [musicPlayer setQueueWithItemCollection: mediaItemCollection];
        [musicPlayer play];
    }
	[self dismissViewControllerAnimated:YES completion:NO];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
	[self dismissViewControllerAnimated:YES completion:NO];
}

#pragma mark - Gestures
- (void)reportHorizontalSwipe:(UIGestureRecognizer *)recognizer
{
    //what to do when horizontal gesture detected
    
    
}

- (void)reportVerticalSwipe:(UIGestureRecognizer *)recognizer
{
    //what to do when vertical gesture detected
    if([titleLabel isHidden] && [artistLabel isHidden] && [albumLabel isHidden]
       && ![playPauseButton isHidden] && ![prevButton isHidden] && ![nextButton isHidden])
    {
        titleLabel.hidden = false;
        artistLabel.hidden = false;
        albumLabel.hidden = false;
        playPauseButton.hidden = true;
        prevButton.hidden = true;
        nextButton.hidden = true;
    } else {
        titleLabel.hidden = true;
        artistLabel.hidden = true;
        albumLabel.hidden = true;
        playPauseButton.hidden = false;
        prevButton.hidden = false;
        nextButton.hidden = false;
    }
    //if(![titleLabel isHidden] && ![artistLabel isHidden] && ![albumLabel isHidden]
    //          && [playPauseButton isHidden] && [prevButton isHidden] && [nextButton isHidden])
    
    
}

#pragma mark - Controls

- (IBAction)prevSong:(id)sender
{
    if([musicPlayer currentPlaybackTime] < 5.0)
        [musicPlayer skipToPreviousItem];
    else [musicPlayer skipToBeginning];
}

- (IBAction)playPause:(id)sender
{
    if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying)
        [musicPlayer pause];
    else [musicPlayer play];
}

- (IBAction)nextSong:(id)sender
{
    [musicPlayer skipToNextItem];
}

@end