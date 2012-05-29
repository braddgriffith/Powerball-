//
//  PayoutTableView.h
//  Powerball Results
//
//  Created by Brad Grifffith on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PayoutCell.h"

@interface PayoutTableView : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)  NSMutableArray *payouts;
@property (nonatomic, strong)  NSMutableArray *payout;
@property (nonatomic, weak)  IBOutlet UITableView *tableView;

- (void)getPayoutData;

@end
