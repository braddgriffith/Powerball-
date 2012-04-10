//
//  NumberGeneratorViewController.h
//  Powerball Results
//
//  Created by Brad Grifffith on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneratorViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UILabel *numberOne;
@property (nonatomic, strong) IBOutlet UILabel *numberTwo;
@property (nonatomic, strong) IBOutlet UILabel *numberThree;
@property (nonatomic, strong) IBOutlet UILabel *numberFour;
@property (nonatomic, strong) IBOutlet UILabel *numberFive;
@property (nonatomic, strong) IBOutlet UILabel *powerball;

-(IBAction)refresh:(id)sender;
-(IBAction)save:(id)sender;

@end
