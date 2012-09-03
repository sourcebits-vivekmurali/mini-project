//
//  ScenesModelDelegate.h
//  ThreeLittlePigs
//
//  Created by Vivek Murali on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScenesModel.h"

@protocol ScenesModelDelegate <NSObject>

- (ScenesModel *)modelSharedInstance;

@end
