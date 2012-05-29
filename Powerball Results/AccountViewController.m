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
@synthesize permissions;

@synthesize logoutButton;
@synthesize headerLabel;

int introHeight = 39;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = [[UIApplication sharedApplication] delegate]; 
    permissions = [NSArray arrayWithObjects:@"email", @"user_location", @"user_about_me", nil]; 
    
    CGRect frame = CGRectMake(20, 44+5, self.view.frame.size.width-40, introHeight);
    headerLabel = [[UILabel alloc] initWithFrame:frame];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:190.0/255.0 blue:10.0/255.0 alpha:1];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.lineBreakMode = UILineBreakModeWordWrap;
    headerLabel.numberOfLines = 0;
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
    [navigationBar sizeToFit]; 
    navigationBar.barStyle = UIBarStyleBlackTranslucent;
    UINavigationItem *titleItem = [[UINavigationItem alloc] initWithTitle:@"Account"];
    
    frame = CGRectMake(0, navigationBar.frame.size.height+introHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBar.frame.size.height - introHeight);
    tableViewForAccount = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.tableViewForAccount setBackgroundColor:[UIColor blackColor]];
    tableViewForAccount.dataSource = self;
    tableViewForAccount.delegate = self;
    
    logoutButton = [[UIBarButtonItem alloc] 
                    initWithTitle:@"Logout" 
                    style:UIBarButtonItemStyleBordered 
                    target:self 
                    action:@selector(logoutButtonTouchHandler:)];
    
    if (!([appDelegate.user.email isEqualToString:@""] || appDelegate.user.email == nil)) {
        logoutButton.title = @"Login";
    } else {

    }
    
    titleItem.leftBarButtonItem = logoutButton;
    [navigationBar setItems:[NSArray arrayWithObject:titleItem]];
    
    [self.view addSubview:tableViewForAccount]; //add the tableView
    [self.view addSubview:navigationBar]; //add the bar
    [self.view addSubview:headerLabel]; //add the intro
}

- (void)viewWillAppear:(BOOL)animated //Creates and instatiates ParseLoginViewController if appdelegate.user.email == ""
{
    NSLog(@"viewWillAppear appDelegate.user.email = %@", appDelegate.user.email);
    
    self.rowTitleArray = [NSMutableArray arrayWithObjects:@"First Name", @"Last Name", @"Email", @"Username", @"Location", nil]; 
    [self rowDataArrayLoadData];
    
    NSLog(@"viewWillAppear appDelegate.user.email = %@", appDelegate.user.email);
    if ([appDelegate.user.email isEqualToString:@""] || appDelegate.user.email == nil) {
        [self displayParseLoginVC];
        headerLabel.font = [UIFont boldSystemFontOfSize:14];
        headerLabel.text = @"Hit Login to get updates on winning tickets and enable Smartpick.";
    } else {
        headerLabel.font = [UIFont boldSystemFontOfSize:18];
        headerLabel.text = @"Welcome to Powerball+";// @"Maximize winnings by selecting unique numbers. With Smartpick and accounts, no two Powerball+ users will choose the same numbers.";/
    }
}

- (void)displayParseLoginVC
{
    NSLog(@"displayParseLoginVC appDelegate.user.email = %@", appDelegate.user.email);
    [PFUser logOut]; 
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
    appDelegate.user.parseUser = user; //5.28 ADDED USER TO APPDELEGATE AND ASSIGNED HERE
    [self rowDataArrayLoadData];
    [tableViewForAccount reloadData]; 
    [self dismissModalViewControllerAnimated:YES];
    
    //LOGGED IN USER
    NSString *channel = [NSString stringWithFormat:@"a%@", appDelegate.user.id]; //subscribe to GENERAL BROADCAST CHANNEL
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
        NSLog(@"result = %@",result);
        
        appDelegate.user.first_name = [result objectForKey:@"first_name"];
        appDelegate.user.last_name = [result objectForKey:@"last_name"];
        appDelegate.user.email = [result objectForKey:@"email"];
        appDelegate.user.location = [[result objectForKey:@"location"]objectForKey:@"name"];
        appDelegate.user.username = [result objectForKey:@"username"];
        
        NSLog(@"appDelegate id = %@, first = %@, last = %@, email = %@, location = %@",[result objectForKey:@"id"], appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.location);
        
        // https://parse.com/docs/ios_guide#users
        // other fields can be set just like with PFObject
        // [user setObject:@"415-392-0202" forKey:@"phone"];
        NSLog(@"requestDidLoad currentUser = %@",[PFUser currentUser]);
        NSLog(@"requestDidLoad appDelegate.user.parseUser = %@", appDelegate.user.parseUser);
        [appDelegate.user.parseUser setObject:appDelegate.user.first_name forKey:@"first_name"];
        [appDelegate.user.parseUser setObject:appDelegate.user.last_name forKey:@"last_name"];
        [appDelegate.user.parseUser setObject:appDelegate.user.email forKey:@"email"];
        [appDelegate.user.parseUser setObject:appDelegate.user.location forKey:@"location"];
        [appDelegate.user.parseUser setObject:appDelegate.user.username forKey:@"username"];
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
        
        UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, 155, 44)];
        [dataLabel setTag:2]; // We use the tag to set it later
        [dataLabel setFont:[UIFont systemFontOfSize:17]];
        [dataLabel setBackgroundColor:[UIColor clearColor]];
        
        [cell.contentView addSubview:titleLabel];
        [cell.contentView addSubview:dataLabel];
    }
    
    // Cannot select these cells
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // Access labels in the cell using the tag # 
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *dataLabel = (UILabel *)[cell viewWithTag:2];
    
    // Display the data in the table
    [titleLabel setText:[self.rowTitleArray objectAtIndex:indexPath.row]];
    if (self.rowDataArray.count != 0) {
        NSLog(@"Indexpath: we have: %@",[self.rowDataArray objectAtIndex:indexPath.row]); //BREAKING - are "" objects
        [dataLabel setText:[self.rowDataArray objectAtIndex:indexPath.row]];
    }
    return cell;
}
@end