//
//  ViewController.m
//  SIMPLE
//
//  Created by Rohan Sinha on 21/05/13.
//  Copyright (c) 2013 Rohan Sinha. All rights reserved.
//

#import "ReflectionView.h"
#import "PlayerController.h"
#import<math.h>
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
float rewardMatrix[1000][1000];
float normalizedReward[1000];
NSMutableDictionary *songs;
NSMutableDictionary *idx;
NSMutableArray *v1;
NSMutableArray *v2;
NSMutableArray *v3;
BOOL newUser = YES;
NSMutableArray *policy1;
NSMutableArray *policy2;
NSMutableArray *rewards;
//NSMutableArray *r1;
//NSMutableArray *r2;
//NSMutableArray *r3;

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
    if([musicPlayer playbackState] == MPMusicPlaybackStateStopped || [musicPlayer playbackState] == MPMusicPlaybackStatePaused)
        [playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:normal];
    else [playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:normal];
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
    NSString *rwd = [[self getFilePath] stringByAppendingPathComponent:@"rewards.plist"];
    NSString *filePath = [[self getFilePath] stringByAppendingPathComponent:@"data.plist"];
    NSString *mapper = [[self getFilePath] stringByAppendingPathComponent:@"mapper.plist"];
    NSString *pol1 = [[self getFilePath] stringByAppendingPathComponent:@"policy1.plist"];
    NSString *pol2 = [[self getFilePath] stringByAppendingPathComponent:@"policy2.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:rwd])
    {
        songs = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        idx = [[NSMutableDictionary alloc] initWithContentsOfFile:mapper];
        policy1 = [[NSMutableArray alloc] initWithContentsOfFile:pol1];
        policy2 = [[NSMutableArray alloc] initWithContentsOfFile:pol2];
        rewards = [[NSMutableArray alloc] initWithContentsOfFile:rwd];
        newUser = NO;
        for(int i = 0; i < [rewards count]; i++)
        {
            NSMutableArray *tempRwd = [rewards objectAtIndex:i];
            for(int j = 0; j < [rewards count]; j++)
                rewardMatrix[i][j] = [[tempRwd objectAtIndex:j] floatValue];
        }
        
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
                rewardMatrix[i][j] = 0.00;
            }
        }
        idx = [[NSMutableDictionary alloc] init];
        //r1 = [[NSMutableArray alloc] init];
        //r2 = [[NSMutableArray alloc] init];
        //r3 = [[NSMutableArray alloc] init];
        v1 = [[NSMutableArray alloc] init];
        v2 = [[NSMutableArray alloc] init];
        v3 = [[NSMutableArray alloc] init];
        //Initializing songs
        NSArray *fullList = [query items];
        songs = [[NSMutableDictionary alloc] init];
        //NSNumber *zero = [NSNumber numberWithInt:0];
        float a = (1/(float)n); //float contributed by nirvik
        //NSLog(@"%f", a);
        NSNumber *calc = [NSNumber numberWithFloat:a];
        for(int i = 0; i < 1000; i++)
        {
            //[r1 addObject:zero];
            //[r2 addObject:zero];
            //[r3 addObject:zero];
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
        //[sid setObject:r1 forKey:@"r1"];
        //[sid setObject:r2 forKey:@"r2"];
        //[sid setObject:r3 forKey:@"r3"];
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
        [idx writeToFile:mapper atomically:YES];
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
        /*[musicPlayer skipToPreviousItem];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];*/
        [self prevSong:recognizer];
    }
}

- (void)reportRightSwipe:(UIGestureRecognizer *)recognizer
{
    if(![self displayMode])
    {
        /*[musicPlayer skipToNextItem];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];*/
        [self nextSong:recognizer];
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
        NSTimeInterval time = [musicPlayer currentPlaybackTime];
        MPMediaItem *current = [musicPlayer nowPlayingItem];
        [musicPlayer skipToPreviousItem];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
        NSLog(@"calling compute");
        [self compute:time forSong:current];
        numSongsHeard++;
    } else {
        NSTimeInterval time = [musicPlayer currentPlaybackTime];
        MPMediaItem *current = [musicPlayer nowPlayingItem];
        [musicPlayer skipToBeginning];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioProgressUpdate) userInfo:nil repeats:YES];
        NSLog(@"calling compute");
        [self compute:time forSong:current];
        numSongsHeard++;
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
/*
- (void)testQueue:(id)sender
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
*/
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
    if(prevPercent > 50.0 && prevPercent <= 80.0)
    {
        rewardMatrix[curr][previous] += 3.00;
        [self compute2:prevPercent forSong:prev];
        twoBack = prev;
        tBackPercent = prevPercent;
        step = YES;
    } else if(prevPercent > 80) {
        rewardMatrix[curr][previous] += 5.00;
        [self compute2:prevPercent forSong:prev];
        twoBack = prev;
        tBackPercent = prevPercent;
        step = YES;
    } else {
        rewardMatrix[curr][previous] += 0.00;
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
        if(tBackPercent < 50.0)
        {
            [self updateV:1 forSong:prev withTime:percent];
        } else if(tBackPercent >= 50.0 && tBackPercent < 80.0) {
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
        float t = [[temp objectAtIndex:prevIndex] floatValue];
        if(percent < 50.0)
        {
            t += 0.00;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithFloat:t]];
            
        } else if(percent >= 50.0 && percent < 80.0)
        {
            t += 3.00;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithFloat:t]];
        } else {
            t += 5.00;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithFloat:t]];
        }
        [[songs objectForKey:aKey] setValue:temp forKey:@"v1"];
        NSLog(@"%f", t);
        NSLog(@"v1:\n%@", temp);
    } else if(which == 2)
    {
        NSMutableArray *temp = [[songs objectForKey:aKey] objectForKey:@"v2"];
        float t = [[temp objectAtIndex:prevIndex] floatValue];
        if(percent < 50.0)
        {
            t += 0.00;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithFloat:t]];
        } else if(percent >= 50.0 && percent < 80.0)
        {
            t += 3.00;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithFloat:t]];
        } else {
            t += 5.00;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithFloat:t]];
        }
        [[songs objectForKey:aKey] setValue:temp forKey:@"v2"];
        NSLog(@"%f", t);
        NSLog(@"v2:\n%@", temp);
    } else if(which == 3)
    {
        NSMutableArray *temp = [[songs objectForKey:aKey] objectForKey:@"v3"];
        float t = [[temp objectAtIndex:prevIndex] floatValue];
        if(percent < 50.0)
        {
            t += 0.00;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithFloat:t]];
        } else if(percent >= 50.0 && percent < 80.0)
        {
            t += 3.00;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithFloat:t]];
        } else {
            t += 5.00;
            [temp replaceObjectAtIndex:prevIndex withObject:[NSNumber numberWithFloat:t]];
        }
        [[songs objectForKey:aKey] setValue:temp forKey:@"v3"];
        NSLog(@"%f", t);
        NSLog(@"v3:\n%@", temp);
    }
    
    NSString *databasePath = [[self getFilePath] stringByAppendingPathComponent:@"data.plist"];
    [songs writeToFile:databasePath atomically:YES];
    if(numSongsHeard > 5)
        [self predict:prev heard:percent];
}

- (void) predict:(MPMediaItem *)current heard:(float)percentHeard
{
    //int index = [[idx objectForKey:[current valueForProperty:MPMediaItemPropertyPersistentID]] integerValue];
    NSLog(@"Predicting");
    MPMediaQuery *query = [MPMediaQuery songsQuery]; //filter songs...remove videos and shit
    int n = [[query items] count];
    float sumReward = 0.00;
    float sumColoumn[n];
    float sumV = 0.00;
    id aKey;
    float tempV[n];
    NSArray *keys = [songs allKeys];
    //Notmalizng reward matrix
    for(int i = 0; i < n; i++)
    {
        sumColoumn[i] = 0;
        for(int j = 0; j < n; j++)
        {
            sumReward += rewardMatrix[i][j];
            sumColoumn[i] += rewardMatrix[j][i];
        }
    }
    sumReward = sqrtf(sumReward);
    if(sumReward > 0)
    {
        for(int i = 0; i < n; i++)
        {
            normalizedReward[i] = sumColoumn[i]/(float)sumReward;
        }
    }
    float p1[n];
    float p2[n];
    
    //Normalizing Vi
    if(percentHeard < 50.0)
    {
        //r1
        for(int i = 0; i < n; i++)
        {
            aKey = [keys objectAtIndex:i];
            //sumV += [[[[songs objectForKey:aKey] objectForKey:@"v1"] objectAtIndex:i] floatValue];
            //[temp addObject:[NSNumber numberWithFloat:[[[[songs objectForKey:aKey] objectForKey:@"v1"] objectAtIndex:i] floatValue]]];
            tempV[i] = [[[[songs objectForKey:aKey] objectForKey:@"v1"] objectAtIndex:i] floatValue];
            NSLog(@"normalizing v1\n%f", tempV[i]);
            sumV += tempV[i];
        }
        
        if(sumV > 0)
        {
            for(int i = 0; i < n; i++)
            {
                tempV[i] = tempV[i]/sqrtf(sumV);
            }
        }
    } else if(percentHeard >= 50.0 && percentHeard < 80.0)
    {
        //r2
        for(int i = 0; i < n; i++)
        {
            aKey = [keys objectAtIndex:i];
            //[temp addObject:[NSNumber numberWithFloat:[[[[songs objectForKey:aKey] objectForKey:@"v1"] objectAtIndex:i] floatValue]]];
            tempV[i] = [[[[songs objectForKey:aKey] objectForKey:@"v2"] objectAtIndex:i] floatValue];
            NSLog(@"normalizing v2\n%f", tempV[i]);
            sumV += tempV[i];
        }
        
        if(sumV > 0)
        {
            for(int i = 0; i < n; i++)
            {
                tempV[i] = tempV[i]/sqrtf(sumV);
            }
        }
    } else {
        //r3
        for(int i = 0; i < n; i++)
        {
            aKey = [keys objectAtIndex:i];
            //[temp addObject:[NSNumber numberWithFloat:[[[[songs objectForKey:aKey] objectForKey:@"v1"] objectAtIndex:i] floatValue]]];
            tempV[i] = [[[[songs objectForKey:aKey] objectForKey:@"v3"] objectAtIndex:i] floatValue];
            NSLog(@"normalizing v3\n%f", tempV[i]);
            sumV += tempV[i];
        }
        
        if(sumV > 0)
        {
            for(int i = 0; i < n; i++)
            {
                tempV[i] = tempV[i]/sqrtf(sumV);
            }
        }
    }
    if(newUser)
    {
        for(int i = 0; i < n; i++)
        {
            p1[i] = (float)(1/n);
            p2[i] = (float)(1/n);
        }
        newUser = NO;
    } else {
        for(int i = 0; i < n; i++)
        {
            p1[i] = [[policy1 objectAtIndex:i] floatValue];
            p2[i] = [[policy2 objectAtIndex:i] floatValue];
        }
        for(int i = 0; i < n; i++)
        {
            p1[i] += (0.85*(normalizedReward[i]-(0.85*p1[i])));
            p2[i] += (0.85*(tempV[i]-(0.85*p2[i])));
        }
    }
    NSString *databasePath = [[self getFilePath] stringByAppendingPathComponent:@"data.plist"];
    [songs writeToFile:databasePath atomically:YES];
    //Prediction--Queue Gen
    float q[n];
    float max = 0;
    int maxIndex = 0;
    for(int i = 0; i < n; i++)
    {
        q[i] = (p1[i]*0.6)+(0.4*p2[i]);
        if(q[i] > max)
        {
            max = q[i];
            maxIndex = i;
        }
    }
    NSArray *allKeysForMax = [idx allKeysForObject:[NSNumber numberWithInt:maxIndex]];
    //[MPMediaItemCollection collectionWithItems:(NSArray *) allKeysForMax];
    NSString *pID = [allKeysForMax objectAtIndex:0];
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:pID forProperty:MPMediaItemPropertyPersistentID];
    MPMediaQuery *songQuery = [[MPMediaQuery alloc] init];
    [songQuery addFilterPredicate:predicate];
    NSArray *queue = [songQuery items];
    [self setNowPlayingQueue:[MPMediaItemCollection collectionWithItems:(NSArray *) queue]];
    [musicPlayer setQueueWithItemCollection:nowPlayingQueue];
    [musicPlayer play];
    NSString *pol1 = [[self getFilePath] stringByAppendingPathComponent:@"policy1.plist"];
    NSString *pol2 = [[self getFilePath] stringByAppendingPathComponent:@"policy2.plist"];
    NSString *rwd = [[self getFilePath] stringByAppendingPathComponent:@"rewards.plist"];
    for(int i = 0; i < n; i++)
    {
        NSMutableArray *tempReward = [[NSMutableArray alloc] init];
        [policy1 addObject:[NSNumber numberWithFloat:p1[i]]];
        [policy2 addObject:[NSNumber numberWithFloat:p2[i]]];
        for(int j = 0; j < n; j++)
        {
            [tempReward addObject:[NSNumber numberWithFloat:rewardMatrix[i][j]]];
        }
        [rewards addObject:tempReward];
    }
    [policy1 writeToFile:pol1 atomically:YES];
    [policy2 writeToFile:pol2 atomically:YES];
    [rewards writeToFile:rwd atomically:YES];
    //destroy policy1, policy2, rewards
    [policy1 removeAllObjects];
    [policy2 removeAllObjects];
    [rewards removeAllObjects];
}

@end