//
//  FeedbackViewController.m
//  Ourstar2
//
//  Created by Brad Grifffith on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedbackViewController.h"

@implementation FeedbackViewController

@synthesize appLink;
@synthesize emailBody;
@synthesize emailSubject;
@synthesize supportEmail;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
}

- (IBAction)rateGame 
{
    //GUESS [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=ourstar-san-francisco&id=508993109"]]; 
    //REAL PREVIOUS [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=409954448"]];
    if(appLink == nil) {
        //PFQuery *query = [PFQuery queryWithClassName:@"LocationsVariables"];
        //PFObject *appVariables = [query getObjectWithId:@"2hpLMmZYpI"]; 
        //appLink = [appVariables objectForKey:@"appLink"];
    }
    if(appLink != nil) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appLink]];
    }
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
        emailBody = @"Hey, Here's a feature I need...";
        emailSubject = @"Ideas";
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


@end
