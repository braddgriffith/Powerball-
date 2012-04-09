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

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
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
    
    /*  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* selectedAlready = [[NSUserDefaults standardUserDefaults] objectForKey:@"selections"];
    NSMutableArray* selections = [[NSMutableArray alloc] init];
    
    if(selectedAlready) {
        selections = [(NSArray*)selectedAlready mutableCopy];
    }
    
    [selections insertObject:currentSelection atIndex:0];
    
    [defaults setObject:selections forKey:@"selections"];
    [defaults synchronize];*/
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *selectionsData = [currentDefaults objectForKey:@"selections"];
    
    NSLog(@"Selections Data = %@", selectionsData);
    
    NSMutableArray *selections = [[NSMutableArray alloc] init];
    
    if (selectionsData) 
    {
        selections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:selectionsData]];
    }
    
    [selections insertObject:currentSelection atIndex:0];
    
    NSLog(@"%@",selections);
    
    //NSMutableArray *selections = [currentDefaults objectForKey:@"selections"];
    //[NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:selectedAlready]];
    //NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:selectedAlready];


    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:selections] forKey:@"selections"];
    
    [HudView hudInView:self.navigationController.view text:@"Saved!" lineTwo:@"Check History" animated:YES];

    NSLog(@"Data saved");
//    selectedAlready = nil;
//    selections = nil;
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


@end
