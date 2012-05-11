//
//  Selection.h
//  Powerball Results
//
//  Created by Brad Grifffith on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Selection : NSObject <NSCoding>

@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSDate * drawingDate;
@property (nonatomic, strong) NSNumber * selectionOne;
@property (nonatomic, strong) NSNumber * selectionTwo;
@property (nonatomic, strong) NSNumber * selectionThree;
@property (nonatomic, strong) NSNumber * selectionFour;
@property (nonatomic, strong) NSNumber * selectionFive;
@property (nonatomic, strong) NSNumber * selectionPowerball;
@property (nonatomic, strong) NSString * userID;
@property (nonatomic, strong) NSMutableArray * selectionArray;
@property (nonatomic, strong) NSDate * userChosenDate;
@property (nonatomic, strong) NSString * jackpot;

@end
