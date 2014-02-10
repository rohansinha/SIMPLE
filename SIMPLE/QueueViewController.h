//
//  QueueViewController.h
//  SIMPLE
//
//  Created by Rohan Sinha on 16/11/13.
//  Copyright (c) 2013 Rohan Sinha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface QueueViewController : UITableViewController

@property (copy, nonatomic) MPMediaItemCollection *playQueue;
@property (weak, nonatomic) id delegate;

- (IBAction)dismiss:(id)sender;

@end
