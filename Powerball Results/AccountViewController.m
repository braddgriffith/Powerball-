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
    
    //[self.view addSubview:scrollView]; //add the tableView
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
        headerLabel.text = @"Hit Login to get updates on winning tickets and enable Smartpick.";
    } else { 
        if ([appDelegate.user.first_name isEqualToString:@""] || [appDelegate.user.last_name isEqualToString:@""] || [appDelegate.user.location isEqualToString:@""]) {
            headerLabel.text = @"Complete your profile...";
        } else {
            headerLabel.text = @"Welcome to Powerball+";// @"Maximize winnings by selecting unique numbers. With Smartpick and accounts, no two Powerball+ users will choose the same numbers.";/
        }
        headerLabel.font = [UIFont boldSystemFontOfSize:18];
        logoutButton.title = @"Logout";
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
    } else {  //else, go ask FB for data
        [[PFFacebookUtils facebook] requestWithGraphPath:@"me?fields=first_name,last_name,email,location,username" //REQUEST_WITH_GRAPH_PATH
                                             andDelegate:self];
        NSLog(@"Got to FB");
    }
    appDelegate.user.parseUser = user;
    NSLog(@"didLogInUser currentUser = %@", [PFUser currentUser]);
    NSLog(@"didLogInUser user = %@", user);
    [self rowDataArrayLoadData];
    [tableViewForAccount reloadData]; 
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
    
    appDelegate.user.email = [user objectForKey:@"email"];
    [self dismissModalViewControllerAnimated:YES];
    appDelegate.user.first_name = @"";
    appDelegate.user.last_name = @"";
    appDelegate.user.location = @"";
    appDelegate.user.username = @"";
    
    [self rowDataArrayLoadData];
    [tableViewForAccount reloadData];
    logoutButton.title = @"Logout";
}

- (void)rowDataArrayLoadData
{
    self.rowDataArray = [NSMutableArray arrayWithObjects:appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.username, appDelegate.user.location, nil]; 
}

- (void)signUpViewControllerDidCancelLogIn:(PFSignUpViewController *)signUpController {
    NSLog(@"Cancelled sign up!");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)logoutButtonTouchHandler:(id)sender 
{
    if ([logoutButton.title isEqualToString:@"Logout"]) {
        [PFUser logOut]; // Logout user, this automatically clears the cache
        
        appDelegate.user.email = @"";
        appDelegate.user.first_name = @"";
        appDelegate.user.last_name = @"";
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
    return self.rowTitleArray.count;
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
        if ([[self.rowTitleArray objectAtIndex:indexPath.row] isEqualToString:@"Username"]) {
            [dataLabel setUserInteractionEnabled:NO];
        }
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
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *dataElement = [self.rowDataArray objectAtIndex:(textField.tag - 10)];
    NSLog(@"dataElement: %@", dataElement);
    dataElement = [textField text];
    NSLog(@"textfield: %@", [textField text]);
    NSLog(@"textfield.tag: %i", textField.tag);
    
    //self.rowDataArray = [NSMutableArray arrayWithObjects:appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.username, appDelegate.user.location, nil]; 
    if (textField.tag - 10 == 0) {
        appDelegate.user.first_name = dataElement;
    } if (textField.tag - 10 == 1) {
        appDelegate.user.last_name = dataElement;
    } if (textField.tag - 10 == 2) {
        appDelegate.user.email = dataElement;
    } if (textField.tag - 10 == 3) {
        appDelegate.user.username = dataElement;
    } if (textField.tag - 10 == 4) {
        appDelegate.user.location = dataElement;
    }
    activeField = nil;
    if(appDelegate.user.parseUser) {
        [appDelegate.user.parseUser saveInBackground];
        NSLog(@"Saving user");
    }
    if ([appDelegate.user.first_name isEqualToString:@""] || [appDelegate.user.last_name isEqualToString:@""] || [appDelegate.user.location isEqualToString:@""] || !appDelegate.user.first_name || !appDelegate.user.last_name || !appDelegate.user.location) {
        [headerLabel setText:@"Complete your profile..."];
    } else {
        [headerLabel setText:@"Welcome to Powerball+"];//@"Maximize winnings by selecting unique numbers. With Smartpick and accounts, no two Powerball+ users will choose the same numbers.";
    }
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