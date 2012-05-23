//
//  ParseLoginViewController.h
//  Powerball Results
//
//  Created by Brad Grifffith on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Parse/Parse.h>

@protocol ParseLoginViewControllerDelegate <NSObject>
- (void) didLogInUser;
@end

@interface ParseLoginViewController : PFLogInViewController

@end
