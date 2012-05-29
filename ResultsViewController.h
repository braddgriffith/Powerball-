//
//  ResultsViewController.h
//  Powerball Results
//
//  Created by Brad Grifffith on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayoutTableView.h"

@interface ResultsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *nextDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextJackpotLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastJackpotLabel;
@property (weak, nonatomic) IBOutlet UILabel *date1;
@property (weak, nonatomic) IBOutlet UILabel *date2;
@property (weak, nonatomic) IBOutlet UILabel *date3;
@property (weak, nonatomic) IBOutlet UILabel *date4;
@property (weak, nonatomic) IBOutlet UILabel *date5;
@property (strong, nonatomic) NSMutableArray *allSelections;
@property (strong, nonatomic) NSMutableArray *allPayouts;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet PayoutTableView *payoutsTableView;

@property (nonatomic, strong) NSDate *upcomingDrawDate;

@end
