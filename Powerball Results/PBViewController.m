//
//  ViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PBViewController.h"

@interface PBViewController ()

@end

@implementation PBViewController
@synthesize webView;
@synthesize spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadResults];
    
    self.webView.delegate = self;
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner removeFromSuperview];
    self.spinner = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView * alert = [[UIAlertView alloc] 
                           initWithTitle:@"Alert" 
                           message:@"Couldn't connect to the network. Please try again in one minute." 
                           delegate:self cancelButtonTitle:@"Hide" 
                           otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];  
    self.spinner = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)loadResults
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(CGRectGetMidX(self.webView.bounds), CGRectGetMidY(self.webView.bounds));
    [self.spinner setColor:[UIColor blackColor]];
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.coloradolottery.com/mobile/winning-numbers/powerball-past/"]]];
}

-(IBAction)refresh:(id)sender
{
    [self loadResults];
}

@end
