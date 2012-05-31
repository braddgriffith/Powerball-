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
#import "IntroAnimation.h"

@implementation SelectorViewController

@synthesize numberOne;
@synthesize numberTwo;
@synthesize numberThree;
@synthesize numberFour;
@synthesize numberFive;
@synthesize powerball;
@synthesize nextDrawDateEST;

@synthesize selection;
@synthesize selections;
@synthesize upcomingDrawDate;
@synthesize pickButton;

@synthesize theArrowView;
@synthesize encourageLabel;
@synthesize firstTime; 

@synthesize appDelegate;

@synthesize today;

bool playAnimationForImage = YES;
bool triedPick = NO;
bool triedClear = NO;
bool triedEdit = NO;
bool triedSave = NO;


//Encouragement Arrow
int arrowWidth = 32;
int arrowStartXoffset = 24;
int arrowStartY = 324;
int arrowHeight = 38;
int arrowBounce = 5;
int horizArrowHeight = 32;
int horizArrowWidth = 38;

int encourageLabelWidth = 200;
int encourageLabelHeight = 22;
float encourageAlpha = 0.8;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    firstTime = YES; //NEED TO STORE IN NSUSERDEFAULTS
    
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
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //create a date formatter
    //[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]]; //Current time of local timezone - drawings are 10:59PM EST
    //[dateFormatter setDateFormat:@"EEEE - h:mm a"];//Was @"MM/dd h:mm a"];
    //NSString *dateStr = [dateFormatter stringFromDate:upcomingDrawDate];
    
    //NSString *dateIntro = @"Next: ";
    //currentDrawDate.text = [dateIntro stringByAppendingString:dateStr];
    
    //dateFormatter = nil;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    NSLog(@"Selector has %d selections", [self.selections count]);
    NSLog(@"viewWillAppear Email is %@", appDelegate.user.email);
    if (firstTime) {
        [self encourageEditing];
        //[self encourageSave];
        //[self encourageClear];
        //[self encourageQuickPick];
        if (triedPick) {
            [self encourageClear];
        }
    } else if ([appDelegate.user.email isEqualToString:@""]) {
        [pickButton.titleLabel setText:@"QuickPick"];
        [pickButton setTitle:@"QuickPick" forState:(UIControlStateNormal)];
        [pickButton setTitle:@"QuickPick" forState:(UIControlStateSelected)];
        int arrowStartX = self.view.frame.size.width-arrowWidth-arrowStartXoffset;
        int labelStartX = self.view.frame.size.width-(1.8*arrowWidth)-encourageLabelWidth;
        [IntroAnimation encourageSomething:self.view withImage:@"06-arrow-south@2x.png" atStartY:arrowStartY withText:@"Sign In to enable SmartPick" withYOffset:8 atStartX:arrowStartX atLabelStartX:labelStartX withDirection:@"vertical"];
    } else {
        [pickButton.titleLabel setText:@"SmartPick"];
        [pickButton setTitle:@"SmartPick" forState:(UIControlStateNormal)];
        [pickButton setTitle:@"SmartPick" forState:(UIControlStateSelected)];
        if (theArrowView) {
            [self removeEncouragement];
        }
    }
    [pickButton.titleLabel setTextAlignment:UITextAlignmentCenter];
}

-(void)encourageQuickPick
{
    int arrowPickStartY = pickButton.frame.origin.y-pickButton.frame.size.height-arrowBounce;
    int arrowPickStartX = pickButton.frame.origin.x + (pickButton.frame.size.width/4);
    int labelStartX = arrowPickStartX;
    [IntroAnimation encourageSomething:self.view withImage:@"06-arrow-south@2x.png" atStartY:arrowPickStartY withText:@"Click to QuickPick numbers..." withYOffset:18 atStartX:arrowPickStartX atLabelStartX:labelStartX withDirection:@"vertical"];
}

-(void)encourageClear
{
    int arrowPickStartY = self.view.frame.origin.y;
    int arrowPickStartX = self.view.frame.origin.x+1.5*arrowWidth;
    int labelStartX = arrowPickStartX-arrowWidth;
    [IntroAnimation encourageSomething:self.view withImage:@"03-arrow-north@2x.png" atStartY:arrowPickStartY withText:@"Now, click to clear..." withYOffset:-6 atStartX:arrowPickStartX atLabelStartX:labelStartX withDirection:@"vertical"];
}

-(void)encourageSave
{
    int arrowPickStartY = self.view.frame.origin.y;
    int arrowPickStartX = self.view.frame.size.width-1.35*arrowWidth;
    int labelStartX = arrowPickStartX-4.8*arrowWidth;
    [IntroAnimation encourageSomething:self.view withImage:@"03-arrow-north@2x.png" atStartY:arrowPickStartY withText:@"Now, click to save..." withYOffset:-6 atStartX:arrowPickStartX atLabelStartX:labelStartX withDirection:@"vertical"];
}

-(void)encourageEditing
{
    int arrowPickStartY = self.powerball.frame.origin.y + .5*self.powerball.frame.size.height -.5*horizArrowHeight;
    int arrowPickStartX = self.powerball.frame.origin.x + self.powerball.frame.size.width + .8*arrowBounce;
    int labelStartX = arrowPickStartX + horizArrowWidth +1*arrowBounce;
    [IntroAnimation encourageSomething:self.view withImage:@"09-arrow-west@2x.png" atStartY:arrowPickStartY withText:@"Edit the Powerball..." withYOffset:-4 atStartX:arrowPickStartX atLabelStartX:labelStartX withDirection:@"horizontal"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
    [IntroAnimation removeEncouragement:encourageLabel withImageView:theArrowView];
}

-(void)removeEncouragement
{
    [encourageLabel removeFromSuperview];
    [theArrowView removeFromSuperview];
    playAnimationForImage = NO;
    encourageLabel = nil;
    theArrowView = nil;
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

- (NSInteger)generateSmart
{
    return arc4random()%28+32;
}

-(IBAction)quikPik:(id)sender
{
    triedPick = YES;
    if ([pickButton.titleLabel.text isEqualToString:@"SmartPick"]) {
        [self smartPick];
    } else {
        [self regularPick];
    }
}

-(IBAction)regularPick
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

-(IBAction)smartPick
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
    
    NSInteger d = [self generateSmart];
    while ([currentNumbers containsObject:[NSNumber numberWithInt:d]]) {
        d =[self generateSmart];
    }
    self.numberFour.text = [NSString stringWithFormat:@"%d", d];
    anumber = [NSNumber numberWithInteger:d];
    [currentNumbers addObject:anumber];
    
    NSInteger e = [self generateSmart];
    while ([currentNumbers containsObject:[NSNumber numberWithInt:e]]) {
        e =[self generateSmart];
    }
    self.numberFive.text = [NSString stringWithFormat:@"%d", e];
    anumber = [NSNumber numberWithInteger:e];
    [currentNumbers addObject:anumber];
    
    NSInteger f = arc4random()%35 +1;
    self.powerball.text = [NSString stringWithFormat:@"%d", f];
    
    currentNumbers = nil;
}

- (void)viewDidUnload 
{
    //[self setCurrentDrawDate:nil];
    [super viewDidUnload];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{   
    [self removeEncouragement];
}

@end
