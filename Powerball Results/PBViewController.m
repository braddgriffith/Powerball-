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

@synthesize refreshButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; //black
    self.webView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; //black
    [self.webView setOpaque:NO];
    [self.view addSubview:self.webView];
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
    [navigationBar sizeToFit]; 
    navigationBar.barStyle = UIBarStyleBlackOpaque;
    UINavigationItem *titleItem = [[UINavigationItem alloc] initWithTitle:@"Results"];
    
    refreshButton = [[UIBarButtonItem alloc] 
                    initWithTitle:@"Refresh" 
                    style:UIBarButtonItemStyleBordered 
                    target:self 
                    action:@selector(refresh:)];
    
    titleItem.rightBarButtonItem = refreshButton;
    [navigationBar setItems:[NSArray arrayWithObject:titleItem]];
    
    [self.view addSubview:navigationBar];
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
                           message:@"Couldn't connect to the network. Please press refresh to try again in one minute." 
                           delegate:self cancelButtonTitle:@"Hide" 
                           otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show]; 
    [self.spinner removeFromSuperview];
    self.spinner = nil;
}

- (void)loadResults
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(CGRectGetMidX(self.webView.bounds), CGRectGetMidY(self.webView.bounds));
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.coloradolottery.com/mobile/winning-numbers/powerball-past/"]]];
}

-(IBAction)refresh:(id)sender
{
    [self loadResults];
    NSLog(@"Refreshed");
}

@end
