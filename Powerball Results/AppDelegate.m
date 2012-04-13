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
                  clientKey:@"DTFNe2YNrrp3gFayj4jBkIEeD4vDjnhK5AhMCs9X"];
    
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *selectionsData = [currentDefaults objectForKey:@"selections"];
    
    if (selectionsData) 
    {
        self.selections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:selectionsData]];
    }
    
    [self setupViewControllers];
    
    return YES;
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
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.selections] forKey:@"selections"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"App Resigned Active.");
}

- (void) applicationWillTerminate:(UIApplication *)application
{

}

@end
