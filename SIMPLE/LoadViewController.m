//
//  LoadViewController.m
//  SIMPLE
//
//  Created by Rohan Sinha on 8/2/14.
//  Copyright (c) 2014 Rohan Sinha. All rights reserved.
//

#import "LoadViewController.h"

@interface LoadViewController ()

@end

@implementation LoadViewController
NSTimer *audioTimer;
float a = 0.00;
NSString *text;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [ad setImage:[UIImage imageNamed:@"ad_here.jpg"]];
    audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animateLoad) userInfo:nil repeats:YES];
    [progress setProgress:a animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setLabel
{
    [motion setText:text];
}

- (void) animateLoad
{
    a += .01;
    [progress setProgress:a animated:YES];
    text = @"Beginning SIMPLE...";
    if(a > 0.25)
        text = @"Initializing Library...";
    if(a > 0.50)
        text = @"Crunching Numbers...";
    if(a > 0.75)
        text = @"Optimizing Algorithm...";
    if(a > 0.98)
        text = @"Welcome to SIMPLE!";
    
    [self setLabel];
    /*if(a > 1.03)
        [self addChildViewController:[UIViewController PlayerController]];*/
}

@end
