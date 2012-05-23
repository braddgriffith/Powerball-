//
//  PayoutTableView.h
//  Powerball Results
//
//  Created by Brad Grifffith on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PayoutCell.h"

@interface PayoutTableView : NSObject <UITableViewDelegate, UITableViewDataSource, NSCoding>

@property (nonatomic, weak)  NSMutableArray *payouts;
@property (nonatomic, weak)  NSMutableArray *payout;
@property (nonatomic, weak)  IBOutlet UITableView *tableView;

@end
