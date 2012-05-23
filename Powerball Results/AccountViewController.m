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

@synthesize headerView, headerImageView, headerNameLabel;
@synthesize rowTitleArray, rowDataArray, imageData;
@synthesize appDelegate;
@synthesize tableViewForAccount;
@synthesize permissions;

@synthesize logoutButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"ViewDidLoad");
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    permissions = [NSArray arrayWithObjects:@"email", @"user_location", @"user_about_me", nil]; //"user_about_me" 
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
    [navigationBar sizeToFit]; 
    navigationBar.barStyle = UIBarStyleBlackTranslucent;
    UINavigationItem *titleItem = [[UINavigationItem alloc] initWithTitle:@"Account"];
    
    CGRect frame = CGRectMake(0, navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - navigationBar.frame.size.height);
    tableViewForAccount = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    [self.tableViewForAccount setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    tableViewForAccount.dataSource = self;
    tableViewForAccount.delegate = self;
    
    logoutButton = [[UIBarButtonItem alloc] 
                    initWithTitle:@"Logout" 
                    style:UIBarButtonItemStyleBordered 
                    target:self 
                    action:@selector(logoutButtonTouchHandler:)];
    
    titleItem.leftBarButtonItem = logoutButton;
    [navigationBar setItems:[NSArray arrayWithObject:titleItem]];
    
    [self.view addSubview:tableViewForAccount]; //add the tableView
    [self.view addSubview:navigationBar]; //add the bar
}

- (void)viewWillAppear:(BOOL)animated //Creates and instatiates ParseLoginViewController if appdelegate.user.email == ""
{
    NSLog(@"viewWillAppear appDelegate.user.email = %@", appDelegate.user.email);
    
    self.rowTitleArray = [NSMutableArray arrayWithObjects:@"Location", @"First Name", @"Last Name", @"Email", @"Username", nil]; 
    self.rowDataArray = [NSMutableArray arrayWithObjects:appDelegate.user.location, appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.username, nil];
    
    if ([appDelegate.user.email isEqualToString:@""] || appDelegate.user.email == nil) {
        [self displayParseLoginVC];
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
    NSLog(@"HEY WE Logged IN!!!");
    NSLog(@"User: %@",user);
    
    if (![PFFacebookUtils isLinkedWithUser:user]) { //if account not linked w FB, use PFuser
        NSLog(@"Got to PFuser");
        appDelegate.user.location = [user objectForKey:@"location"]; //just location from PFUser
        appDelegate.user.first_name = [user objectForKey:@"first_name"]; 
        appDelegate.user.last_name = [user objectForKey:@"last_name"]; //    
        appDelegate.user.email = [user objectForKey:@"email"];
        appDelegate.user.username = [user objectForKey:@"username"];
    } else {  //else, go ask FB for data
        [[PFFacebookUtils facebook] requestWithGraphPath:@"me?fields=first_name,last_name,email,location,username" //REQUEST_WITH_GRAPH_PATH
                                             andDelegate:self];
        NSLog(@"Got to FB");
    }
    self.rowDataArray = [NSMutableArray arrayWithObjects:appDelegate.user.location, appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.username, nil];
    [tableViewForAccount reloadData]; //Reload the data
    [self dismissModalViewControllerAnimated:YES];
}

-(void)request:(PF_FBRequest *)request didLoad:(id)result //IF WE GET DATA BACK FROM FB, SAVE TO NETWORK
{       
    NSLog(@"didLoad - Facebook request %@ loaded", result);
    if ([[request url] rangeOfString:@"/me"].location != NSNotFound)
    {
        appDelegate.user.first_name = [result objectForKey:@"first_name"];
        appDelegate.user.last_name = [result objectForKey:@"last_name"];
        appDelegate.user.email = [result objectForKey:@"email"];
        appDelegate.user.location = [[result objectForKey:@"location"]objectForKey:@"name"];
        appDelegate.user.username = [result objectForKey:@"username"];
        
        NSLog(@"appDelegate id = %@, first = %@, last = %@, email = %@, location = %@",[result objectForKey:@"id"], appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.location);
        NSLog(@"appDelegate first = %@, last = %@, email = %@, location = %@", appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.location);
        
        [[PFUser currentUser] setObject:appDelegate.user.first_name forKey:@"first_name"];
        [[PFUser currentUser] setObject:appDelegate.user.last_name forKey:@"last_name"];
        [[PFUser currentUser] setObject:appDelegate.user.email forKey:@"email"];
        [[PFUser currentUser] setObject:appDelegate.user.location forKey:@"location"];
        [[PFUser currentUser] setObject:appDelegate.user.username forKey:@"username"];
        [[PFUser currentUser] saveInBackground];
    }
    self.rowDataArray = [NSMutableArray arrayWithObjects:appDelegate.user.location, appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.username, nil];
    [self.tableViewForAccount reloadData];
}

- (void)viewDidUnload
{
    NSLog(@"ViewDidUnload");
}

- (void)logInViewControllerDidCancelLogIn:(ParseLoginViewController *)logInController {
    NSLog(@"HEY WE cancelled Log in!!!");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    NSLog(@"We signed up!");
    
    appDelegate.user.email = [user objectForKey:@"email"];
    [self dismissModalViewControllerAnimated:YES];
    
    self.rowDataArray = [NSMutableArray arrayWithObjects: @"", @"", @"", appDelegate.user.email, @"", nil]; //not really right - need a loadData call or something
    [tableViewForAccount reloadData]; //Reload the data
}

- (void)signUpViewControllerDidCancelLogIn:(PFSignUpViewController *)signUpController {
    NSLog(@"HEY WE cancelled sign up!!!");
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
        
        self.rowDataArray = [NSMutableArray arrayWithObjects:appDelegate.user.location, appDelegate.user.first_name, appDelegate.user.last_name, appDelegate.user.email, appDelegate.user.username, nil];
        
        [self.tableViewForAccount reloadData];
        
        logoutButton.title = @"Login";
        
        NSLog(@"We logged out!!!");
    } else {
        [self displayParseLoginVC];
        logoutButton.title = @"Logout";
    }
    NSLog(@"logout appDelegate.user.email = %@", appDelegate.user.email);
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
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
        [titleLabel setTag:1]; // We use the tag to set it later
        [titleLabel setTextAlignment:UITextAlignmentRight];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        
        UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, 165, 44)];
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