//
//  SelectorViewController.h
//  Powerball Results
//
//  Created by Brad Grifffith on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Selection.h"

@interface SelectorViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *numberOne;
@property (nonatomic, strong) IBOutlet UITextField *numberTwo;
@property (nonatomic, strong) IBOutlet UITextField *numberThree;
@property (nonatomic, strong) IBOutlet UITextField *numberFour;
@property (nonatomic, strong) IBOutlet UITextField *numberFive;
@property (nonatomic, strong) IBOutlet UITextField *powerball;

- (IBAction)clear:(id)sender;
- (IBAction)save:(id)sender;

@end
