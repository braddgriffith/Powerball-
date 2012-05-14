//
//  FeedbackViewController.m
//  Ourstar2
//
//  Created by Brad Grifffith on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedbackViewController.h"
#import <Parse/Parse.h>

@implementation FeedbackViewController//: UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate> 

@synthesize appLink;
@synthesize emailBody;
@synthesize emailSubject;
@synthesize supportEmail;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)rateGame 
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=517545261"]];
    //@"https://userpub.itunes.apple.com/WebObjects/MZUserPublishing.woa/wa/addUserReview?id=517545261&type=Purple+Software"]]; - does triple redirect - works on non iOS devices
}

- (IBAction)sendEmail 
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    if(emailBody == nil) {
        //PFQuery *query = [PFQuery queryWithClassName:@"LocationsVariables"];
        //PFObject *appVariables = [query getObjectWithId:@"2hpLMmZYpI"]; 
        //emailBody = [appVariables objectForKey:@"emailBody"];
        //emailSubject = [appVariables objectForKey:@"emailSubject"];
        //supportEmail = [appVariables objectForKey:@"supportEmail"];
        emailBody = @"Hey,";
        emailSubject = @"I've got some ideas...";
        supportEmail = @"pluspowerball@gmail.com";
    }
    if(emailBody != nil) {
        NSArray *toRecipients = [NSArray arrayWithObjects:supportEmail, nil];
        [picker setToRecipients:toRecipients];
        [picker setSubject:emailSubject];
        [picker setMessageBody:emailBody isHTML:NO];
        [self presentModalViewController:picker animated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

//- (void)loginViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user 
//{
//    [self dismissModalViewControllerAnimated:YES];
//}
//
//- (void)loginViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
//{
//    [self dismissModalViewControllerAnimated:YES];
//}
//
//- (void)signUpViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user 
//{
//    [self dismissModalViewControllerAnimated:YES];
//}
//
//- (void)signUpViewControllerDidCancelLogin:(PFLogInViewController *)logInController
//{
//    [self dismissModalViewControllerAnimated:YES];
//}
@end
