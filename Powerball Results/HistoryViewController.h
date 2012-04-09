//
//  HistoryViewController.h
//  Powerball Results
//
//  Created by Brad Grifffith on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Selection.h"

@interface HistoryViewController : UITableViewController

@property (nonatomic,strong)  NSArray *selections;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) Selection *addSelection;

@end
