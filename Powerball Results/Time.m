//
//  Time.m
//  Powerball Results
//
//  Created by Brad Grifffith on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Time.h"

@implementation Time

NSDate *today;

- (double)getTimeZoneOffset
{
    today = [NSDate date]; //get RIGHT NOW
    
    NSTimeZone *localTimeZone = [NSTimeZone systemTimeZone];
    NSTimeZone *easternTimeZone = [NSTimeZone timeZoneWithName:@"US/Eastern"]; 
    
    NSInteger localOffset = [localTimeZone secondsFromGMTForDate:today];
    NSInteger easternOffset = [easternTimeZone secondsFromGMTForDate:today];
    NSTimeInterval interval = localOffset - easternOffset;
    
    NSLog(@"Current timezone offset from easternTime: %.0f", interval);
    
    return interval;
}

- (NSDate *)getDrawDate:(NSString *)direction//gets today's weekday, calls roundForwardToDayNumber, then calls roundForwardToTime
{
    today = [NSDate date]; //get right now
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
    NSCalendar *gregorian = [[NSCalendar alloc] 
                             initWithCalendarIdentifier:NSGregorianCalendar];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Eastern"]]; //Eastern Time of USA - drawings are at 10:59PM EST
    
    NSDate *todayRounded = [self roundDateToTime:today usingHour:22 usingMinute:59 usingDirection:direction];
    
    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:todayRounded];
    NSInteger weekday = [weekdayComponents weekday];
    NSNumber *weekdayNumber = [NSNumber numberWithInt:weekday];
    NSString *weekdayStr = [NSString stringWithFormat:@"%d", weekdayNumber];
    NSLog(@"Weekday: %@", weekdayStr);
    
    NSNumber *dayOne = [NSNumber numberWithInt:(4)]; //Weds
    NSNumber *dayTwo = [NSNumber numberWithInt:(7)]; //Sunday
    NSArray *dayNumbers = [[NSArray alloc] initWithObjects:dayOne, dayTwo, nil];
    
    NSTimeInterval interval = [self roundToDayNumber:dayNumbers usingDay:weekdayNumber usingDirection:direction];
    
    NSDate *drawDate = [[NSDate alloc] initWithTimeIntervalSinceNow:(interval)];
    drawDate = [self roundDateToTime:drawDate usingHour:22 usingMinute:59 usingDirection:direction];
    //[self scheduleNotification:drawDate];
    return drawDate;
}

- (NSTimeInterval)roundToDayNumber:(NSArray *)dayNumbers usingDay:(NSNumber *)dayOfWeek usingDirection:(NSString *)direction
//Takes an array of weekdays (1-7) returns the number of seconds to add/subtract to get from dayOfWeek to one of those numbers
{
    NSTimeInterval interval = 0;
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSLog(@"secondsPerDay: %.0f",secondsPerDay);
    NSLog(@"DayNumbers are: %@",dayNumbers);
    NSLog(@"DayOfWeek is: %@",dayOfWeek);
    
    if ([direction isEqualToString:@"forward"]) {
        NSNumber *upperBound = [NSNumber numberWithInt:8];
        while (![dayNumbers containsObject:dayOfWeek]) {
            interval = interval + secondsPerDay;
            dayOfWeek = [NSNumber numberWithFloat:([dayOfWeek floatValue] + 1)];
            if ([dayOfWeek doubleValue] == [upperBound doubleValue]) {
                dayOfWeek = [NSNumber numberWithInt:1];
            }
            NSLog(@"roundToDayNumber forward dayOfWeek:%@",dayOfWeek);
        } 
    } else if ([direction isEqualToString:@"backward"]) {
        NSNumber *lowerBound = [NSNumber numberWithInt:0];
        while (![dayNumbers containsObject:dayOfWeek]) {
            interval = interval - secondsPerDay;
            dayOfWeek = [NSNumber numberWithFloat:([dayOfWeek floatValue] - 1)];
            if ([dayOfWeek doubleValue] == [lowerBound doubleValue]) {
                dayOfWeek = [NSNumber numberWithInt:7];
            }
            NSLog(@"roundToDayNumber backward dayOfWeek:%@",dayOfWeek);
        }
    }
    NSLog(@"Interval: %.0f",interval);
    return interval;
}

- (void)scheduleNotification:(NSDate *)nextDate
{
    UILocalNotification *futureAlert;
    futureAlert = [[UILocalNotification alloc] init];
    futureAlert.fireDate = nextDate;
    futureAlert.timeZone = [NSTimeZone defaultTimeZone];//ids this right - or do we want GMT?
    futureAlert.alertBody = @"The Powerball drawing just went down!";
    [[UIApplication sharedApplication] scheduleLocalNotification:futureAlert];
}

- (NSDate *)roundDateToTime:(NSDate *)startDate usingHour:(int)hour usingMinute:(int)minute usingDirection:(NSString *)direction //Takes a time, moves it backward or forward to 11PM, moves the time a full day if necessary
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]; 
    NSDateComponents *todayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:startDate];
    NSInteger theDay = [todayComponents day];
    NSInteger theMonth = [todayComponents month];
    NSInteger theYear = [todayComponents year];
    NSInteger theHour = [todayComponents hour];
    NSInteger theMinute = [todayComponents minute];
    
    if (direction == @"forward") {
        if (theHour > hour) {
            theHour = 0;
            theMinute = 0;
            theDay = theDay+1;
        }
        if (theHour == hour) {
            if (theMinute > minute) {
                theHour = 0;
                theMinute = 0;
                theDay = theDay+1;
            }
        }
    } else if (direction == @"backward") {
        if (theHour < hour) {
            theHour = 0;
            theMinute = 0;
            theDay = theDay-1;
        }
        if (theHour == hour) {
            if (theMinute < minute) {
                theHour = 0;
                theMinute = 0;
                theDay = theDay-1;
            }
        }
    } else {
        NSLog(@"We didn't use @forward or @backward in roundDateToTime");
    }
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay]; 
    [components setMonth:theMonth]; 
    [components setYear:theYear];
    [components setHour:hour]; 
    [components setMinute:minute]; 
    NSDate *roundedDate = [gregorian dateFromComponents:components];
    
    NSLog(@"%@", roundedDate);
    return roundedDate;
}

@end
