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

@property (strong, nonatomic) IBOutlet UILabel *nextDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *nextJackpotLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastJackpotLabel;
@property (strong, nonatomic) IBOutlet UILabel *date1;
@property (strong, nonatomic) IBOutlet UILabel *date2;
@property (strong, nonatomic) IBOutlet UILabel *date3;
@property (strong, nonatomic) IBOutlet UILabel *date4;
@property (strong, nonatomic) IBOutlet UILabel *date5;
@property (strong, nonatomic) NSMutableArray *allSelections;
@property (strong, nonatomic) NSMutableArray *allPayouts;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet PayoutTableView *payoutsTableView;

@property (nonatomic, strong) NSDate *upcomingDrawDate;

@end
