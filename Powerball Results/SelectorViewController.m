//
//  SelectorViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectorViewController.h"
#import "HudView.h"
#import "Selection.h"
#import "AppDelegate.h"
#import "Time.h"
#import <Parse/Parse.h>

@implementation SelectorViewController

@synthesize numberOne;
@synthesize numberTwo;
@synthesize numberThree;
@synthesize numberFour;
@synthesize numberFive;
@synthesize powerball;
@synthesize currentDrawDate;
@synthesize nextDrawDateEST;

@synthesize selection;
@synthesize selections;
@synthesize upcomingDrawDate;
@synthesize pickButton;

@synthesize appDelegate;

@synthesize today;

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"Selector has %d selections", [self.selections count]);
    NSLog(@"viewWillAppear Email is %@", appDelegate.user.email);
    
    if ([appDelegate.user.email isEqualToString:@""]) {
        [pickButton.titleLabel setText:@"QuickPick"];
        [pickButton setTitle:@"QuickPick" forState:(UIControlStateNormal)];
        [pickButton setTitle:@"QuickPick" forState:(UIControlStateSelected)];
    } else {
        [pickButton.titleLabel setText:@"SmartPick"];
        [pickButton setTitle:@"SmartPick" forState:(UIControlStateNormal)];
        [pickButton setTitle:@"SmartPick" forState:(UIControlStateSelected)];
    }
    [pickButton.titleLabel setTextAlignment:UITextAlignmentCenter];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Stars02.png"]];
    
    appDelegate = [[UIApplication sharedApplication] delegate]; 
    
    //Calculate the next draw date in EST
    NSLog(@"Local Time Zone %@",[[NSTimeZone localTimeZone] name]);
    NSLog(@"System Time Zone %@",[[NSTimeZone systemTimeZone] name]);
    Time *theTime = [[Time alloc] init];
    nextDrawDateEST = [theTime getDrawDate:@"forward"]; 
    double interval = [theTime getTimeZoneOffset];
    upcomingDrawDate = [nextDrawDateEST dateByAddingTimeInterval:interval];
    
    //Put next draw date on screen
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //create a date formatter
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]]; //Current time of local timezone - drawings are 10:59PM EST
    [dateFormatter setDateFormat:@"EEEE - h:mm a"];//Was @"MM/dd h:mm a"];
    NSString *dateStr = [dateFormatter stringFromDate:upcomingDrawDate];
    
    NSString *dateIntro = @"Next: ";
    currentDrawDate.text = [dateIntro stringByAppendingString:dateStr];
    
    dateFormatter = nil;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)loadSelection
{
    self.numberOne.text = [selection.selectionOne stringValue];
    self.numberTwo.text = [selection.selectionTwo stringValue];
    self.numberThree.text = [selection.selectionThree stringValue];
    self.numberFour.text = [selection.selectionFour stringValue];
    self.numberFive.text = [selection.selectionFive stringValue];
    self.powerball.text = [selection.selectionPowerball stringValue];
}

- (IBAction)clear:(id)sender
{
    self.numberOne.text = @"";
    self.numberTwo.text = @"";
    self.numberThree.text = @"";
    self.numberFour.text = @"";
    self.numberFive.text = @"";
    self.powerball.text = @"";
}

- (void)presentWarning
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Needed!"
                                                    message:@"All entries need to be a number! Try QuickPick to select numbers fast."
                                                   delegate:NULL 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:NULL];
    [alert show];
}

- (IBAction)save:(id)sender
{
    [self resignAll];
    
    if (![[numberOne text] intValue]) {
        [self presentWarning];
        return;
    } else if (![[numberTwo text] intValue]) {
        [self presentWarning];
        return;
    } else if (![[numberThree text] intValue]) {
        [self presentWarning];
        return;
    } else if (![[numberFour text] intValue]) {
        [self presentWarning];
        return;
    } else if (![[numberFive text] intValue]) {
        [self presentWarning];
        return;
    } else if (![[powerball text] intValue]) {
        [self presentWarning];
        return;
    }
    
    NSString *entryOne = [numberOne text];
    NSString *entryTwo = [numberTwo text];
    NSString *entryThree = [numberThree text];
    NSString *entryFour = [numberFour text];
    NSString *entryFive = [numberFive text];
    NSString *entryPowerball = [powerball text];
    
    Selection *currentSelection = [[Selection alloc] init];
    
    NSNumberFormatter * numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    currentSelection.selectionOne = [numFormatter numberFromString:entryOne];
    currentSelection.selectionTwo = [numFormatter numberFromString:entryTwo];
    currentSelection.selectionThree = [numFormatter numberFromString:entryThree];
    currentSelection.selectionFour = [numFormatter numberFromString:entryFour];
    currentSelection.selectionFive = [numFormatter numberFromString:entryFive];
    currentSelection.selectionPowerball = [numFormatter numberFromString:entryPowerball];
    currentSelection.drawingDate = upcomingDrawDate;
    NSTimeInterval since70 = [nextDrawDateEST timeIntervalSince1970];
    currentSelection.since70 = [NSNumber numberWithFloat:since70];
    currentSelection.userChosenDate = [NSDate date];
    
    currentSelection.selectionArray = [NSMutableArray array];
    [currentSelection.selectionArray insertObject:currentSelection.selectionOne atIndex:0];
    [currentSelection.selectionArray insertObject:currentSelection.selectionTwo atIndex:0];
    [currentSelection.selectionArray insertObject:currentSelection.selectionThree atIndex:0];
    [currentSelection.selectionArray insertObject:currentSelection.selectionFour atIndex:0];
    [currentSelection.selectionArray insertObject:currentSelection.selectionFive atIndex:0];
    
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [currentSelection.selectionArray sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    NSLog(@"Array:%@", currentSelection.selectionArray);
    
    if (self.selections) {
        [self.selections insertObject:currentSelection atIndex:0];
    } 
    
    PFObject *newSelection = [PFObject objectWithClassName:@"Selections"];
    
    NSLog(@"Selector has %d selections", [self.selections count]);
    
    if(currentSelection.selectionOne){
        [newSelection setObject:currentSelection.selectionOne forKey:@"Ball1"];
    }
    if(currentSelection.selectionTwo){
        [newSelection setObject:currentSelection.selectionTwo forKey:@"Ball2"];
    }
    if(currentSelection.selectionThree){
        [newSelection setObject:currentSelection.selectionThree forKey:@"Ball3"];
    }
    if(currentSelection.selectionFour){
        [newSelection setObject:currentSelection.selectionFour forKey:@"Ball4"];
    }
    if(currentSelection.selectionFive){
        [newSelection setObject:currentSelection.selectionFive forKey:@"Ball5"];
    }
    if(currentSelection.selectionPowerball){
        [newSelection setObject:currentSelection.selectionPowerball forKey:@"BallPowerball"];
    }
    if(currentSelection.drawingDate){
        [newSelection setObject:currentSelection.drawingDate forKey:@"drawDate"];
    }
    if(currentSelection.since70){
        [newSelection setObject:currentSelection.since70 forKey:@"since70"];
    }
    if(currentSelection.selectionArray){
        NSArray *parseArray = [NSArray arrayWithArray:currentSelection.selectionArray];
        [newSelection setObject:parseArray forKey:@"selectionArray"];
    }
    
    if(appDelegate.user.username == @""){ 
        [newSelection setObject:@"Unknown User" forKey:@"userID"];
    } else {
        [newSelection setObject:appDelegate.user.username forKey:@"userID"];
    }
    
    currentSelection.type = @"Powerball";
    if(currentSelection.type){ // OVERWRITE WITH REAL type
        [newSelection setObject:currentSelection.type forKey:@"type"];
    }
    [newSelection setObject:currentSelection.userChosenDate forKey:@"addedDate"];
    [newSelection saveInBackground];

    [HudView hudInView:self.navigationController.view text:@"Saved!" lineTwo:@"Check MyPicks" animated:YES];

    NSLog(@"Data saved");
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    [self resignAll];
}

- (IBAction)viewTapped
{ 
    [self resignAll];
}

- (void)resignAll
{
    [numberOne resignFirstResponder];
    [numberTwo resignFirstResponder];
    [numberThree resignFirstResponder];
    [numberFour resignFirstResponder];
    [numberFive resignFirstResponder];
    [powerball resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;     // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];

    if (nextResponder) {
        [nextResponder becomeFirstResponder];         // Found next responder, so set it.
    } else {
        [self save:(selection)];         // Not found, so go to save.
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (NSInteger)generateRandom
{
    return arc4random()%59+1;
}

-(IBAction)quikPik:(id)sender
{
    NSMutableArray *currentNumbers = [[NSMutableArray alloc] init];
    
    NSInteger a = [self generateRandom];
    self.numberOne.text = [NSString stringWithFormat:@"%d", a];
    NSNumber *anumber = [NSNumber numberWithInteger:a];
    [currentNumbers addObject:anumber];
    
    NSInteger b = [self generateRandom];
    while ([currentNumbers containsObject:[NSNumber numberWithInt:b]]) {
        b = [self generateRandom];
    }
    self.numberTwo.text = [NSString stringWithFormat:@"%d", b];
    anumber = [NSNumber numberWithInteger:b];
    [currentNumbers addObject:anumber];
    
    NSInteger c = [self generateRandom];
    while ([currentNumbers containsObject:[NSNumber numberWithInt:c]]) {
        c = [self generateRandom];
    }
    self.numberThree.text = [NSString stringWithFormat:@"%d", c];
    anumber = [NSNumber numberWithInteger:c];
    [currentNumbers addObject:anumber];
    
    NSInteger d = [self generateRandom];
    while ([currentNumbers containsObject:[NSNumber numberWithInt:d]]) {
        d = [self generateRandom];
    }
    self.numberFour.text = [NSString stringWithFormat:@"%d", d];
    anumber = [NSNumber numberWithInteger:d];
    [currentNumbers addObject:anumber];
    
    NSInteger e = [self generateRandom];
    while ([currentNumbers containsObject:[NSNumber numberWithInt:e]]) {
        e =[self generateRandom];
    }
    self.numberFive.text = [NSString stringWithFormat:@"%d", e];
    anumber = [NSNumber numberWithInteger:e];
    [currentNumbers addObject:anumber];
    
    NSInteger f = arc4random()%35 +1;
    self.powerball.text = [NSString stringWithFormat:@"%d", f];
    
    currentNumbers = nil;
}

- (void)viewDidUnload {
    [self setCurrentDrawDate:nil];
    [super viewDidUnload];
}
@end
