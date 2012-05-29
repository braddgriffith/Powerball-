//
//  User.h
//  Powerball Results
//
//  Created by Brad Grifffith on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *current_cause;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *credit_card_last_4;
@property (nonatomic, strong) NSString *credit_card_type;
@property (nonatomic, strong) NSString *default_cause;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) PFUser *parseUser;

@end
