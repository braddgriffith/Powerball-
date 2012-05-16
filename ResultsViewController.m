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
#import "Time.h"

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
@synthesize results1;
@synthesize results2;
@synthesize results3;
@synthesize results4;
@synthesize results5;
@synthesize winningsAndOddsTableView;
@synthesize allSelections;

@synthesize upcomingDrawDate;

UIActivityIndicatorView *spinner;
BOOL firstTime;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.center = CGPointMake(self.view.frame.size.width - spinner.bounds.size.width/2.0f - 10, self.view.frame.size.height / 2.0f);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    firstTime = YES;
    
    [self getDrawData];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"ViewWillAppear firstTime:%d",firstTime);
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
    
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Sent query.");
        if (!error) {
            NSLog(@"Successfully retrieved %d locations.", objects.count); 
            for (PFObject *object in objects) {  
                Selection *selection = [[Selection alloc] init];
                
                selection.jackpot = [object objectForKey:@"Jackpot"];
                selection.drawingDate = [object objectForKey:@"Date"];
                selection.selectionOne = [formatter numberFromString:[object objectForKey:@"Ball1"]];
                selection.selectionTwo = [formatter numberFromString:[object objectForKey:@"Ball2"]];//[object objectForKey:@"Ball2"];
                selection.selectionThree = [formatter numberFromString:[object objectForKey:@"Ball3"]];//[object objectForKey:@"Ball3"];
                selection.selectionFour = [formatter numberFromString:[object objectForKey:@"Ball4"]];//[object objectForKey:@"Ball4"];
                selection.selectionFive = [formatter numberFromString:[object objectForKey:@"Ball5"]];//[object objectForKey:@"Ball5"];
                selection.selectionPowerball = [formatter numberFromString:[object objectForKey:@"BallPowerball"]];//[object objectForKey:@"BallPowerball"];
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
    [spinner removeFromSuperview];
    spinner = nil;
}

- (void)setUpViewData
{
    //Put next draw date on screen
    Time *theTime = [[Time alloc] init];
    NSDate *nextDrawDateEST = [theTime getDrawDate:@"forward"]; 
    double interval = [theTime getTimeZoneOffset];
    upcomingDrawDate = [nextDrawDateEST dateByAddingTimeInterval:interval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //create a date formatter
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]]; //Current time of local timezone - drawings are 10:59PM EST
    [dateFormatter setDateFormat:@"EEEE - h:mm a"];
    NSString *dateStr = [dateFormatter stringFromDate:upcomingDrawDate];
     
    nextDateLabel.text = dateStr;
    
    NSDate *lastDrawDateEST = [theTime getDrawDate:@"backward"]; 
    interval = [theTime getTimeZoneOffset];
    NSDate *lastDrawDate = [lastDrawDateEST dateByAddingTimeInterval:interval];
    dateStr = [dateFormatter stringFromDate:lastDrawDate];
    
    lastDateLabel.text = dateStr;
    
    Selection *nextDraw = [self.allSelections objectAtIndex:0];
    NSLog(@"NextDraw %@", nextDraw.jackpot);
    nextJackpotLabel.text = nextDraw.jackpot;
    
    Selection *lastDraw = [self.allSelections objectAtIndex:1];
    NSLog(@"LastJackpot: %@", lastDraw.jackpot);
    lastJackpotLabel.text = lastDraw.jackpot;
    
    Selection *drawResult = [[Selection alloc] init];
    NSArray *dates = [[NSArray alloc] initWithObjects:date1, date2, date3, date4, date5, nil];
    NSArray *results = [[NSArray alloc] initWithObjects:results1, results2, results3, results4, results5, nil];
    
    [dateFormatter setDateFormat:@"M/dd/yy"];//yyyy"];//@"MM/dd/yyyy"];
    
    for (int x=1; x<=5; x++) {
        drawResult = [self.allSelections objectAtIndex:(1+x)]; //Start at the third Draw
        UILabel *currentDate = [dates objectAtIndex:(-1+x)]; //Start at the first label
        UILabel *currentResult = [results objectAtIndex:(-1+x)]; //Start at the first label
        
        NSDate *givenDate = drawResult.drawingDate;
        NSString *newDateStr = [[dateFormatter stringFromDate:givenDate]stringByAppendingString:@":"];
        NSLog(@"Weekday: %@", newDateStr);        
        
        currentDate.text = newDateStr;
    
        NSString *selectionList = [[drawResult.selectionOne stringValue] stringByAppendingString:@"-"];
        selectionList = [selectionList stringByAppendingString:[drawResult.selectionTwo stringValue]];
        selectionList = [selectionList stringByAppendingString:@"-"];
        selectionList = [selectionList stringByAppendingString:[drawResult.selectionThree stringValue]];
        selectionList = [selectionList stringByAppendingString:@"-"];
        selectionList = [selectionList stringByAppendingString:[drawResult.selectionFour stringValue]];
        selectionList = [selectionList stringByAppendingString:@"-"];
        selectionList = [selectionList stringByAppendingString:[drawResult.selectionFive stringValue]];
        selectionList = [selectionList stringByAppendingString:@"-"];
        selectionList = [selectionList stringByAppendingString:[drawResult.selectionPowerball stringValue]];
        
        currentResult.text = selectionList;
        
        NSLog(@"Selection# %@ on %@ for %@", [NSString stringWithFormat:@"%d", x], [dateFormatter stringFromDate:givenDate], drawResult.jackpot);
    }
    [self addResults];
}

- (void)addResults
{
    int xindent = 15; //distance from left side for first item - aka X
    int xbuffer = 10; //distance between items
    int ystart = 140; //distance from top for items - aka Y
    int numItems = 6; //number of items
    int screenWidth = self.view.frame.size.width; 
    int xsize = (screenWidth - (2*xindent) - (numItems*xbuffer)) / numItems;
    
    for (int x=1; x<=numItems; x++) {
        CGRect frame = CGRectMake(xindent+((x-1)*(xsize+xbuffer)), ystart, xsize, xsize);
        NSLog(@"Width: %i", xsize);
        
//        UIImage *myImage = [UIImage imageNamed:@"13-target.png"];
//        NSString *myWatermarkText = @"7&&&&";
//        UIImage *watermarkedImage = nil;
//        UIGraphicsBeginImageContext(myImage.size);
//        //[myImage drawAtPoint: CGPointMake(xindent+((x-1)*(xsize+xbuffer)),ystart)];
//        [myImage drawAtPoint: CGPointZero];
//        [myWatermarkText drawAtPoint: CGPointMake(10, 10) withFont: [UIFont systemFontOfSize: 20]];
//        watermarkedImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        endView.image = myImage;
//        [self.view addSubview:endView];
        
        UIImageView *endView = [[UIImageView alloc] initWithFrame:frame];
        endView.image = [UIImage imageNamed:@"13-target.png"];
        [self.view addSubview:endView];
        
        if (firstTime) {
            float animationDuration = (x * 0.1f + 1.0f);
            
            CABasicAnimation *ballMover = [CABasicAnimation animationWithKeyPath:@"position"];
            ballMover.removedOnCompletion = NO;
            ballMover.fillMode = kCAFillModeForwards;
            ballMover.duration = animationDuration;
            ballMover.fromValue = [NSValue valueWithCGPoint:CGPointMake(endView.center.x + (x*screenWidth), endView.center.y)];
            ballMover.toValue = [NSValue valueWithCGPoint:endView.center];
            ballMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            [endView.layer addAnimation:ballMover forKey:@"ballMover"];
            
            CABasicAnimation *ballRotator = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            ballRotator.removedOnCompletion = NO;
            ballRotator.fillMode = kCAFillModeForwards;
            ballRotator.duration = animationDuration;
            ballRotator.fromValue = [NSNumber numberWithFloat:0];
            ballRotator.toValue = [NSNumber numberWithFloat:-2*M_PI];
            ballRotator.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            [endView.layer addAnimation:ballRotator forKey:@"ballRotator"];
        }
    }
    firstTime = NO;
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
