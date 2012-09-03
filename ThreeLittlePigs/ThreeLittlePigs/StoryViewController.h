//
//  StoryViewController.h
//  ThreeLittlePigs
//
//  Created by Vivek Murali on 30/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLPAppDelegate.h"
#import "ScenesModel.h"
#import "ScenesModelDelegate.h"
#import "ImageAndID.h"
#import <AVFoundation/AVFoundation.h>

@interface StoryViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *storyScrollView;
@property (strong, nonatomic) ScenesModel *model;
@property (strong, nonatomic) NSArray *scenes;
@property (strong, nonatomic) NSMutableArray *allScenesImagesAndIDs;
@property (weak, nonatomic) id <ScenesModelDelegate> modelDelegate;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) CGPoint previousSceneScrollPoint;

@end
