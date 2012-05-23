//
//  PayoutCell.m
//  Powerball Results
//
//  Created by Brad Grifffith on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PayoutCell.h"

@implementation PayoutCell

@synthesize prize;
@synthesize odds;
@synthesize backgroundViewForColor;
@synthesize matchedBallsView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        prize.textAlignment = UITextAlignmentLeft;
        prize.font = [UIFont systemFontOfSize:14];
        prize.textColor = [UIColor whiteColor];
        odds.textAlignment = UITextAlignmentLeft;
        odds.font = [UIFont systemFontOfSize:14];
        odds.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    
    CGRect frame = CGRectMake(boundsX+10 ,5, 200, 22);
    matchedBallsView.frame = frame;
    
    frame= CGRectMake(boundsX+70 ,5, 200, 22);
    prize.frame = frame;
    
    frame= CGRectMake(boundsX+170 ,5, 200, 22);
    odds.frame = frame;
    
    [self.contentView addSubview:prize];
    [self.contentView addSubview:odds];
    [self.contentView addSubview:matchedBallsView];
}


@end
