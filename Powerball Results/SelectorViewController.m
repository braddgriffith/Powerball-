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

@implementation SelectorViewController

@synthesize numberOne;
@synthesize numberTwo;
@synthesize numberThree;
@synthesize numberFour;
@synthesize numberFive;
@synthesize powerball;
@synthesize todaysDate;
@synthesize currentDrawDate;

@synthesize selections;

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];

    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:today];
    currentDrawDate.text = timeString;
  
    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:today];
    NSInteger weekday = [weekdayComponents weekday];
    NSString *weekdayStr = [NSString stringWithFormat:@"%d", weekday];
    NSLog(@"Weekday: %@", weekdayStr);
    
    self.todaysDate.text = [dateFormatter stringFromDate:today]; 
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    if (weekday == 0) {
        NSDate *drawFollowingSunday = [[NSDate alloc] initWithTimeIntervalSinceNow:(3 * secondsPerDay)];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingSunday];
    } else if (weekday == 1) {
        NSDate *drawFollowingMonday = [[NSDate alloc] initWithTimeIntervalSinceNow:(2 * secondsPerDay)];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingMonday];
    } else if (weekday == 2) {
        NSDate *drawFollowingTuesday = [[NSDate alloc] initWithTimeIntervalSinceNow:(1 * secondsPerDay)];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingTuesday];
    } else if (weekday == 3) {
        NSDate *drawFollowingWednesday = [[NSDate alloc] initWithTimeIntervalSinceNow:(0 * secondsPerDay)];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingWednesday];
    } else if (weekday == 4) {
        NSDate *drawFollowingThursday = [[NSDate alloc] initWithTimeIntervalSinceNow:(2 * secondsPerDay)];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingThursday];
    } else if (weekday == 5) {
        NSDate *drawFollowingFriday = [[NSDate alloc] initWithTimeIntervalSinceNow:(1 * secondsPerDay)];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingFriday];
    } else if (weekday == 6) {
        NSDate *drawFollowingSaturday = [[NSDate alloc] initWithTimeIntervalSinceNow:(0 * secondsPerDay)];
        self.currentDrawDate.text = [dateFormatter stringFromDate:drawFollowingSaturday];
    }
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
