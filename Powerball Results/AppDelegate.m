//
//  AppDelegate.m
//  Powerball Results
//
//  Created by Brad Grifffith on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "SelectorViewController.h"
#import "HistoryViewController.h"
#import "SelectorViewController.h"
#import "HistoryViewController.h"
#import <Parse/Parse.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize selections = _selections;
@synthesize drawDates;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"RitD22GrDUjVP3P04EdlvMu3IYJoRQmYoRYo2Sma" 
                  clientKey:@"DTFNe2YNrrp3gFayj4jBkIEeD4vDjnhK5AhMCs9X"]; //Dev
    
//    [Parse setApplicationId:@"uS5c2WJ8Osp94YRmWOHPEKL9NsNazKuS4eUIZ1Wl" 
//                  clientKey:@"qMMetsxWm44XomrL7a153GlCFVBKbNiipe5Z9iUj"]; //Prod
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge| UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeSound];
    
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *selectionsData = [currentDefaults objectForKey:@"selections"];
    
    if (selectionsData) {
        self.selections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:selectionsData]];
    } else {
        self.selections = [[NSMutableArray alloc] init];
    }
    
    [self setupViewControllers];
    
    return YES;
}

- (void)application:(UIApplication *)application 
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if ([error code] == 3010) {
        NSLog(@"Push notifications don't work in the simulator!");
    } else {
        NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

-(void) setupViewControllers
{
    self.tabBarController = (UITabBarController *)self.window.rootViewController;
    
    UINavigationController *navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:1];
    SelectorViewController *selectorViewController = (SelectorViewController *)[[navigationController viewControllers] objectAtIndex:0];  
    
    navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:2];
    HistoryViewController *historyViewController = (HistoryViewController *)[[navigationController viewControllers] objectAtIndex:0];

    selectorViewController.selections = self.selections;
    historyViewController.selections = self.selections;
}
 
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.selections] forKey:@"selections"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"App Resigned Active.");
}

// PUSH REGISTRATION

- (void)application:(UIApplication *)application 
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    [PFPush storeDeviceToken:newDeviceToken]; // Send parse the device token
    // Subscribe this user to the broadcast channel, "" 
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully subscribed to the broadcast channel.");
        } else {
            NSLog(@"Failed to subscribe to the broadcast channel.");
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end
