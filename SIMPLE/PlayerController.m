//
//  ViewController.m
//  SIMPLE
//
//  Created by Rohan Sinha on 21/05/13.
//  Copyright (c) 2013 Rohan Sinha. All rights reserved.
//

#import "ReflectionView.h"
#import "PlayerController.h"
//#import "QueueViewController.h"
//#import <sqlite3.h>

@implementation PlayerController
@synthesize musicPlayer, nowPlayingQueue, reflectionView = _reflectionView;

NSTimer *audioTimer;
float alpha = 0.99;
float gama = 0.85;
BOOL step = NO;  //for num songs (3 queue)
MPMediaItem *twoBack;
float tBackPercent;
int numSongsHeard = 0;
int rewardMatrix[1000][1000];
int normalizedReward[1000];
NSMutableDictionary *songs;
NSMutableDictionary *idx;
NSMutableArray *v1;
NSMutableArray *v2;
NSMutableArray *v3;
NSMutableArray *r1;
NSMutableArray *r2;
NSMutableArray *r3;

#pragma mark - Intial Load
/*
- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"simple_data.sqlite"];
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
	[playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:normal];
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
    
    [self initializeData];
}

#pragma mark - Database Stuff
- (NSString *) getFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return documentsDirectory;
}

- (void)initializeData
{
    //NSString *savePath = [[self getFilePath] stringByAppendingPathComponent:@"data.plist"];
    NSString *filePath = [[self getFilePath] stringByAppendingPathComponent:@"data.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        songs = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    } else {
        //set up stuff...this is first run
        MPMediaQuery *query = [MPMediaQuery songsQuery]; //filter songs...remove videos and shit
        int n = [[query items] count];
        //NSLog(@"%d", n);
        
        //Building reward matrix
        for(int i = 0; i < n; i++)
        {
            for(int j = 0; j < n; j++)
            {
                rewardMatrix[i][j] = 0;
            }
        }
        idx = [[NSMutableDictionary alloc] init];
        r1 = [[NSMutableArray alloc] init];
        r2 = [[NSMutableArray alloc] init];
        r3 = [[NSMutableArray alloc] init];
        v1 = [[NSMutableArray alloc] init];
        v2 = [[NSMutableArray alloc] init];
        v3 = [[NSMutableArray alloc] init];
        //Initializing songs
        NSArray *fullList = [query items];
        songs = [[NSMutableDictionary alloc] init];
        NSNumber *zero = [NSNumber numberWithInt:0];
        float a = (1/(float)n); //float contributed by nirvik
        //NSLog(@"%f", a);
        NSNumber *calc = [NSNumber numberWithFloat:a];
        for(int i = 0; i < 1000; i++)
        {
            [r1 addObject:zero];
            [r2 addObject:zero];
            [r3 addObject:zero];
            [v1 addObject:calc];
            [v2 addObject:calc];
            [v3 addObject:calc];
        }
        //NSLog(@"%@", arr2[0]);
        NSMutableDictionary *sid = [[NSMutableDictionary alloc] init];
        [sid setObject:[NSNumber numberWithBool:NO] forKey:@"flag"];
        [sid setObject:v1 forKey:@"v1"];
        [sid setObject:v2 forKey:@"v2"];
        [sid setObject:v3 forKey:@"v3"];
        [sid setObject:r1 forKey:@"r1"];
        [sid setObject:r2 forKey:@"r2"];
        [sid setObject:r3 forKey:@"r3"];
        for(int i = 0; i < n; i++)
        {
            //[sid setObject:[[fullList objectAtIndex:i] valueForProperty:MPMediaItemPropertyTitle]  forKey:@"name"];
            [songs setObject:sid forKey:[[fullList objectAtIndex:i] valueForProperty:MPMediaItemPropertyPersistentID]];
            //[songs setObject:sid forKey:[NSNumber numberWithInt:i]];
            //NSLog(@"%@", sid);
            //NSLog(@"%@", [[fullList objectAtIndex:i] valueForProperty:MPMediaItemPropertyPersistentID]);
        }
        //NSDictionary *temp = songs[@"8769369858748389178"];
        
        NSArray *test = [songs allKeys];
        for(int i = 0; i < n; i++)
        {
            id aKey = [test objectAtIndex:i];
            //id anObject = [songs objectForKey:aKey];
            [idx setValue:[NSNumber numberWithInt:i] forKey:aKey];
            //NSLog(@"%@", anObject);
        }
        //NSLog(@"%@", [[songs objectForKey:@"8769369858748389327"] objectForKey:@"v1"]);
        [songs writeToFile:filePath atomically:YES];
    }
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
    if(![self displayMode])
    {
        [musicPlayer skipToPreviousItem];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
    }
}

- (void)reportRightSwipe:(UIGestureRecognizer *)recognizer
{
    if(![self displayMode])
    {
        [musicPlayer skipToNextItem];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
    }
}

- (void)reportDownSwipe:(UIGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    if([self displayMode] && location.y > 320)
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
    CGPoint location = [recognizer locationInView:self.view];
    if(![self displayMode] && location.y > 320)
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
    //[self compute];
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

- (IBAction)testQueue:(id)sender
{
    MPMediaItem *current = [musicPlayer nowPlayingItem];
    NSTimeInterval playTime = [musicPlayer currentPlaybackTime];
    BOOL wasPlaying = FALSE;
    if([musicPlayer playbackState] == MPMusicPlaybackStatePlaying)
        wasPlaying = TRUE;
    NSMutableArray *newQueue = [[nowPlayingQueue items] mutableCopy];
    MPMediaPropertyPredicate *artistNamePredicate = [MPMediaPropertyPredicate predicateWithValue: @"Adele" forProperty: MPMediaItemPropertyArtist];
    MPMediaQuery *sample = [[MPMediaQuery alloc] init];
    [sample addFilterPredicate: artistNamePredicate];
    NSArray *newItems = [sample items];
    [newQueue addObjectsFromArray:newItems];
    [self setNowPlayingQueue:[MPMediaItemCollection collectionWithItems:(NSArray *) newQueue]];
    [musicPlayer setQueueWithItemCollection:nowPlayingQueue];
    [musicPlayer setNowPlayingItem:current];
    [musicPlayer setCurrentPlaybackTime:playTime];
    
    if(wasPlaying)
        [musicPlayer play];
}

- (IBAction)nextSong:(id)sender
{
    NSTimeInterval time = [musicPlayer currentPlaybackTime];
    MPMediaItem *current = [musicPlayer nowPlayingItem];
    [musicPlayer skipToNextItem];
    audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
    NSLog(@"calling compute");
    [self compute:time forSong:current];
    numSongsHeard++;
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


#pragma mark - SIMPLE Algo
- (void) compute:(NSTimeInterval)time forSong:(MPMediaItem *)prev
{
    NSLog(@"reached compute1");
    float listened = time;
    float prevTrackLength = [[prev valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
    float prevPercent = (listened*100)/prevTrackLength;
    //float currentTrackLength = [[[musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
    //float percentOfCurrent = (((float)[musicPlayer currentPlaybackTime])*100)/currentTrackLength;
    int curr = [[idx objectForKey:[[musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyPersistentID]] integerValue];
    int previous = [[idx objectForKey:[prev valueForProperty:MPMediaItemPropertyPersistentID]] integerValue];
    if(prevPercent > 50.0 && prevPercent <= 80)
    {
        rewardMatrix[curr][previous] += 3;
        [self compute2:prevPercent forSong:prev];
        twoBack = prev;
        tBackPercent = prevPercent;
        step = YES;
    } else if(prevPercent > 80) {
        rewardMatrix[curr][previous] += 5;
        [self compute2:prevPercent forSong:prev];
        twoBack = prev;
        tBackPercent = prevPercent;
        step = YES;
    } else {
        rewardMatrix[curr][previous] += 0;
        [self compute2:prevPercent forSong:prev];
        twoBack = prev;
        tBackPercent = prevPercent;
        step = YES;
    }
}

- (void) compute2:(float)percent forSong:(MPMediaItem *)prev
{
    NSLog(@"reached compute2");
    if(step)
    {
        NSLog(@"entered compute2 calculations");
        if(tBackPercent < 50)
        {
            [self updateV:1 forSong:prev withTime:percent];
        } else if(tBackPercent >= 50 && tBackPercent < 80) {
            [self updateV:2 forSong:prev withTime:percent];
        } else {
            [self updateV:3 forSong:prev withTime:percent];
        }
    }
}

- (void) updateV:(int)which forSong:(MPMediaItem *)prev withTime:(float)percent
{
    NSLog(@"reached updateV");
    int updateIndex = [[idx objectForKey:[twoBack valueForProperty:MPMediaItemPropertyPersistentID]] integerValue];
    NSArray *keys = [songs allKeys];
    id aKey = [keys objectAtIndex:updateIndex];
    int prevIndex = [[idx objectForKey:[prev valueForProperty:MPMediaItemPropertyPersistentID]] integerValue];
    if(which == 1)
    {
        NSMutableArray *temp = [[songs objectForKey:aKey] objectForKey:@"v1"];
        int t = [[temp objectAtIndex:prevIndex] integerValue];
        if(percent < 50)
        {
            t += 0;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithInt:t]];
            
        } else if(percent >= 50 && percent < 80)
        {
            t += 3;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithInt:t]];
        } else {
            t += 5;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithInt:t]];
        }
        [[songs objectForKey:aKey] setValue:temp forKey:@"v1"];
        NSLog(@"%d", t);
    } else if(which == 2)
    {
        NSMutableArray *temp = [[songs objectForKey:aKey] objectForKey:@"v2"];
        int t = [[temp objectAtIndex:prevIndex] integerValue];
        if(percent < 50)
        {
            t += 0;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithInt:t]];
        } else if(percent >= 50 && percent < 80)
        {
            t += 3;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithInt:t]];
        } else {
            t += 5;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithInt:t]];
        }
        [[songs objectForKey:aKey] setValue:temp forKey:@"v2"];
    } else if(which == 3)
    {
        NSMutableArray *temp = [[songs objectForKey:aKey] objectForKey:@"v3"];
        int t = [[temp objectAtIndex:prevIndex] integerValue];
        if(percent < 50)
        {
            t += 0;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithInt:t]];
        } else if(percent >= 50 && percent < 80)
        {
            t += 3;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithInt:t]];
        } else {
            t += 5;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithInt:t]];
        }
        [[songs objectForKey:aKey] setValue:temp forKey:@"v3"];
    }
    NSString *filePath = [[self getFilePath] stringByAppendingPathComponent:@"data.plist"];
    [songs writeToFile:filePath atomically:YES];
}

@end