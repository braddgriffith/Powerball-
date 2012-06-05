//
//  AccountViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "ParseLoginViewController.h"
#import "HudView.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

@synthesize rowTitleArray, rowDataArray;
@synthesize appDelegate;
@synthesize tableViewForAccount;
@synthesize tableViewForAccountFrame;
@synthesize permissions;

@synthesize logoutButton;
@synthesize headerLabel;
@synthesize activeField;

int introHeight = 39;
int tableViewForAccountHeight = 400;
int naviHeight;

bool userEdited = NO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = [[UIApplication sharedApplication] delegate]; 
    self.permissions = [NSArray arrayWithObjects:@"email", @"user_location", @"user_about_me", nil]; 
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
    [navigationBar sizeToFit]; 
    naviHeight = navigationBar.frame.size.height;
    navigationBar.barStyle = UIBarStyleBlackTranslucent;
    UINavigationItem *titleItem = [[UINavigationItem alloc] initWithTitle:@"Account"];
    
    CGRect frame = CGRectMake(20, naviHeight+5, self.view.frame.size.width-40, introHeight);
    self.headerLabel = [[UILabel alloc] initWithFrame:frame];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:190.0/255.0 blue:10.0/255.0 alpha:1];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.lineBreakMode = UILineBreakModeWordWrap;
    headerLabel.numberOfLines = 0;
    
    frame = CGRectMake(0, navigationBar.frame.size.height+introHeight, self.view.frame.size.width, tableViewForAccountHeight);
    self.tableViewForAccount = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Stars02.png"]];
    [self.tableViewForAccount setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Stars02.png"]]];
    tableViewForAccount.dataSource = self;
    tableViewForAccount.delegate = self;
    
    logoutButton = [[UIBarButtonItem alloc] 
                    initWithTitle:@"Logout" 
                    style:UIBarButtonItemStyleBordered 
                    target:self 
                    action:@selector(logoutButtonTouchHandler:)];
    
    if (!([appDelegate.user.email isEqualToString:@""] || appDelegate.user.email == nil)) {
        logoutButton.title = @"Login";
    }
    
    titleItem.leftBarButtonItem = logoutButton;
    [navigationBar setItems:[NSArray arrayWithObject:titleItem]];
    
    [self.view addSubview:tableViewForAccount]; //add the tableView
    [self.view addSubview:navigationBar]; //add the bar
    [self.view addSubview:headerLabel]; //add the intro
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
    if ([appDelegate.user.email isEqualToString:@""] || appDelegate.user.email == nil) {
        [self displayParseLoginVC];
    }
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated //Creates and instatiates ParseLoginViewController if appdelegate.user.email == ""
{
    NSLog(@"viewWillAppear appDelegate.user.email = %@", appDelegate.user.email);
    
    self.rowTitleArray = [NSMutableArray arrayWithObjects:@"First Name", @"Last Name", @"Email", @"Username", @"Location", nil];
    [self rowDataArrayLoadData];
    
    NSLog(@"viewWillAppear appDelegate.user.email = %@", appDelegate.user.email);
    
    if ([appDelegate.user.email isEqualToString:@""] || appDelegate.user.email == nil) {
        logoutButton.title = @"Login";
        headerLabel.font = [UIFont boldSystemFontOfSize:14];
        headerLabel.text = @"Press Login to get updates on winning tickets and enable Smartpick.";
    } else { 
        if ([appDelegate.user.first_name isEqualToString:@""] || [appDelegate.user.last_name isEqualToString:@""] || [appDelegate.user.location isEqualToString:@""] 
            || [appDelegate.user.first_name isEqualToString:@"Tap to edit"] || [appDelegate.user.last_name isEqualToString:@"Tap to edit"]) {
            headerLabel.text = @"Complete your profile...";
        } else {
            headerLabel.text = @"Welcome to Powerball+";// @"Maximize winnings by selecting unique numbers. With Smartpick and accounts, no two Powerball+ users will choose the same numbers.";/
        }
        headerLabel.font = [UIFont boldSystemFontOfSize:18];
        logoutButton.title = @"Logout";
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
    if(appDelegate.user.parseUser && userEdited) {
        [appDelegate.user.parseUser saveInBackground];
        NSLog(@"Saving user");
        userEdited = NO;
    }
}

- (void)displayParseLoginVC
{
    NSLog(@"displayParseLoginVC appDelegate.user.email = %@", appDelegate.user.email);
    [PFUser logOut]; //WATCH FOR THIS
    ParseLoginViewController *logInController = [[ParseLoginViewController alloc] init];
    
    logInController.fields = PFLogInFieldsUsernameAndPassword
    | PFLogInFieldsFacebook
    | PFLogInFieldsSignUpButton
    | PFLogInFieldsDismissButton
    | PFLogInFieldsPasswordForgotten;
    
    logInController.facebookPermissions = permissions;
    
    logInController.delegate = self;
    logInController.signUpController.delegate = self;
    [self presentModalViewController:logInController animated:YES];
}

#pragma mark - PFLogInViewControllerDelegate

- (void)logInViewController:(ParseLoginViewController *)controller didLogInUser:(PFUser *)user //If FB user, ask FB for details w requestWithGraphPath me?fields=id
{ 
    NSLog(@"Logged in and User: %@",user);
    
    if (![PFFacebookUtils isLinkedWithUser:user]) { //if account not linked w FB, use PFuser
        NSLog(@"Got to PFuser - not in FB");
        appDelegate.user.location = [user objectForKey:@"location"]; //just location from PFUser
        appDelegate.user.first_name = [user objectForKey:@"first_name"]; 
        appDelegate.user.last_name = [user objectForKey:@"last_name"]; //    
        appDelegate.user.email = user.email; 
        appDelegate.user.username = [user objectForKey:@"username"];
        appDelegate.user.parseUser = user;
        [self rowDataArrayLoadData];
        [tableViewForAccount reloadData]; 
    } else {  //else, go ask FB for data
//        [PFFacebookUtils linkUser:user permissions:nil block:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                NSLog(@"Woohoo, user logged in with Facebook!");
//            }
//        }];
        [[PFFacebookUtils facebook] requestWithGraphPath:@"me?fields=first_name,last_name,email,location,username" //REQUEST_WITH_GRAPH_PATH
                                             andDelegate:self];
        NSLog(@"Got to FB");
    }
    appDelegate.user.parseUser = user;
    NSLog(@"didLogInUser currentUser = %@", [PFUser currentUser]);
    NSLog(@"didLogInUser user = %@", user);
    [self dismissModalViewControllerAnimated:YES];
    
    //PUSH - subscribe to MY channel for scored tickets - appDelegate.user.id
    NSString *channel = [NSString stringWithFormat:@"a%@", user.objectId];
    [PFPush subscribeToChannelInBackground:channel block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully subscribed to the PERSONAL (%@) broadcast channel.",appDelegate.user.id);
        } else {
            NSLog(@"Failed to subscribe to the PERSONAL (%@) broadcast channel.",appDelegate.user.id);
        }
    }];
}

-(void)request:(PF_FBRequest *)request didLoad:(id)result //IF WE GET DATA BACK FROM FB, SAVE TO NETWORK
{       
    NSLog(@"didLoad - Facebook request %@ loaded", result);
    if ([[request url] rangeOfString:@"/me"].location != NSNotFound)
    {
        NSLog(@"didLoad result = %@",result);
        
        //Puts the latest appDelegate.user.X into the rowDataArray for display
        appDelegate.user.first_name = [result objectForKey:@"first_name"];
        appDelegate.user.last_name = [result objectForKey:@"last_name"];
        appDelegate.user.email = [result objectForKey:@"email"];
        appDelegate.user.location = [[result objectForKey:@"location"]objectForKey:@"name"];
        appDelegate.user.username = [result objectForKey:@"username"];
        
        NSLog(@"didLoad appDelegate id = %@, first = %@, last = %@, email = %@, location = %@",[result objectForKey:@"id"], appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.location);
        
        // https://parse.com/docs/ios_guide#users
        // other fields can be set just like with PFObject
        // [user setObject:@"415-392-0202" forKey:@"phone"];
        
        [[PFUser currentUser] refresh];
        
        NSLog(@"didLoad currentUser = %@",[PFUser currentUser]);
        NSLog(@"didLoad appDelegate.user.parseUser = %@", appDelegate.user.parseUser);
        [appDelegate.user.parseUser setObject:appDelegate.user.first_name forKey:@"first_name"];
        [appDelegate.user.parseUser setObject:appDelegate.user.last_name forKey:@"last_name"];
        [appDelegate.user.parseUser setObject:appDelegate.user.email forKey:@"email"];
        [appDelegate.user.parseUser setObject:appDelegate.user.location forKey:@"location"];
        [appDelegate.user.parseUser setObject:appDelegate.user.username forKey:@"username"];
        NSLog(@"Saving user %@, stuff like %@ for first_name.", appDelegate.user.parseUser, appDelegate.user.first_name);
        [appDelegate.user.parseUser saveInBackground];
        
        logoutButton.title = @"Logout";
    }
    [self rowDataArrayLoadData];
    [self.tableViewForAccount reloadData];
    [self viewWillAppear:NO];
}

- (void)logInViewControllerDidCancelLogIn:(ParseLoginViewController *)logInController {
    NSLog(@"Cancelled log in!");
    [self dismissModalViewControllerAnimated:YES];
    logoutButton.title = @"Login";
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    NSLog(@"We signed up!");
    
    if ([user objectForKey:@"first_name"]) {
        appDelegate.user.first_name = [user objectForKey:@"first_name"];
    } else {
        appDelegate.user.first_name = @"Tap to edit";
    }
    
    if ([user objectForKey:@"last_name"]) {
        appDelegate.user.last_name = [user objectForKey:@"last_name"];
    } else {
        appDelegate.user.last_name = @"Tap to edit";
    }
    
    if ([user objectForKey:@"email"]) {
        appDelegate.user.email = [user objectForKey:@"email"];
    } else {
        appDelegate.user.email = @"Tap to edit";
    }
    
    if (user.username) {
        appDelegate.user.username = user.username;
    } else {
        appDelegate.user.username = @"nil";
    }
    
    if ([user objectForKey:@"location"]) {
        appDelegate.user.location = [user objectForKey:@"location"];
    } else {
        appDelegate.user.location = @"Tap to edit";
    }
    
    [self dismissModalViewControllerAnimated:YES];
    appDelegate.user.parseUser = user;
    [self rowDataArrayLoadData];
    [tableViewForAccount reloadData];
    logoutButton.title = @"Logout";
}

- (void)rowDataArrayLoadData //Puts the latest appDelegate.user.X into the rowDataArray for display
{
//    self.rowDataArray = [NSMutableArray arrayWithObjects:
//                         [NSString stringWithString:appDelegate.user.first_name], 
//                         [NSString stringWithString:appDelegate.user.last_name],//appDelegate.user.last_name, 
//                         [NSString stringWithString:appDelegate.user.email],//appDelegate.user.email, 
//                         [NSString stringWithString:appDelegate.user.username],//appDelegate.user.username, 
//                         [NSString stringWithString:appDelegate.user.location],//appDelegate.user.location, 
//                         nil]; 
    self.rowDataArray = [NSMutableArray arrayWithObjects:appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.username, appDelegate.user.location, nil];
    NSLog(@"rowDataArray loaded data");
}

- (void)signUpViewControllerDidCancelLogIn:(PFSignUpViewController *)signUpController {
    NSLog(@"Cancelled sign up!");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)logoutButtonTouchHandler:(id)sender 
{
    if ([logoutButton.title isEqualToString:@"Logout"]) {
        [PFUser logOut]; // Logout user, this automatically clears the cache
        
        appDelegate.user.first_name = @"";
        appDelegate.user.last_name = @"";
        appDelegate.user.email = @"";
        appDelegate.user.location = @"";
        appDelegate.user.username = @"";
        
        [self rowDataArrayLoadData];
        [self.tableViewForAccount reloadData];
        logoutButton.title = @"Login";
        headerLabel.font = [UIFont boldSystemFontOfSize:14];
        [headerLabel setText:@"Hit Login to get updates on winning tickets and enable Smartpick."];
        NSLog(@"We logged out!");
    } else {
        [self displayParseLoginVC];
    }
    NSLog(@"logoutButton appDelegate.user.email = %@", appDelegate.user.email);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"self.rowDataArray.count = %d", self.rowDataArray.count);
    return self.rowDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        // Create the cell and add the labels
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 44)];
        [titleLabel setTag:1]; // We use the tag to set it later
        [titleLabel setTextAlignment:UITextAlignmentRight];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        
        UITextField *dataTextField = [[UITextField alloc] initWithFrame:CGRectMake(125, 1, 160, 44)];
        [dataTextField setTag:(10 + indexPath.row)]; // We use the tag to set it later
        [dataTextField setFont:[UIFont systemFontOfSize:17]];
        [dataTextField setBackgroundColor:[UIColor clearColor]];
        [dataTextField setTextAlignment:UITextAlignmentLeft];
        dataTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        dataTextField.delegate = self;
        
        [cell.contentView addSubview:titleLabel];
        [cell.contentView addSubview:dataTextField];
    }
    
    // Cannot select these cells
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // Access labels in the cell using the tag # 
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UITextField *dataLabel = (UITextField *)[cell viewWithTag:(10 + indexPath.row)];
    
    // Display the data in the table
    [titleLabel setText:[self.rowTitleArray objectAtIndex:indexPath.row]];
    if (self.rowDataArray.count != 0) {
        NSLog(@"Indexpath: we have: %@",[self.rowDataArray objectAtIndex:indexPath.row]); 
        [dataLabel setText:[self.rowDataArray objectAtIndex:indexPath.row]];
//        if ([[self.rowTitleArray objectAtIndex:indexPath.row] isEqualToString:@"Username"]) {
//            [dataLabel setUserInteractionEnabled:NO];
//        }
    }
    return cell;
}

- (IBAction)viewTapped
{ 
    [[self.tableViewForAccount superview] endEditing:YES];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableViewForAccount.contentInset = contentInsets;
    self.tableViewForAccount.scrollIndicatorInsets = contentInsets;
    
    self.tableViewForAccountFrame = self.tableViewForAccount.frame;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    CGRect frame = CGRectMake(0, naviHeight+introHeight, self.view.frame.size.width, self.view.frame.size.height - kbSize.height - introHeight);
    [self.tableViewForAccount setFrame:frame];
    [self.tableViewForAccount setContentSize:CGSizeMake(self.view.frame.size.width, 500)];
    
    NSLog(@"aRect: %@", NSStringFromCGRect(aRect));
    NSLog(@"Origin: %@", NSStringFromCGPoint(activeField.frame.origin));
    
    CGPoint rootViewPoint = [activeField convertPoint:activeField.frame.origin toView:self.view];
    NSLog(@"rootViewPoint: %@", NSStringFromCGPoint(rootViewPoint));
    
    if (!CGRectContainsPoint(aRect, rootViewPoint)) { //activeField.frame.origin is the key
        [self.tableViewForAccount scrollRectToVisible:activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableViewForAccount.contentInset = contentInsets;
    self.tableViewForAccount.scrollIndicatorInsets = contentInsets;
    self.tableViewForAccount.frame = tableViewForAccountFrame;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"Tap to edit"]) {
        textField.text = @"";
    }
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    userEdited= YES;
    NSString *dataElement = [self.rowDataArray objectAtIndex:(textField.tag - 10)];
    NSLog(@"dataElement: %@", dataElement);
    dataElement = [textField text];
    NSLog(@"textfield: %@", [textField text]);
    NSLog(@"textfield.tag: %i", textField.tag);
    
    //self.rowDataArray = [NSMutableArray arrayWithObjects:appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.username, appDelegate.user.location, nil]; 
    if (textField.tag - 10 == 0) {
        appDelegate.user.first_name = [NSString stringWithString:dataElement];
        [appDelegate.user.parseUser setObject:dataElement forKey:@"first_name"];
    } if (textField.tag - 10 == 1) {
        appDelegate.user.last_name = [NSString stringWithString:dataElement];
        [appDelegate.user.parseUser setObject:dataElement forKey:@"last_name"];
    } if (textField.tag - 10 == 2) {
        appDelegate.user.email = [NSString stringWithString:dataElement];
        [appDelegate.user.parseUser setObject:dataElement forKey:@"email"];
    } if (textField.tag - 10 == 3) {
        PFQuery *query = [PFQuery queryForUser];
        [query whereKey:@"username" equalTo:dataElement]; // find all users
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSLog(@"Successfully retrieved %d users.", objects.count);
                if(objects.count == 0) {
                    NSLog(@"dataElement: %@", dataElement);
                    NSLog(@"appDelegate.user.username: %@", appDelegate.user.username);
                    NSLog(@"appDelegate.user.parseUser: %@", appDelegate.user.parseUser);
                    appDelegate.user.username = [NSString stringWithString:dataElement];;
                    appDelegate.user.parseUser.username = [NSString stringWithString:dataElement];;
                    activeField = nil;
                    NSLog(@"appDelegate.user.username after dataElement: %@", appDelegate.user.username);
                    [appDelegate.user.parseUser saveInBackground];
                    NSLog(@"Saving user");
                    [HudView hudInView:self.view text:@"Username" lineTwo:@"Updated" animated:YES];
                } else {
                    [HudView hudInView:self.view text:@"Username Taken" lineTwo:@"Choose Another" animated:YES];
                    NSLog(@"Someone has that username");
                    textField.text = appDelegate.user.username;
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    } if (textField.tag - 10 == 4) {
        appDelegate.user.location = [NSString stringWithString:dataElement];;
        [appDelegate.user.parseUser setObject:dataElement forKey:@"location"];
    }
    activeField = nil;
    if ([appDelegate.user.first_name isEqualToString:@""] || [appDelegate.user.last_name isEqualToString:@""] || [appDelegate.user.location isEqualToString:@""] || !appDelegate.user.first_name || !appDelegate.user.last_name || !appDelegate.user.location) {
        [headerLabel setText:@"Complete your profile..."];
    } else {
        [headerLabel setText:@"Welcome to Powerball+"];//@"Maximize winnings by selecting unique numbers. With Smartpick and accounts, no two Powerball+ users will choose the same numbers.";
    }
    [self rowDataArrayLoadData];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

@end