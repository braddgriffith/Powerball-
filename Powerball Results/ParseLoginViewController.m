//
//  ParseLoginViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParseLoginViewController.h"

@implementation ParseLoginViewController

int frameYstart = 15;
int frameIndent = 18;
int frameHeight = 64;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.logInView.backgroundColor = [UIColor blackColor];
    
    //Override the logo display to display text
    CGRect frame = CGRectMake(frameIndent,frameYstart,self.view.frame.size.width-2*frameIndent,frameHeight);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.text = @"Join via Facebook in two taps!";// enter your username/password or tap sign-up. ";
    [self.logInView addSubview:label]; //add the tableView
    
    self.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small@2x.png"]];
    
    self.logInView.usernameField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.logInView.passwordField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    self.logInView.usernameField.textColor = [UIColor blackColor];
    self.logInView.passwordField.textColor = [UIColor blackColor];
    
    self.logInView.usernameField.font = [UIFont fontWithName:@"System" size: 14.0];
    self.logInView.passwordField.font = [UIFont fontWithName:@"System" size: 14.0];
    
    self.logInView.usernameField.borderStyle = UITextBorderStyleRoundedRect;
    self.logInView.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.logInView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Stars02.png"]];
    
    self.signUpController.signUpView.backgroundColor = [UIColor blackColor];
    
    //Override the logo display to display text//Override the logo display to display text - as above
    self.signUpController.signUpView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small@2x.png"]];
    
    self.signUpController.signUpView.usernameField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.signUpController.signUpView.passwordField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.signUpController.signUpView.emailField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    self.signUpController.signUpView.usernameField.textColor = [UIColor blackColor];
    self.signUpController.signUpView.passwordField.textColor = [UIColor blackColor];
    self.signUpController.signUpView.emailField.textColor = [UIColor blackColor];
    
    self.signUpController.signUpView.usernameField.font = [UIFont fontWithName:@"System" size: 14.0];
    self.signUpController.signUpView.passwordField.font = [UIFont fontWithName:@"System" size: 14.0];
    self.signUpController.signUpView.emailField.font = [UIFont fontWithName:@"System" size: 14.0];  
    
    self.signUpController.signUpView.usernameField.borderStyle = UITextBorderStyleRoundedRect;
    self.signUpController.signUpView.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.signUpController.signUpView.emailField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.signUpController.signUpView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Stars02.png"]];
    
    self.signUpController.fields = PFLogInFieldsUsernameAndPassword
    | PFLogInFieldsFacebook
    | PFLogInFieldsTwitter
    | PFLogInFieldsSignUpButton
    | PFLogInFieldsPasswordForgotten;
    
    //self.logInView.passwordForgottenButton.accessibilityLabel = @"Please enter the email address for your account.";
    //self.logInView.passwordResetFailed.accessibilityLabel = @"This email address is not registered.";
}



@end
