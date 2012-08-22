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

@interface AccountViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, PF_FBRequestDelegate, UITextFieldDelegate> {
    //AppDelegate *appDelegate;
}

// Connections
//@property (nonatomic, weak) AppDelegate *appDelegate;

// Data
@property (nonatomic, strong) NSArray *permissions; 

// UITableView header view properties
@property (nonatomic, strong) UITableView *tableViewForAccount;
@property (nonatomic, assign) CGRect tableViewForAccountFrame;

// UITableView row data properties
@property (nonatomic, strong) NSMutableArray *rowTitleArray;
@property (nonatomic, strong) NSMutableArray *rowDataArray;
@property (nonatomic, strong) UITextField *activeField;

// User Interface
@property (nonatomic, strong) UIBarButtonItem *logoutButton;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) IBOutlet UILabel *headerLabel;

//@property (nonatomic, strong) UINavigationBar *navBar;

@end