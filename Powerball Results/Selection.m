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
    [coder encodeObject:userID forKey:@"selectionArray"];
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
        self.userID = [coder decodeObjectForKey:@"selectionArray"];
    }   
    return self;
}

@end
