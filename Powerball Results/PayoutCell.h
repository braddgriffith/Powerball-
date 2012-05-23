//
//  PayoutCell.h
//  Powerball Results
//
//  Created by Brad Grifffith on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayoutCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *prize;
@property (nonatomic, weak) IBOutlet UILabel *odds;
@property (nonatomic, weak) IBOutlet UIView *backgroundViewForColor;
@property (nonatomic, weak) IBOutlet UIView *matchedBallsView;

@end
