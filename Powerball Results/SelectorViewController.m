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

@implementation SelectorViewController

@synthesize numberOne;
@synthesize numberTwo;
@synthesize numberThree;
@synthesize numberFour;
@synthesize numberFive;
@synthesize powerball;
@synthesize todaysDate;
@synthesize currentDrawDate;

@synthesize selection;
@synthesize selections;

-(void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    selection = appDelegate.selection;
    
    if (selection) {
        [self loadSelection];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    
    NSDate *today = [NSDate date]; //get RIGHT NOW
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //create a date formatter
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]]; //Current time of local timezone - drawings are at 10:59PM EST
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    todaysDate.text = [dateFormatter stringFromDate:today]; 
    
    [self getNextDrawDate];
}

- (void)getNextDrawDate
{
    NSDate *today = [NSDate date]; //get RIGHT NOW
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //create a date formatter
    NSCalendar *gregorian = [[NSCalendar alloc]  //create a Gregorian calendar
                             initWithCalendarIdentifier:NSGregorianCalendar];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:(-4*60*60)]]; //Eastern Time of USA - drawings are at 10:59PM EST

    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:today];
    NSInteger weekday = [weekdayComponents weekday];
    NSString *weekdayStr = [NSString stringWithFormat:@"%d", weekday];
    NSLog(@"Weekday: %@", weekdayStr);
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    if (weekday == 0) {
        NSDate *drawFollowingSunday = [[NSDate alloc] initWithTimeIntervalSinceNow:(0 * secondsPerDay)];
        drawFollowingSunday = [self roundDateForwardTo11PM:drawFollowingSunday];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingSunday];
    } else if (weekday == 1) {
        NSDate *drawFollowingMonday = [[NSDate alloc] initWithTimeIntervalSinceNow:(3 * secondsPerDay)];
        drawFollowingMonday = [self roundDateForwardTo11PM:drawFollowingMonday];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingMonday];
    } else if (weekday == 2) {
        NSDate *drawFollowingTuesday = [[NSDate alloc] initWithTimeIntervalSinceNow:(2 * secondsPerDay)];
        drawFollowingTuesday = [self roundDateForwardTo11PM:drawFollowingTuesday];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingTuesday];
    } else if (weekday == 3) {
        NSDate *drawFollowingWednesday = [[NSDate alloc] initWithTimeIntervalSinceNow:(1 * secondsPerDay)];
        drawFollowingWednesday = [self roundDateForwardTo11PM:drawFollowingWednesday];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingWednesday];
    } else if (weekday == 4) {
        NSDate *drawFollowingThursday = [[NSDate alloc] initWithTimeIntervalSinceNow:(0 * secondsPerDay)];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingThursday];
    } else if (weekday == 5) {
        NSDate *drawFollowingFriday = [[NSDate alloc] initWithTimeIntervalSinceNow:(2 * secondsPerDay)];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingFriday];
    } else if (weekday == 6) {
        NSDate *drawFollowingSaturday = [[NSDate alloc] initWithTimeIntervalSinceNow:(1 * secondsPerDay)];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingSaturday];
    }
}

- (NSDate *)roundDateForwardTo11PM:(NSDate *)startDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]; //WHERE DO I PUT THE TIMEZONE?
    NSDateComponents *todayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:startDate];
    NSInteger theDay = [todayComponents day];
    NSInteger theMonth = [todayComponents month];
    NSInteger theYear = [todayComponents year];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay]; 
    [components setMonth:theMonth]; 
    [components setYear:theYear];
    [components setHour:23]; // If EST
    NSDate *roundedDate = [gregorian dateFromComponents:components];

    return roundedDate;
}    

- (void)loadSelection
{
    self.numberOne.text = selection.selectionOne;
    self.numberTwo.text = selection.selectionTwo;
    self.numberThree.text = selection.selectionThree;
    self.numberFour.text = selection.selectionFour;
    self.numberFive.text = selection.selectionFive;
    self.powerball.text = selection.selectionPowerball;
}

- (IBAction)clear:(id)sender
{
    self.numberOne.text = @"";
    self.numberTwo.text = @"";
    self.numberThree.text = @"";
    self.numberFour.text = @"";
    self.numberFive.text = @"";
    self.powerball.text = @"";
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.selection = nil;
}

- (IBAction)save:(id)sender
{
    [numberOne resignFirstResponder];
    [numberTwo resignFirstResponder];
    [numberThree resignFirstResponder];
    [numberFour resignFirstResponder];
    [numberFive resignFirstResponder];
    [powerball resignFirstResponder];
    
    NSString *entryOne = [numberOne text];
    NSString *entryTwo = [numberTwo text];
    NSString *entryThree = [numberThree text];
    NSString *entryFour = [numberFour text];
    NSString *entryFive = [numberFive text];
    NSString *entryPowerball = [powerball text];
    
    Selection *currentSelection = [[Selection alloc] init];
    
    currentSelection.selectionOne = entryOne;
    currentSelection.selectionTwo = entryTwo;
    currentSelection.selectionThree = entryThree;
    currentSelection.selectionFour = entryFour;
    currentSelection.selectionFive = entryFive;
    currentSelection.selectionPowerball = entryPowerball;
    currentSelection.drawingDate = currentDrawDate.text;
    
    [self.selections insertObject:currentSelection atIndex:0];
    
    [HudView hudInView:self.navigationController.view text:@"Saved!" lineTwo:@"Check History" animated:YES];

    NSLog(@"Data saved");
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    [numberOne resignFirstResponder];
    [numberTwo resignFirstResponder];
    [numberThree resignFirstResponder];
    [numberFour resignFirstResponder];
    [numberFive resignFirstResponder];
    [powerball resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}


- (void)viewDidUnload {
    [self setCurrentDrawDate:nil];
    [super viewDidUnload];
}
@end
