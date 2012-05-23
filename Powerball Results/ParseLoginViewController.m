//
//  ParseLoginViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParseLoginViewController.h"

@implementation ParseLoginViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.logInView.backgroundColor = [UIColor blackColor];
    
    self.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small@2x.png"]];
    
    self.logInView.usernameField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.logInView.passwordField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    self.logInView.usernameField.textColor = [UIColor blackColor];
    self.logInView.passwordField.textColor = [UIColor blackColor];
    
    self.logInView.usernameField.font = [UIFont fontWithName:@"System" size: 14.0];
    self.logInView.passwordField.font = [UIFont fontWithName:@"System" size: 14.0];
    
    self.logInView.usernameField.borderStyle = UITextBorderStyleRoundedRect;
    self.logInView.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.signUpController.signUpView.backgroundColor = [UIColor blackColor];
    
    self.signUpController.signUpView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small@2x.png"]];
    
    self.signUpController.signUpView.usernameField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    self.signUpController.signUpView.passwordField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    self.signUpController.signUpView.emailField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    
    self.signUpController.signUpView.usernameField.textColor = [UIColor blackColor];
    self.signUpController.signUpView.passwordField.textColor = [UIColor blackColor];
    self.signUpController.signUpView.emailField.textColor = [UIColor blackColor];
    
    self.signUpController.signUpView.usernameField.font = [UIFont fontWithName:@"System" size: 14.0];
    self.signUpController.signUpView.passwordField.font = [UIFont fontWithName:@"System" size: 14.0];
    self.signUpController.signUpView.emailField.font = [UIFont fontWithName:@"System" size: 14.0];  
    
    self.signUpController.signUpView.usernameField.borderStyle = UITextBorderStyleRoundedRect;
    self.signUpController.signUpView.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.signUpController.signUpView.emailField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.signUpController.fields = PFLogInFieldsUsernameAndPassword
    | PFLogInFieldsFacebook
    | PFLogInFieldsTwitter
    | PFLogInFieldsSignUpButton
    | PFLogInFieldsPasswordForgotten;
    
    //self.logInView.passwordForgottenButton.accessibilityLabel = @"Please enter the email address for your account.";
    //self.logInView.passwordResetFailed.accessibilityLabel = @"This email address is not registered.";
}



@end
