//
//  Selection.m
//  Powerball Results
//
//  Created by Brad Grifffith on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Selection.h"

@implementation Selection 

@synthesize type;
@synthesize drawingDate;
@synthesize selectionOne;
@synthesize selectionTwo;
@synthesize selectionThree;
@synthesize selectionFour;
@synthesize selectionFive;
@synthesize selectionPowerball;
@synthesize userID;
@synthesize selectionArray;
@synthesize userChosenDate;
@synthesize jackpot;

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:type forKey:@"type"];
    [coder encodeObject:drawingDate forKey:@"drawingDate"];
    [coder encodeObject:selectionOne forKey:@"selectionOne"];
    [coder encodeObject:selectionTwo forKey:@"selectionTwo"];
    [coder encodeObject:selectionThree forKey:@"selectionThree"];
    [coder encodeObject:selectionFour forKey:@"selectionFour"];
    [coder encodeObject:selectionFive forKey:@"selectionFive"];
    [coder encodeObject:selectionPowerball forKey:@"selectionPowerball"];
    [coder encodeObject:userID forKey:@"userID"];
    [coder encodeObject:selectionArray forKey:@"selectionArray"];
    [coder encodeObject:userChosenDate forKey:@"userChosenDate"];
    [coder encodeObject:jackpot forKey:@"jackpot"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    self = [[Selection alloc] init];
    if (self != nil)
    {
        self.type = [coder decodeObjectForKey:@"type"];
        self.drawingDate = [coder decodeObjectForKey:@"drawingDate"];
        self.selectionOne = [coder decodeObjectForKey:@"selectionOne"];
        self.selectionTwo = [coder decodeObjectForKey:@"selectionTwo"];
        self.selectionThree = [coder decodeObjectForKey:@"selectionThree"];
        self.selectionFour = [coder decodeObjectForKey:@"selectionFour"];
        self.selectionFive = [coder decodeObjectForKey:@"selectionFive"];
        self.selectionPowerball = [coder decodeObjectForKey:@"selectionPowerball"];
        self.userID = [coder decodeObjectForKey:@"userID"];
        self.selectionArray = [coder decodeObjectForKey:@"selectionArray"];
        self.userChosenDate = [coder decodeObjectForKey:@"userChosenDate"];
        self.jackpot = [coder decodeObjectForKey:@"jackpot"];
    }   
    return self;
}

@end
