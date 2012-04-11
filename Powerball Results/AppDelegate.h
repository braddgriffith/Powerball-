//
//  AppDelegate.h
//  Powerball Results
//
//  Created by Brad Grifffith on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Selection.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) NSMutableArray *drawDates;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) Selection *selection;

@end
