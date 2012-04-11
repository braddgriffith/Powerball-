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
@synthesize upcomingDrawDate;

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
    
    NSTimeZone *localTimeZone = [NSTimeZone systemTimeZone];
    NSTimeZone *estTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    
    NSInteger localOffset = [localTimeZone secondsFromGMTForDate:today];
    NSInteger estOffset = [estTimeZone secondsFromGMTForDate:today];
    NSTimeInterval interval = localOffset - estOffset;
    
    NSDate* todayEST = [[NSDate alloc] initWithTimeInterval:interval sinceDate:today];
    NSTimeInterval diff = [todayEST timeIntervalSinceDate:today];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //create a date formatter
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]]; //Current time of local timezone - drawings are at 10:59PM EST
    [dateFormatter setDateFormat:@"MM/dd"];
    
    todaysDate.text = [dateFormatter stringFromDate:today]; 
    
    NSDate *nextDrawDateEST = [self getNextDrawDate]; //Returns the next draw date in EST
    upcomingDrawDate = [nextDrawDateEST dateByAddingTimeInterval:diff];
    [dateFormatter setDateFormat:@"MM/dd h:mm a"];
    currentDrawDate.text = [dateFormatter stringFromDate:upcomingDrawDate]; 
    
    dateFormatter = nil;
}

- (NSDate *)getNextDrawDate
{
    NSDate *today = [NSDate date]; //get time/date right now
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
    NSCalendar *gregorian = [[NSCalendar alloc] 
                             initWithCalendarIdentifier:NSGregorianCalendar];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]]; //Eastern Time of USA - drawings are at 10:59PM EST

    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:today];
    NSInteger weekday = [weekdayComponents weekday];
    NSString *weekdayStr = [NSString stringWithFormat:@"%d", weekday];
    NSLog(@"Weekday: %@", weekdayStr);
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSTimeInterval interval = 0;
    
    if (weekday == 1) { //This is Sunday
        interval = (3 * secondsPerDay);
    } else if (weekday == 2) {
       interval = (2 * secondsPerDay);
    } else if (weekday == 3) {
        interval = (1 * secondsPerDay);
    } else if (weekday == 4) {
        interval = (0 * secondsPerDay);    
    } else if (weekday == 5) {
        interval = (2 * secondsPerDay);
    } else if (weekday == 6) {
        interval = (1 * secondsPerDay);
    } else if (weekday == 7) {
        interval = (0 * secondsPerDay);
    }
    
    NSDate *drawFollowingDay = [[NSDate alloc] initWithTimeIntervalSinceNow:(interval)];
    drawFollowingDay = [self roundDateForwardTo11PM:drawFollowingDay];
    return drawFollowingDay;
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
    [components setHour:22]; // If EST
    [components setMinute:59]; 
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
    currentSelection.drawingDate = upcomingDrawDate;
    
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
