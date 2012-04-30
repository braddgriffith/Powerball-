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
//    PFLogInViewController *login = [[PFLogInViewController alloc] init];
//    login.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsFacebook;
//    
//    login.delegate = self;
//    login.signUpController.delegate = self;
//    
//    [self presentModalViewController:login animated:YES];
}

- (IBAction)rateGame 
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://userpub.itunes.apple.com/WebObjects/MZUserPublishing.woa/wa/addUserReview?id=517545261&type=Purple+Software"]]; //http://itunes.apple.com/us/app/powerball+/id517545261?ls=1&mt=8
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/powerball+/id517545261?ls=1&mt=8"]];// - gets us to the App, not the reviews

//REAL PREVIOUS [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=409954448"]];
//    if(appLink == nil) {
//        //PFQuery *query = [PFQuery queryWithClassName:@"LocationsVariables"];
//        //PFObject *appVariables = [query getObjectWithId:@"2hpLMmZYpI"]; 
//        //appLink = [appVariables objectForKey:@"appLink"];
//    }
//    if(appLink != nil) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appLink]];
//    }
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
