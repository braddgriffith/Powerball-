//
//  Payout.h
//  Powerball Results
//
//  Created by Brad Grifffith on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Payout : NSObject

@property (nonatomic, strong) NSNumber * matches;
@property (nonatomic, strong) NSNumber * specialMatches;
@property (nonatomic, strong) NSString * payout;
@property (nonatomic, strong) NSString * odds;

@end
