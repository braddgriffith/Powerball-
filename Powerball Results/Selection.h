//
//  Selection.h
//  Powerball Results
//
//  Created by Brad Grifffith on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Selection : NSObject //<NSCoding>

@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * drawingDate;
@property (nonatomic, strong) NSString * selectionOne;
@property (nonatomic, strong) NSString * selectionTwo;
@property (nonatomic, strong) NSString * selectionThree;
@property (nonatomic, strong) NSString * selectionFour;
@property (nonatomic, strong) NSString * selectionFive;
@property (nonatomic, strong) NSString * selectionPowerball;
@property (nonatomic, strong) NSString * userID;

@end
