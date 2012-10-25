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
#import "User.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

@synthesize rowTitleArray, rowDataArray;
@synthesize tableViewForAccount;
@synthesize tableViewForAccountFrame;
@synthesize permissions;

@synthesize logoutButton;
@synthesize saveButton;
@synthesize headerLabel;
@synthesize activeField;

//@synthesize navBar;

int introHeight = 39;
int tableViewForAccountHeight = 400;
int naviHeight;

bool seenAccountIntro = NO;

AppDelegate *localDelegate;

bool userEdited = NO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    seenAccountIntro = [[currentDefaults objectForKey:@"seenAccountIntro"] boolValue];
    
    User *localUser = [AppDelegate user];
    
    self.permissions = [NSArray arrayWithObjects:@"email", @"user_location", @"user_about_me", nil]; 

    UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
    [navigationBar sizeToFit]; 
    naviHeight = navigationBar.frame.size.height;
    navigationBar.barStyle = UIBarStyleBlackTranslucent;
    UINavigationItem *titleItem = [[UINavigationItem alloc] initWithTitle:@"Account"];
    //navBar = navigationBar;
    
    CGRect frame = CGRectMake(20, naviHeight+5, self.view.frame.size.width-40, introHeight);
    self.headerLabel = [[UILabel alloc] initWithFrame:frame];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:190.0/255.0 blue:10.0/255.0 alpha:1];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.lineBreakMode = UILineBreakModeWordWrap;
    headerLabel.numberOfLines = 0;
    
    frame = CGRectMake(0, navigationBar.frame.size.height+introHeight, self.view.frame.size.width, tableViewForAccountHeight);
    self.tableViewForAccount = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    self.tableViewForAccount.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Stars02.png"]];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Stars02.png"]];
    [tableViewForAccount setBackgroundView:nil];
    [self.tableViewForAccount setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Stars02.png"]]];
    tableViewForAccount.dataSource = self;
    tableViewForAccount.delegate = self;
    
    logoutButton = [[UIBarButtonItem alloc] 
                    initWithTitle:@"Logout" 
                    style:UIBarButtonItemStyleBordered 
                    target:self 
                    action:@selector(logoutButtonTouchHandler:)];
    
    saveButton = [[UIBarButtonItem alloc] 
                    initWithTitle:@"Save" 
                    style:UIBarButtonItemStyleBordered 
                    target:self 
                    action:@selector(saveButtonTouchHandler:)];
    
    if (!([localUser.email isEqualToString:@""] || localUser.email == nil)) {
        logoutButton.title = @"Signup/Login";
    }
    
    titleItem.leftBarButtonItem = logoutButton;
    titleItem.rightBarButtonItem = saveButton;
    [navigationBar setItems:[NSArray arrayWithObject:titleItem]];
    
    [self.view addSubview:tableViewForAccount]; //add the tableView
    [self.view addSubview:navigationBar]; //add the bar
    [self.view addSubview:headerLabel]; //add the intro
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
    if ([localUser.email isEqualToString:@""] || localUser.email == nil) {
        [self displayParseLoginVC];
    }
    [self registerForKeyboardNotifications];
    
    self.rowTitleArray = [NSMutableArray arrayWithObjects:@"First Name", @"Last Name", @"Email", @"Username", @"Location", nil];
    
    if (seenAccountIntro == NO) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Welcome to Your Account!" 
                              message:@"Accounts enable Smartpick (intelligent selection). Facebook is easiest (we'll never share without asking). Tap the blue or the green button!" 
                              delegate:nil 
                              cancelButtonTitle:@"Hide" 
                              otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show]; 
        seenAccountIntro = YES;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:seenAccountIntro] forKey:@"seenAccountIntro"];
    }
}

- (void)viewWillAppear:(BOOL)animated //Creates and instatiates ParseLoginViewController if appdelegate.user.email == ""
{
    User *localUser = [AppDelegate user];
    NSLog(@"viewWillAppear localUser.email = %@", localUser.email);
    
    [self rowDataArrayLoadData];
    
    if ([localUser.email isEqualToString:@""] || localUser.email == nil) {
        logoutButton.title = @"Signup/Login";
        headerLabel.font = [UIFont boldSystemFontOfSize:14];
        headerLabel.text = @"Press Signup/Login to get updates on winning tickets and enable Smartpick.";
    } else { 
        if ([localUser.first_name isEqualToString:@""] || [localUser.last_name isEqualToString:@""] || [localUser.location isEqualToString:@""] 
            || [localUser.first_name isEqualToString:@"Tap to edit"] || [localUser.last_name isEqualToString:@"Tap to edit"]) {
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
    User *localUser = [AppDelegate user]; 
    
    [super viewWillDisappear:NO];
    if(localUser.parseUser && userEdited) {
        [localUser.parseUser saveInBackground];
        NSLog(@"Saving user");
        userEdited = NO;
    }
}

- (void)displayParseLoginVC
{
    User *localUser = [AppDelegate user];
    NSLog(@"displayParseLoginVC localUser.email = %@", localUser.email);
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
    User *localUser = [AppDelegate user];
    NSLog(@"Logged in and User: %@",user);
    
    if (![PFFacebookUtils isLinkedWithUser:user]) { //if account not linked w FB, use PFuser
        NSLog(@"Got to PFuser - not in FB");
        localUser.location = [user objectForKey:@"location"]; //just location from PFUser
        localUser.first_name = [user objectForKey:@"first_name"]; 
        localUser.last_name = [user objectForKey:@"last_name"]; //    
        localUser.email = user.email; 
        localUser.username = [user objectForKey:@"username"];
        localUser.parseUser = user;
        [self rowDataArrayLoadData];
        [tableViewForAccount reloadData]; 
    } else {  //else, go ask FB for data
        [[PFFacebookUtils facebook] requestWithGraphPath:@"me?fields=first_name,last_name,email,location,username" //REQUEST_WITH_GRAPH_PATH
                                             andDelegate:self];
        NSLog(@"Got to FB");
    }
    localUser.parseUser = user;
    NSLog(@"didLogInUser currentUser = %@", [PFUser currentUser]);
    NSLog(@"didLogInUser user = %@", user);
    [self dismissModalViewControllerAnimated:YES];
    
    //PUSH - subscribe to MY channel for scored tickets
    NSLog(@"a%@",localUser.parseUser.objectId);
    if (localUser.parseUser.objectId) {
        NSString *channel = [NSString stringWithFormat:@"a%@", localUser.parseUser.objectId];
        [PFPush subscribeToChannelInBackground:channel block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Successfully subscribed to the PERSONAL (%@) broadcast channel.",localUser.parseUser.objectId);
            } else {
                NSLog(@"Failed to subscribe to the PERSONAL (%@) broadcast channel.",localUser.parseUser.objectId);
            }
        }];
    }
}

-(void)request:(PF_FBRequest *)request didLoad:(id)result //IF WE GET DATA BACK FROM FB, SAVE TO NETWORK
{       
    User *localUser = [AppDelegate user];
    
    NSLog(@"didLoad - Facebook request %@ loaded", result);
    if ([[request url] rangeOfString:@"/me"].location != NSNotFound)
    {
        NSLog(@"didLoad result = %@",result);
        
        //Puts the latest appDelegate.user.X into the rowDataArray for display
        NSLog(@"result first_name: %@",[result objectForKey:@"first_name"]);
        NSString *first = [result objectForKey:@"first_name"];
        localUser.first_name = [NSString stringWithString:first];
        NSLog(@"localUser.first_name: %@",localUser.first_name);
        [localUser.parseUser setObject:first forKey:@"first_name"];
        
        if ([result objectForKey:@"first_name"]) {
            localUser.first_name = [result objectForKey:@"first_name"];
        } else {
            localUser.first_name = @"";
        }
        
        if ([result objectForKey:@"last_name"]) {
            localUser.last_name = [result objectForKey:@"last_name"];
        } else {
            localUser.last_name = @"";
        }
        
        if ([result objectForKey:@"email"]) {
            localUser.email = [result objectForKey:@"email"];
        } else {
            localUser.email = @"";
        }
        
        if ([[result objectForKey:@"location"]objectForKey:@"name"]) {
           localUser.location = [[result objectForKey:@"location"]objectForKey:@"name"];
        } else {
            localUser.location = @"";
        }
        
        if ([result objectForKey:@"username"]) {
            localUser.username = [result objectForKey:@"username"];
        } else {
            localUser.username = @"";
        }
        
        NSLog(@"didLoad localDelegate id = %@, first = %@, last = %@, email = %@, location = %@",[result objectForKey:@"id"], localUser.first_name, localUser.last_name, localUser.email, localUser.location);
        
        // https://parse.com/docs/ios_guide#users
        // other fields can be set just like with PFObject
        // [user setObject:@"415-392-0202" forKey:@"phone"];
        
        NSLog(@"didLoad currentUser = %@",[PFUser currentUser]);
        NSLog(@"didLoad localUser.parseUser = %@", localUser.parseUser);
        [localUser.parseUser setObject:localUser.first_name forKey:@"first_name"];
        [localUser.parseUser setObject:localUser.last_name forKey:@"last_name"];
        [localUser.parseUser setObject:localUser.email forKey:@"email"];
        [localUser.parseUser setObject:localUser.location forKey:@"location"];
        [localUser.parseUser setObject:localUser.username forKey:@"username"];
        NSLog(@"Saving user %@, stuff like %@ for first_name.", localUser.parseUser, localUser.first_name);
        [localUser.parseUser saveInBackground];
        
        logoutButton.title = @"Logout";
    }
    [self rowDataArrayLoadData];
    [self.tableViewForAccount reloadData];
    [self viewWillAppear:NO];
    logoutButton.title = @"Logout";
}

- (void)logInViewControllerDidCancelLogIn:(ParseLoginViewController *)logInController {
    NSLog(@"Cancelled log in!");
    [self dismissModalViewControllerAnimated:YES];
    logoutButton.title = @"Signup/Login";
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    NSLog(@"We signed up!");
    User *localUser = [AppDelegate user];
    
    if ([user objectForKey:@"first_name"]) {
        localUser.first_name = [user objectForKey:@"first_name"];
    } else {
        localUser.first_name = @"Tap to edit";
    }
    
    if ([user objectForKey:@"last_name"]) {
        localUser.last_name = [user objectForKey:@"last_name"];
    } else {
        localUser.last_name = @"Tap to edit";
    }
    
    if ([user objectForKey:@"email"]) {
        localUser.email = [user objectForKey:@"email"];
    } else {
        localUser.email = @"Tap to edit";
    }
    
    if (user.username) {
        localUser.username = user.username;
    } else {
        localUser.username = @"nil";
    }
    
    if ([user objectForKey:@"location"]) {
        localUser.location = [user objectForKey:@"location"];
    } else {
        localUser.location = @"Tap to edit";
    }
    
    [self dismissModalViewControllerAnimated:YES];
    localUser.parseUser = user;
    [self rowDataArrayLoadData];
    [tableViewForAccount reloadData];
    logoutButton.title = @"Logout";
}

- (void)rowDataArrayLoadData //Puts the latest appDelegate.user.X into the rowDataArray for display
{
    User *localUser = [AppDelegate user];

    NSLog(@"localUser.first_name = %@", localUser.first_name);
    NSLog(@"localUser.last_name = %@", localUser.last_name);
    NSLog(@" localUser.email = %@", localUser.email);
    NSLog(@" localUser.username = %@", localUser.username);
    NSLog(@" localUser.location = %@", localUser.location);
    self.rowDataArray = [NSMutableArray arrayWithObjects:localUser.first_name, localUser.last_name, localUser.email, localUser.username, localUser.location, nil];
    NSLog(@"rowDataArray loaded data self.rowDataArray.count = %d", self.rowDataArray.count);
    
    self.tableViewForAccount.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Stars02.png"]];
}

- (void)signUpViewControllerDidCancelLogIn:(PFSignUpViewController *)signUpController {
    NSLog(@"Cancelled sign up!");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)logoutButtonTouchHandler:(id)sender 
{
    User *localUser = [AppDelegate user];
    
    if ([logoutButton.title isEqualToString:@"Logout"]) {
        [PFUser logOut]; // Logout user, this automatically clears the cache
        
        localUser.first_name = @"";
        localUser.last_name = @"";
        localUser.email = @"";
        localUser.location = @"";
        localUser.username = @"";
        
        [self rowDataArrayLoadData];
        [self.tableViewForAccount reloadData];
        logoutButton.title = @"Login";
        headerLabel.font = [UIFont boldSystemFontOfSize:14];
        [headerLabel setText:@"Hit Login to get updates on winning tickets and enable Smartpick."];
        NSLog(@"We logged out!");
    } else {
        [self displayParseLoginVC];
    }
    NSLog(@"logoutButton localUser.email = %@", localUser.email);
}

- (void)saveButtonTouchHandler:(id)sender 
{
    User *localUser = [AppDelegate user];
    
    if (!localUser.parseUser) {
        localUser.parseUser = [[PFUser alloc] init];
    }
    
    if ([saveButton.title isEqualToString:@"Save"]) {
        NSLog(@"localUser.parseUser = %@",localUser.parseUser);
        NSLog(@"localUser.first_name = %@",localUser.first_name);
        [localUser.parseUser saveInBackground];
        [[self.tableViewForAccount superview] endEditing:YES];
    } 
    [HudView hudInView:self.view text:@"Account" lineTwo:@"Updated" animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"self.rowTitleArray.count = %d", self.rowTitleArray.count);
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
    User *localUser = [AppDelegate user];
    
    userEdited= YES;
    NSString *dataElement = [self.rowDataArray objectAtIndex:(textField.tag - 10)];
    NSLog(@"dataElement: %@", dataElement);
    dataElement = [textField text];
    NSLog(@"textfield: %@", [textField text]);
    NSLog(@"textfield.tag: %i", textField.tag);
    
    if (!localUser.parseUser) {
        localUser.parseUser = [[PFUser alloc] init];
    }
    
    //self.rowDataArray = [NSMutableArray arrayWithObjects:appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.username, appDelegate.user.location, nil]; 
    if (textField.tag - 10 == 0) {
        localUser.first_name = [NSString stringWithString:dataElement];
        [localUser.parseUser setObject:dataElement forKey:@"first_name"];
    } if (textField.tag - 10 == 1) {
        localUser.last_name = [NSString stringWithString:dataElement];
        [localUser.parseUser setObject:dataElement forKey:@"last_name"];
    } if (textField.tag - 10 == 2) {
        localUser.email = [NSString stringWithString:dataElement];
        [localUser.parseUser setObject:dataElement forKey:@"email"];
    } if (textField.tag - 10 == 3) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:dataElement]; // find all users
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSLog(@"Successfully retrieved %d users.", objects.count);
                if(objects.count == 0) {
                    NSLog(@"dataElement: %@", dataElement);
                    NSLog(@"appDelegate.user.username: %@", localUser.username);
                    NSLog(@"appDelegate.user.parseUser: %@", localUser.parseUser);
                    localUser.username = [NSString stringWithString:dataElement];;
                    localUser.parseUser.username = [NSString stringWithString:dataElement];;
                    activeField = nil;
                    NSLog(@"appDelegate.user.username after dataElement: %@", localUser.username);
                    [localUser.parseUser saveInBackground];
                    NSLog(@"Saving user with an updated username");
                    //[HudView hudInView:self.view text:@"Username" lineTwo:@"Updated" animated:YES];
                } else {
                    if (![dataElement isEqualToString:localUser.username]) {
                        [HudView hudInView:self.view text:@"Username Taken" lineTwo:@"Choose Another" animated:YES];
                        NSLog(@"Someone has that username");
                    }
                    textField.text = localUser.username;
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    } if (textField.tag - 10 == 4) {
        localUser.location = [NSString stringWithString:dataElement];;
        [localUser.parseUser setObject:dataElement forKey:@"location"];
    }
    activeField = nil;
    if ([localUser.first_name isEqualToString:@""] || [localUser.last_name isEqualToString:@""] || [localUser.location isEqualToString:@""] || !localUser.first_name || !localUser.last_name || !localUser.location) {
        [headerLabel setText:@"Complete your profile..."];
    } else {
        [headerLabel setText:@"Welcome to Powerball+"];//@"Maximize winnings by selecting unique numbers. With Smartpick and accounts, no two Powerball+ users will choose the same numbers.";
    }
    [self rowDataArrayLoadData];
    //AppDelegate.user = localUser;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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