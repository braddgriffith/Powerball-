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
@synthesize user;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"RitD22GrDUjVP3P04EdlvMu3IYJoRQmYoRYo2Sma" 
                  clientKey:@"DTFNe2YNrrp3gFayj4jBkIEeD4vDjnhK5AhMCs9X"]; //Dev
    
//    [Parse setApplicationId:@"uS5c2WJ8Osp94YRmWOHPEKL9NsNazKuS4eUIZ1Wl" 
//                  clientKey:@"qMMetsxWm44XomrL7a153GlCFVBKbNiipe5Z9iUj"]; //Prod
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge| UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeSound];
    
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:100.0/255.0 green:190.0/255.0 blue:10.0/255.0 alpha:0.8]];
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *selectionsData = [currentDefaults objectForKey:@"selections"];
    NSData *userData = [currentDefaults objectForKey:@"user"];
    
    if (selectionsData) {
        self.selections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:selectionsData]];
    } else {
        self.selections = [[NSMutableArray alloc] init];
    }
    
    if (userData) {
        self.user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        NSLog(@"Loaded stored user.");
    } else {
        NSLog(@"No user. Creating anonymous user...");
        [PFUser enableAutomaticUser];
        [PFAnonymousUtils logInWithBlock:^(PFUser *currentUser, NSError *error) {
            if (error) {
                NSLog(@"Anonymous login failed.");
            } else {
                NSLog(@"Anonymous user logged in.");
                NSLog(@"Anonymous username = %@",currentUser.username);
            }
        }];
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
    //NSLog(@"Archiving :%@ selections", [self.selections count]);
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
