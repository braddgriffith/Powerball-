//
//  AccountViewController.h
//  Powerball Results
//
//  Created by Brad Grifffith on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ParseLoginViewController.h"

@interface AccountViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, PF_FBRequestDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;

// UITableView header view properties
@property (nonatomic, strong) UITableView *tableViewForAccount;

// UITableView row data properties
@property (nonatomic, strong) NSMutableArray *rowTitleArray;
@property (nonatomic, strong) NSMutableArray *rowDataArray;

@property (nonatomic, strong) NSArray *permissions; 

// BUTTONS
@property (nonatomic, strong) UIBarButtonItem *logoutButton;
@property (nonatomic, strong) IBOutlet UILabel *headerLabel;

@end