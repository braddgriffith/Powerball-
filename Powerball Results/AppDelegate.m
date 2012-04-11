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

@implementation AppDelegate

@synthesize window = _window;
@synthesize selections = _selections;
@synthesize drawDates;
@synthesize tabBarController;
@synthesize selection;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *selectionsData = [currentDefaults objectForKey:@"selections"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(randomSelectionMadeNotification:) 
                                                 name:@"RandomSelectionMadeNotification"
                                               object:nil];
    
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
    
    UINavigationController *navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:2];
    SelectorViewController *selectorViewController = (SelectorViewController *)[[navigationController viewControllers] objectAtIndex:0];  
    
    navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:3];
    HistoryViewController *historyViewController = (HistoryViewController *)[[navigationController viewControllers] objectAtIndex:0];

    selectorViewController.selections = self.selections;
    historyViewController.selections = self.selections;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.selections] forKey:@"selections"];
    NSLog(@"App Resigned Active.");
}

- (void) randomSelectionMadeNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"RandomSelectionMadeNotification"])
    {
        NSLog (@"Successfully received the RandomSelectionMadeNotification notification!");
        
        // Get views. controllerIndex is passed in as the controller we want to go to. 
        UIView * fromView = tabBarController.selectedViewController.view;
        UIView * toView = [[tabBarController.viewControllers objectAtIndex:2] view];
        
        // Transition using a flip.
        [UIView transitionFromView:fromView 
                            toView:toView 
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL finished) {
                            if (finished) {
                                tabBarController.selectedIndex = 2;
                            }
                        }
         ];
    }
}

- (void) applicationWillTerminate:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationMadeNotification" object:nil];
}

@end
