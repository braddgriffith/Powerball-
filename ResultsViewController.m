//
//  ResultsViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResultsViewController.h"
#import <Parse/Parse.h>
#import "Selection.h"
#import "Time.h"
#import "Payout.h"

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
@synthesize payoutsTableView;

@synthesize allSelections;
@synthesize allPayouts;
@synthesize upcomingDrawDate;
@synthesize scrollView;
@synthesize spinner;

@synthesize emailBody;
@synthesize emailSubject;

BOOL firstTime = YES;

//LabelHeights
int nextLabelH = 8;
int jackpotLabelY = 32;
int nextLabelWidth = 45;
int jackpotLabelWidth = 70;
int lastLabelY = 68;
int lastLabelWidth = 45;
int lastJackpotVariableLabelY = 139;
int lastJackpotVariableLabelWidth = 170; 

//StarTrans
int starTransitionHeight = 64;

//Big ball spacing
int xindent = 24;//17; //distance from left side for first item - aka X
int xbuffer = 7; //distance between items
int ystart = 97; //distance from top for items - aka Y
int numItems = 6; //number of items
int numSpecial = 1; //number of special items

//Small ball spacing
int xSmallBuffer = 7;

//Label spacing
int xLindent = 25; //distance from left side for first item - aka X
int yLheight = 28; //distance from last row - aka Y

int yhistoryDateLabel = 182;
int yhistoryBallAdjust = 1;
int dateLabelWidth = 63;

//Scrollview 
int scrollviewHeight = 620;

//GroupButton
int groupButtonWidth = 42;
int groupButtonY = 14;

NSMutableArray *matchingArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.date1 setHidden:YES];
    [self.date2 setHidden:YES];
    [self.date3 setHidden:YES];
    [self.date4 setHidden:YES];
    [self.date5 setHidden:YES];
    [self.nextDateLabel setHidden:YES];
    [self.nextJackpotLabel setHidden:YES];
    [self.lastJackpotLabel setHidden:YES];
    [self.lastDateLabel setHidden:YES];
    [self.payoutsTableView.tableView setHidden:YES];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, scrollviewHeight); //Should be algorithmic based on size of content
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Stars02.png"]];
    
    matchingArray = [[NSMutableArray alloc] init];
    [matchingArray addObject:@"selectionOne"];
    [matchingArray addObject:@"selectionTwo"];
    [matchingArray addObject:@"selectionThree"];
    [matchingArray addObject:@"selectionFour"];
    [matchingArray addObject:@"selectionFive"];
    [matchingArray addObject:@"selectionPowerball"];
    
    //Payouts tableView
    int payoutsViewCenterX = self.scrollView.frame.size.width/2;// 160;
    int payoutsViewCenterY;
    if (payoutsViewCenterX == 160) { //if iPhone
        payoutsViewCenterY = 494;
    } else {
        payoutsViewCenterY = 790;
        xindent = 250;
        xLindent = 250;
        payoutsViewCenterX = self.scrollView.frame.size.width/2 + 240 ;
    }
    
    self.payoutsTableView.tableView.center = CGPointMake(payoutsViewCenterX,payoutsViewCenterY);
    self.payoutsTableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.payoutsTableView.tableView.scrollEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSLog(@"ViewWillAppear firstTime:%d",firstTime);
    [self getDrawData];
    
    self.spinner.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    self.spinner.hidesWhenStopped = YES;
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
}

- (void)getDrawData //Gets all the draw data from Parse
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
            NSLog(@"Successfully retrieved %d past jackpots and drawing results.", objects.count); 
            for (PFObject *object in objects) {  
                Selection *selection = [[Selection alloc] init];
                
                selection.jackpot = [object objectForKey:@"Jackpot"];
                selection.drawingDate = [object objectForKey:@"Date"];
                selection.selectionOne = [formatter numberFromString:[object objectForKey:@"Ball1"]];
                selection.selectionTwo = [formatter numberFromString:[object objectForKey:@"Ball2"]];
                selection.selectionThree = [formatter numberFromString:[object objectForKey:@"Ball3"]];
                selection.selectionFour = [formatter numberFromString:[object objectForKey:@"Ball4"]];
                selection.selectionFive = [formatter numberFromString:[object objectForKey:@"Ball5"]];
                selection.selectionPowerball = [formatter numberFromString:[object objectForKey:@"BallPowerball"]];
                selection.userID = nil;
                selection.userChosenDate = nil;
                selection.matches = nil;
                selection.specialMatches = nil;
                
                [selectionsAndPendingSelections insertObject:selection atIndex:counter];                
                counter ++;
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

- (void)setUpViewData //Does all the view setup, then calls AddResults
{    
    [self.nextDateLabel setHidden:NO];
    [self.nextJackpotLabel setHidden:NO];
    [self.lastJackpotLabel setHidden:NO];
    [self.lastDateLabel setHidden:NO];
    [self.payoutsTableView.tableView setHidden:NO];
    
    Time *theTime = [[Time alloc] init];
    NSDate *nextDrawDateEST = [theTime getDrawDate:@"forward"]; 
    double interval = [theTime getTimeZoneOffset];
    upcomingDrawDate = [nextDrawDateEST dateByAddingTimeInterval:interval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //create a date formatter
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]]; //Current time of local timezone - drawings are 10:59PM EST
    [dateFormatter setDateFormat:@"EEEE - h:mm a"];
    NSString *dateStr = [dateFormatter stringFromDate:upcomingDrawDate];
     
    UILabel *nextLabel = [[UILabel alloc] initWithFrame:CGRectMake(xLindent,nextLabelH,nextLabelWidth,yLheight)];
    nextLabel.font = [UIFont boldSystemFontOfSize:16]; //[UIFont systemFontOfSize:16];
    nextLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:190.0/255.0 blue:10.0/255.0 alpha:1.0];//[UIColor redColor];
    nextLabel.textAlignment = UITextAlignmentLeft;
    nextLabel.backgroundColor = [UIColor clearColor];
    nextLabel.text = @"Next:";
    [self.scrollView addSubview:nextLabel];
    self.nextDateLabel.frame = CGRectMake(xLindent+nextLabelWidth,nextLabelH,255,yLheight);
    
    
    UIButton *groupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    groupButton.frame = CGRectMake(self.scrollView.frame.size.width - xLindent - groupButtonWidth, groupButtonY, groupButtonWidth, groupButtonWidth);
    [groupButton addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
    [groupButton setBackgroundColor:[UIColor blackColor]];
    float cornerRadius = 10.0;
    [groupButton.layer setBorderWidth:2.0];
    [groupButton.layer setCornerRadius:cornerRadius];
    [groupButton.layer setBorderColor:[[UIColor colorWithRed:100.0/255.0 green:190.0/255.0 blue:10.0/255.0 alpha:1.0] CGColor]];//colorWithWhite:0.9 alpha:0.9] CGColor]];
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = groupButton.bounds;
    shineLayer.cornerRadius = cornerRadius;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [groupButton.layer addSublayer:shineLayer];
    UIImage *groupButtonImage = [UIImage imageNamed:@"286-speechbubble.png"];
    //[groupButton setBackgroundImage:[groupButtonImage stretchableImageWithLeftCapWidth:cornerRadius topCapHeight:cornerRadius] forState:UIControlStateNormal];
    [groupButton setImage:groupButtonImage forState:UIControlStateNormal];
    [self.scrollView addSubview:groupButton];
    
    UILabel *jackpotLabel = [[UILabel alloc] initWithFrame:CGRectMake(xLindent,jackpotLabelY,jackpotLabelWidth,yLheight)];
    jackpotLabel.font = [UIFont boldSystemFontOfSize:16];
    jackpotLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:190.0/255.0 blue:10.0/255.0 alpha:1.0];//[UIColor redColor];
    jackpotLabel.textAlignment = UITextAlignmentLeft;
    jackpotLabel.backgroundColor = [UIColor clearColor];
    jackpotLabel.text = @"Jackpot:";
    [self.scrollView addSubview:jackpotLabel];
    self.nextJackpotLabel.frame = CGRectMake(xLindent+jackpotLabelWidth,jackpotLabelY,255,yLheight);
    
    UILabel *lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(xLindent,lastLabelY,lastLabelWidth,yLheight)];
    lastLabel.font = [UIFont boldSystemFontOfSize:16];
    lastLabel.textColor = [UIColor whiteColor];
    lastLabel.textAlignment = UITextAlignmentLeft;
    lastLabel.backgroundColor = [UIColor clearColor];
    lastLabel.text = @"Last:";
    [self.scrollView addSubview:lastLabel];
    self.lastDateLabel.frame = CGRectMake(xLindent+lastLabelWidth,lastLabelY,255,yLheight);
    self.lastDateLabel.textColor = [UIColor whiteColor];
    
    UILabel *whiteJackpotLabel = [[UILabel alloc] initWithFrame:CGRectMake(xLindent,lastJackpotVariableLabelY,jackpotLabelWidth,yLheight)];
    whiteJackpotLabel.font = [UIFont boldSystemFontOfSize:16];
    whiteJackpotLabel.textColor = [UIColor whiteColor];
    whiteJackpotLabel.textAlignment = UITextAlignmentLeft;
    whiteJackpotLabel.backgroundColor = [UIColor clearColor];
    whiteJackpotLabel.text = @"Jackpot:";
    [self.scrollView addSubview:whiteJackpotLabel];
    self.lastJackpotLabel.frame = CGRectMake(xLindent+jackpotLabelWidth,lastJackpotVariableLabelY,lastJackpotVariableLabelWidth,yLheight);
    self.lastJackpotLabel.textColor = [UIColor whiteColor];
    
    self.nextDateLabel.text = dateStr;
    
    //Put LAST draw date on screen
    NSDate *lastDrawDateEST = [theTime getDrawDate:@"backward"]; 
    interval = [theTime getTimeZoneOffset];
    NSDate *lastDrawDate = [lastDrawDateEST dateByAddingTimeInterval:interval];
    [dateFormatter setDateFormat:@"EEEE - M/dd/yy"];
    dateStr = [dateFormatter stringFromDate:lastDrawDate];
    
    lastDateLabel.text = dateStr;
    
    Selection *nextDraw = [self.allSelections objectAtIndex:0];
    NSLog(@"NextDraw %@", nextDraw.jackpot);
    self.nextJackpotLabel.text = nextDraw.jackpot;
    
    Selection *lastDraw = [self.allSelections objectAtIndex:1];
    NSLog(@"LastJackpot: %@", lastDraw.jackpot);
    lastJackpotLabel.text = lastDraw.jackpot;
    
    Selection *drawResult = [[Selection alloc] init];
    NSArray *dates = [[NSArray alloc] initWithObjects:date1, date2, date3, date4, date5, nil];
    
    [dateFormatter setDateFormat:@"M/dd/yy"];
    
    [self.date1 setHidden:NO];
    [self.date2 setHidden:NO];
    [self.date3 setHidden:NO];
    [self.date4 setHidden:NO];
    [self.date5 setHidden:NO];
    
    for (int x=1; x<=5; x++) { //Adds the historical results
        drawResult = [self.allSelections objectAtIndex:(1+x)]; //Start at the third Draw
        UILabel *currentDate = [dates objectAtIndex:(-1+x)]; //Start at the first label
        
        NSDate *givenDate = drawResult.drawingDate;
        NSString *newDateStr = [[dateFormatter stringFromDate:givenDate]stringByAppendingString:@":"];      
        
        currentDate.frame = CGRectMake(xLindent,yhistoryDateLabel+((x-1)*yLheight),dateLabelWidth,yLheight);
        currentDate.font = [UIFont boldSystemFontOfSize:16];
        currentDate.textColor = [UIColor whiteColor];
        currentDate.textAlignment = UITextAlignmentLeft;
        currentDate.backgroundColor = [UIColor clearColor];
        currentDate.text = newDateStr;
        [self.scrollView addSubview:currentDate];
        
        Selection *currentSelection = [self.allSelections objectAtIndex:x+1];
        int screenWidth = self.view.frame.size.width-40; 
        int xsize = MIN(25, (screenWidth - xLindent - dateLabelWidth - (numItems*xbuffer)) / numItems);
        [self animateResults:currentSelection xsize:xsize endX:(xLindent + dateLabelWidth) endY:yhistoryBallAdjust+yhistoryDateLabel+((x-1)*yLheight)  width:xsize height:xsize count:x+1];
    }
    [self addResults];
}

- (void)addResults //Adds the Big Balls - main results(last version)
{
    int screenWidth = self.view.frame.size.width; 
    int xsize = MIN(38, (screenWidth - (2*xindent) - (numItems*xbuffer)) / numItems);
    
    Selection *mainSelection = [self.allSelections objectAtIndex:1];
    [self animateResults:mainSelection xsize:xsize endX:xindent endY:ystart width:xsize height:xsize count:1];
    
    firstTime = NO; //AnimateResults loops through all balls

    [self.spinner removeFromSuperview];
    self.spinner = nil;
}

- (void)animateResults:(Selection *)selection xsize:(int)xsize endX:(int)endX endY:(int)endY width:(int)width height:(int)height count:(int)count //Animates the results onto the screen
{
    int screenWidth = self.view.frame.size.width; 
    NSLog(@"Width: %i", xsize);
    for (int x=1; x<=numItems; x++) { //Iterate through the balls
        CGRect frame = CGRectMake(endX+((x-1)*(xsize+xbuffer)), endY, width, height);
        UIImageView *endView = [[UIImageView alloc] initWithFrame:frame];
        
        NSString *currentBall = [matchingArray objectAtIndex:(x-1)];
        UILabel *label = [[UILabel alloc] initWithFrame:endView.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:xsize*.70];
        label.text = [[selection valueForKey:currentBall] stringValue];
        
        if (x!=numItems) {
            endView.image = [UIImage imageNamed:@"whiteball.png"]; 
            label.textColor = [UIColor blackColor];
        } else {
            endView.image = [UIImage imageNamed:@"redball.png"];
            label.textColor = [UIColor whiteColor];
        }
        
        [endView addSubview:label];
        [self.scrollView addSubview:endView];
        
        if (firstTime) {
            float animationDuration = ((0.1f)*sqrt(x) + (0.4f)*(count-1) + 0.8f); //X is ball number, Count is row number ...(x * (.1f) + 1.0f);
            
            CABasicAnimation *ballMover = [CABasicAnimation animationWithKeyPath:@"position"];
            ballMover.removedOnCompletion = NO;
            ballMover.fillMode = kCAFillModeForwards;
            ballMover.duration = animationDuration;
            ballMover.fromValue = [NSValue valueWithCGPoint:CGPointMake(endView.center.x + (x*screenWidth) + ((count-1)*numItems*screenWidth), endView.center.y)];
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
}

-(void)sendEmail 
{
    NSLog(@"SendEmail");
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    if(emailBody == nil) {
        emailBody = @"Hey, \n\n Let's create a group to buy tickets for Powerball.";
        
        Selection *nextDraw = [self.allSelections objectAtIndex:0];
        NSString *title = [@"Powerball jackpot: " stringByAppendingString:nextDraw.jackpot];
        title = [title stringByAppendingString:@" ... says the Powerball Plus app"];
        emailSubject = title;
    }
    if(emailBody != nil) {
        [picker setSubject:emailSubject];
        [picker setMessageBody:emailBody isHTML:NO];
        [self presentModalViewController:picker animated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
