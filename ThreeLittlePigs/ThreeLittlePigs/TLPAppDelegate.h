//
//  TLPAppDelegate.h
//  ThreeLittlePigs
//
//  Created by Vivek Murali on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScenesModel.h"
#import "ScenesModelDelegate.h"

@interface TLPAppDelegate : UIResponder <UIApplicationDelegate, ScenesModelDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ScenesModel *model;

- (ScenesModel *)model;

@end
