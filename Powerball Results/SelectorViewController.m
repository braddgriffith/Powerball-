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
//@synthesize firstTime; 

@synthesize appDelegate;

@synthesize today;

bool playAnimationForImage = YES;
bool triedPickOne = NO;
bool triedPickTwo = NO;
bool triedClear = NO;
bool triedEdit = NO;
bool triedSaveOne = NO;
bool triedSaveTwo = NO;
bool smartPickActivatedYet = NO;

//Encouragement Arrow
int arrowWidth = 32;
int arrowHeight = 38;
int arrowBounce = 5;
int arrowStartXoffset = 24;
int arrowStartY = 324;
int horizArrowHeight = 32;
int horizArrowWidth = 38;

int encourageLabelWidth = 200;
int encourageLabelHeight = 22;
float encourageAlpha = 0.8;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    triedClear = [[currentDefaults objectForKey:@"triedClear"] boolValue];
    triedPickOne = [[currentDefaults objectForKey:@"triedPickOne"] boolValue];
    triedPickTwo = [[currentDefaults objectForKey:@"triedPickTwo"] boolValue];
    triedEdit = [[currentDefaults objectForKey:@"triedEdit"] boolValue];
    triedSaveOne = [[currentDefaults objectForKey:@"triedSaveOne"] boolValue];
    triedSaveTwo = [[currentDefaults objectForKey:@"triedSaveTwo"] boolValue];
    smartPickActivatedYet = [[currentDefaults objectForKey:@"smartPickActivatedYet"] boolValue];
    NSLog(@"triedClear: %s", triedClear ? "YES" : "NO");
    NSLog(@"triedPickOne: %s", triedPickOne ? "YES" : "NO");
    NSLog(@"triedPickTwo: %s", triedPickTwo ? "YES" : "NO");
    NSLog(@"triedEdit: %s", triedEdit ? "YES" : "NO");
    NSLog(@"triedSaveOne: %s", triedSaveOne ? "YES" : "NO");
    NSLog(@"triedSaveTwo: %s", triedSaveTwo ? "YES" : "NO");
     NSLog(@"smartPickActivatedYet: %s", smartPickActivatedYet ? "YES" : "NO");
    
    //****ERASE THIS AFTER TESTING
    triedClear = NO;
    triedPickOne = NO;
    triedPickTwo = NO;
    triedEdit = NO;
    triedSaveOne = NO;
    triedSaveTwo = NO;
    smartPickActivatedYet = NO;
    //*****ERASE THIS AFTER TESTING
    
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
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [IntroAnimation removeEncouragement];
    NSLog(@"Selector has %d selections", [self.selections count]);
    NSLog(@"viewWillAppear Email is %@", appDelegate.user.email);
    
    [pickButton.titleLabel setText:@"QuickPick"];
    [pickButton setTitle:@"QuickPick" forState:(UIControlStateNormal)];
    [pickButton setTitle:@"QuickPick" forState:(UIControlStateSelected)];
    
    if (triedPickTwo && [appDelegate.user.email isEqualToString:@""]) {
        [self encourageAccount];
    } else if (![appDelegate.user.email isEqualToString:@""]) {
        if (!smartPickActivatedYet) {
            smartPickActivatedYet = YES;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:smartPickActivatedYet] forKey:@"smartPickActivatedYet"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [HudView hudInView:self.navigationController.view text:@"SmartPick!" lineTwo:@"Activated" animated:YES];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Do you love Powerball+?"
                                  message: @"Please help us keep the app free by rating it in the App Store!"
                                  delegate: self
                                  cancelButtonTitle:@"No thanks"
                                  otherButtonTitles:@"Rate it!",nil];
            [alert show];
        }
        [pickButton.titleLabel setText:@"SmartPick"];
        [pickButton setTitle:@"SmartPick" forState:(UIControlStateNormal)];
        [pickButton setTitle:@"SmartPick" forState:(UIControlStateSelected)];
    }
    [pickButton.titleLabel setTextAlignment:UITextAlignmentCenter];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!triedPickOne) {
        //[self encourageClear];
        [self encourageQuickPick];
    } else if(!triedClear) {
        [self encourageClear];
    }
}

-(void)encourageAccount
{
    int arrowPickStartY = self.view.frame.origin.y+self.view.frame.size.height-arrowBounce-arrowHeight;
    int arrowPickStartX = self.view.frame.size.width-arrowWidth-arrowStartXoffset;
    int labelStartX = self.view.frame.size.width-(1.8*arrowWidth)-encourageLabelWidth;
    [IntroAnimation encourageSomething:self.view withImage:@"06-arrow-south@2x.png" atStartY:arrowPickStartY withText:@"Sign In to enable SmartPick" withYOffset:8 atStartX:arrowPickStartX atLabelStartX:labelStartX withDirection:@"vertical"];
}

-(void)encourageMyPicks
{
    int arrowPickStartY = self.view.frame.origin.y+self.view.frame.size.height-arrowBounce-arrowHeight;
    int arrowPickStartX = self.view.frame.size.width-arrowWidth-arrowStartXoffset-(self.view.frame.size.width/4);
    int labelStartX = self.view.frame.size.width-(1.3*arrowWidth)-encourageLabelWidth;
    [IntroAnimation encourageSomething:self.view withImage:@"06-arrow-south@2x.png" atStartY:arrowPickStartY withText:@"Check MyPicks" withYOffset:8 atStartX:arrowPickStartX atLabelStartX:labelStartX withDirection:@"vertical"];
}

-(void)encourageQuickPick
{
    int arrowPickStartY = pickButton.frame.origin.y-pickButton.frame.size.height-arrowBounce;
    int arrowPickStartX = self.view.frame.size.width/2 - arrowWidth/2;
    int labelStartX = arrowPickStartX - (pickButton.frame.size.width/4.5);
    [IntroAnimation encourageSomething:self.view withImage:@"06-arrow-south@2x.png" atStartY:arrowPickStartY withText:@"Click to QuickPick numbers..." withYOffset:18 atStartX:arrowPickStartX atLabelStartX:labelStartX withDirection:@"vertical"];
}

-(void)encourageClear
{
    int arrowPickStartY = self.view.frame.origin.y;
    int arrowPickStartX = self.view.frame.origin.x+.5*arrowWidth;
    int labelStartX = arrowPickStartX+arrowWidth+2;
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
    if (!triedClear) {
        triedClear = YES;
        [IntroAnimation removeEncouragement];
        [self encourageQuickPick];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:triedClear] forKey:@"triedClear"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
    if (!triedSaveOne) {
        triedSaveOne = YES;
        [IntroAnimation removeEncouragement];
        [self encourageMyPicks];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:triedSaveOne] forKey:@"triedSaveOne"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (!triedSaveTwo) {
        triedSaveTwo = YES;
        [IntroAnimation removeEncouragement];
        [self encourageAccount];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:triedSaveTwo] forKey:@"triedSaveTwo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
    if (!triedPickOne) {
        triedPickOne = YES;
        [IntroAnimation removeEncouragement];
        [self encourageSave];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:triedPickOne] forKey:@"triedPickOne"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (!triedPickTwo) {
        triedPickTwo = YES;
        [IntroAnimation removeEncouragement];
        [self encourageEditing];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:triedPickTwo] forKey:@"triedPickTwo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
    if (!triedEdit) {
        triedEdit = YES;
        [IntroAnimation removeEncouragement];
        [self encourageSave];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:triedEdit] forKey:@"triedEdit"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		NSLog(@"user pressed Rate It");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://userpub.itunes.apple.com/WebObjects/MZUserPublishing.woa/wa/addUserReview?id=517545261&type=Purple+Software"]];
	}
	else {
		NSLog(@"user pressed Cancel");
	}
}

@end
