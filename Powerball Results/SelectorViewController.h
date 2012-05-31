//
//  SelectorViewController.h
//  Powerball Results
//
//  Created by Brad Grifffith on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Selection.h"
#import "AppDelegate.h"

@interface SelectorViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *numberOne;
@property (nonatomic, strong) IBOutlet UITextField *numberTwo;
@property (nonatomic, strong) IBOutlet UITextField *numberThree;
@property (nonatomic, strong) IBOutlet UITextField *numberFour;
@property (nonatomic, strong) IBOutlet UITextField *numberFive;
@property (nonatomic, strong) IBOutlet UITextField *powerball;
@property (nonatomic, strong) IBOutlet UIButton *pickButton;
@property (strong, nonatomic) IBOutlet UIImageView *theArrowView;
@property (strong, nonatomic) IBOutlet UILabel *encourageLabel;

@property (strong, nonatomic) Selection *selection;
@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) NSDate *upcomingDrawDate;
@property (nonatomic, strong) NSDate *nextDrawDateEST;
@property (nonatomic, assign) BOOL firstTime;

@property (nonatomic, weak) AppDelegate *appDelegate;

@property (nonatomic, strong) NSDate *today;

- (IBAction)clear:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)viewTapped;
- (IBAction)quikPik:(id)sender;

@end
