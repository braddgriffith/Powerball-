//
//  HistoryCell.h
//  Powerball Results
//
//  Created by Brad Grifffith on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *numbersLabel;
@property (nonatomic, strong) IBOutlet UILabel *powerballLabel;

@end
