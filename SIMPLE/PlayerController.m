//
//  ViewController.m
//  SIMPLE
//
//  Created by Rohan Sinha on 21/05/13.
//  Copyright (c) 2013 Rohan Sinha. All rights reserved.
//

#import "ReflectionView.h"
#import "PlayerController.h"
#import "QueueViewController.h"
#import <sqlite3.h>

@implementation PlayerController
@synthesize musicPlayer, nowPlayingQueue, reflectionView = _reflectionView;

NSTimer *audioTimer;

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
        [playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:normal];
        //[playPosition setProgress:[musicPlayer currentPlaybackTime]];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
    }
    else [playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:normal];
    [self.reflectionView updateReflection];
    
    [self registerMediaPlayerNotifications];
    //[playPosition setValue:[musicPlayer currentPlaybackTime]];
    
    //*****-=-=-=-Gestures Stuff-=-=-=-*****
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportLeftSwipe:)];
    [left setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:left];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportRightSwipe:)];
    [right setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:right];
    
    UISwipeGestureRecognizer *up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportUpSwipe:)];
    [up setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:up];
    
    UISwipeGestureRecognizer *down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportDownSwipe:)];
    [down setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:down];
    
    UIScreenEdgePanGestureRecognizer *queue = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(displayQueue:)];
    [queue setEdges:UIRectEdgeLeft];
    [self.view addGestureRecognizer:queue];
    
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
    [playPosition setProgress:([musicPlayer currentPlaybackTime] / [[currentItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue])];
	UIImage *artworkImage = [UIImage imageNamed:@"noArtworkImage.png"];
	MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
	if (artwork) artworkImage = [artwork imageWithSize:CGSizeMake(320, 320)];
	NSString *genre = [currentItem valueForProperty: MPMediaItemPropertyGenre];
    
    if([genre isEqualToString:@"Rock"]) [self.reflectionView setBackgroundColor:[UIColor purpleColor]];
    else if([genre isEqualToString:@"Alternative"]) [self.reflectionView setBackgroundColor:[UIColor blueColor]];
    else if([genre isEqualToString:@"Pop"]) [self.reflectionView setBackgroundColor:[UIColor greenColor]];
    else if([genre isEqualToString:@"Metal"]) [self.reflectionView setBackgroundColor:[UIColor redColor]];
    else [self.reflectionView setBackgroundColor:[UIColor blackColor]];
    
    [artworkView setImage:artworkImage];
    [self.reflectionView updateReflection];
    //[bg setImage:background];
    
    NSString *titleString = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    if (titleString)
        titleLabel.text = [NSString stringWithFormat:@"%@",titleString];
    else [titleLabel setText:@"Unknown title" ];
    
    NSString *artistString = [currentItem valueForProperty:MPMediaItemPropertyArtist];
    if (artistString) artistLabel.text = [NSString stringWithFormat:@"%@", artistString];
    else [artistLabel setText:@"Unknown artist"];
    
    NSString *albumString = [currentItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    if (albumString) albumLabel.text = [NSString stringWithFormat:@"%@", albumString];
    else [artistLabel setText:@"Unknown album" ];
}

- (void) handle_PlaybackStateChanged: (id) notification
{
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
	if (playbackState == MPMusicPlaybackStatePaused)
        [playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:normal];
    else if (playbackState == MPMusicPlaybackStatePlaying)
        [playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:normal];
	else if (playbackState == MPMusicPlaybackStateStopped) {
        [playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:normal];
		[musicPlayer stop];
    }
}

#pragma mark - Media Picker

- (IBAction)showMediaPicker:(id)sender
{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    [mediaPicker setDelegate:self];
    [mediaPicker setShowsCloudItems:NO];
    [mediaPicker setPrompt:@"Select song to play"];
    [mediaPicker setAllowsPickingMultipleItems:YES];
    
    [self presentViewController:mediaPicker animated:YES completion:NO];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        [musicPlayer setQueueWithItemCollection: mediaItemCollection];
        nowPlayingQueue = mediaItemCollection;
        [musicPlayer play];
    }
	[self dismissViewControllerAnimated:YES completion:NO];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
	[self dismissViewControllerAnimated:YES completion:NO];
}

#pragma mark - Gestures
- (void)displayQueue:(UIGestureRecognizer *)sender {
    QueueViewController *qvc = [[QueueViewController alloc] initWithStyle:UITableViewStylePlain];
    [qvc setValue:nowPlayingQueue forKey:@"playQueue"];
    qvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //[self presentViewController:qvc animated:YES completion:NULL];
}

- (void)handle_tap:(NSSet *)touches
{
    if(![self displayMode])
    {
        NSUInteger numTaps = [[touches anyObject] tapCount];
        if(numTaps)
        {
            if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
                [musicPlayer pause];
                [audioTimer invalidate];
            } else {
                [musicPlayer play];
                audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handle_tap:touches];
}

- (void)reportLeftSwipe:(UIGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    if(![self displayMode] && location.y > 325)
    {
        [musicPlayer skipToNextItem];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
    }
}

- (void)reportRightSwipe:(UIGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    if(![self displayMode] && location.y > 325)
    {
        [musicPlayer skipToPreviousItem];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
    }
}

- (void)reportDownSwipe:(UIGestureRecognizer *)recognizer
{
    if([self displayMode])
    {
        [titleLabel setHidden:NO];
        [albumLabel setHidden:NO];
        [artistLabel setHidden:NO];
        [playPauseButton setHidden:YES];
        [prevButton setHidden:YES];
        [nextButton setHidden:YES];
    }
}

- (void)reportUpSwipe:(UIGestureRecognizer *)recognizer
{
    if(![self displayMode])
    {
        [titleLabel setHidden:YES];
        [albumLabel setHidden:YES];
        [artistLabel setHidden:YES];
        [playPauseButton setHidden:NO];
        [prevButton setHidden:NO];
        [nextButton setHidden:NO];
    }
}

- (bool)displayMode //true for playback controls, false for info
{
    if([titleLabel isHidden] && [artistLabel isHidden] && [albumLabel isHidden]
       && ![playPauseButton isHidden] && ![prevButton isHidden] && ![nextButton isHidden])
        return true;
    else return false;
}

#pragma mark - Controls

- (IBAction)prevSong:(id)sender
{
    if([musicPlayer currentPlaybackTime] < 5.0) {
        [musicPlayer skipToPreviousItem];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
    } else {
        [musicPlayer skipToBeginning];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
    }
}

- (IBAction)playPause:(id)sender
{
    if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [musicPlayer pause];
        [audioTimer invalidate];
    } else {
        [musicPlayer play];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
    }
}

- (IBAction)nextSong:(id)sender
{
    [musicPlayer skipToNextItem];
    audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
}

- (void)audioProgressUpdate
{
    MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
    NSNumber *length = [currentItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    double currentPos = [musicPlayer currentPlaybackTime];
    double len = [length doubleValue];
    if (musicPlayer != nil && length > 0) {
        [playPosition setProgress:(currentPos / len)];
        //[playPosition setValue:currentPos];
        [currentPlayTime setText:[NSString stringWithFormat:@"%02d:%02d", (int) currentPos/60, (int) currentPos%60]];
        [remainingPlayTime setText:[NSString stringWithFormat:@"-%02d:%02d", (int) (len-currentPos)/60, (int) (len-currentPos)%60]];
    } else {
        [currentPlayTime setText:@"00:00"];
        [remainingPlayTime setText:@"00:00"];
    }
}

@end