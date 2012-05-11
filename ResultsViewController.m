//
//  ResultsViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResultsViewController.h"
#import <Parse/Parse.h>
#import  "Selection.h"
//#import "AppDelegate.h"
//#import "SelectorViewController.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController

@synthesize nextDateLabel;
@synthesize nextJackpotLabel;
@synthesize lastDateLabel;
@synthesize lastJackpotLabel;
@synthesize date1;
@synthesize date2;
@synthesize date3;
@synthesize date4;
@synthesize date5;
@synthesize winningsAndOddsTableView;
@synthesize allSelections;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getDrawData];

}

- (void)getDrawData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Drawings"];
    [query orderByDescending:@"Date"];
    query.limit = 100;
    
    NSMutableArray *selectionsAndPendingSelections = [[NSMutableArray alloc] init]; 
    if (!self.allSelections) {
        self.allSelections = [[NSMutableArray alloc] init];
    }
    
    __block int counter = 0;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Sent query.");
        if (!error) {
            NSLog(@"Successfully retrieved %d locations.", objects.count); 
            for (PFObject *object in objects) {  
                Selection *selection = [[Selection alloc] init];
                
                selection.jackpot = [object objectForKey:@"Jackpot"];
                selection.drawingDate = [object objectForKey:@"Date"];
                selection.selectionOne = [object objectForKey:@"Ball1"];
                selection.selectionTwo = [object objectForKey:@"Ball2"];
                selection.selectionThree = [object objectForKey:@"Ball3"];
                selection.selectionFour = [object objectForKey:@"Ball4"];
                selection.selectionFive = [object objectForKey:@"Ball5"];
                selection.selectionPowerball = [object objectForKey:@"BallPowerball"];
                selection.userID = nil;
                selection.userChosenDate = nil;
                
                [selectionsAndPendingSelections insertObject:selection atIndex:counter];                
                counter ++;
                NSLog(@"Spot %d - on %@ the powerball: %@ and jackpot: %@", counter, selection.drawingDate, selection.selectionPowerball, selection.jackpot);
            }
            self.allSelections = selectionsAndPendingSelections;
            [self setUpViewData];
        } else {
            UIAlertView * alert = [[UIAlertView alloc] 
                                   initWithTitle:@"Alert" 
                                   message:@"Couldn't connect to the network. Please try again later." 
                                   delegate:self cancelButtonTitle:@"Hide" 
                                   otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];            
        }
    }];
    query = nil;
}

- (void)setUpViewData
{
    //    //Calculate the next draw date in EST
    //    NSDate *nextDrawDateEST = [self getNextDrawDate]; //returns next draw date in EST
    //    double interval = [self getTimeZoneOffset]; //gets the offset from Today and EST
    //    upcomingDrawDate = [nextDrawDateEST dateByAddingTimeInterval:interval]; //finds the local next drawDate
    //    
    //    //Put next draw date on screen
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //create a date formatter
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]]; //Current time of local timezone - drawings are 10:59PM EST
    [dateFormatter setDateFormat:@"EEEE - h:mm a"];//Was @"MM/dd h:mm a"];
    //    NSString *dateStr = [dateFormatter stringFromDate:upcomingDrawDate];
    //    
    //    nextDateLabel.text = dateStr;
    
    
    Selection *nextDraw = [self.allSelections objectAtIndex:0];
    NSLog(@"NextDraw %@", nextDraw.jackpot);
    nextJackpotLabel.text = nextDraw.jackpot;
    
    Selection *lastDraw = [self.allSelections objectAtIndex:1];
    NSLog(@"LastJackpot: %@", lastDraw.jackpot);
    lastJackpotLabel.text = lastDraw.jackpot;
    
    Selection *drawResult = [[Selection alloc] init];
    NSArray *dates = [[NSArray alloc] initWithObjects:date1, date2, date3, date4, date5, nil];
    for (int x=1; x<=5; x++) {
        drawResult = [self.allSelections objectAtIndex:(1+x)]; //Start at the third Draw
        UILabel *currentDate = [dates objectAtIndex:(-1+x)]; //Start at the first label
        currentDate.text = drawResult.jackpot;
        NSLog(@"Selection# %@ on %@ for %@", [NSString stringWithFormat:@"%d", x], [dateFormatter stringFromDate:drawResult.drawingDate], drawResult.jackpot);
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
