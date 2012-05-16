//
//  Time.h
//  Powerball Results
//
//  Created by Brad Grifffith on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Time : NSObject

- (double)getTimeZoneOffset;
- (NSDate *)getDrawDate:(NSString *)direction;
- (void)scheduleNotification:(NSDate *)nextDate;

@end
