//
//  NumberGeneratorViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeneratorViewController.h"
#import "Selection.h"
#import "SelectorViewController.h"
#import "AppDelegate.h"

@interface GeneratorViewController ()
@end

@implementation GeneratorViewController

@synthesize numberOne;
@synthesize numberTwo;
@synthesize numberThree;
@synthesize numberFour;
@synthesize numberFive;
@synthesize powerball;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    
    [self refresh:nil];
}

-(IBAction)save:(id)sender
{
    Selection *randomSelection = [[Selection alloc] init];
    randomSelection.selectionOne = numberOne.text;
    randomSelection.selectionTwo = numberTwo.text;
    randomSelection.selectionThree = numberThree.text;
    randomSelection.selectionFour = numberFour.text;
    randomSelection.selectionFive = numberFive.text;
    randomSelection.selectionPowerball  = powerball.text;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.selection = randomSelection;
    [self sendNotification];
}


- (void)sendNotification
{
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"RandomSelectionMadeNotification" 
     object:self];
}

-(IBAction)refresh:(id)sender
{
    NSMutableArray *currentNumbers = [[NSMutableArray alloc] init];
    
    NSInteger a = [self generateRandom];
    self.numberOne.text = [NSString stringWithFormat:@"%d", a];
    NSNumber *anumber = [NSNumber numberWithInteger:a];
    [currentNumbers addObject:anumber];
    
    NSInteger b = [self generateRandom];
    while ([currentNumbers containsObject:[NSNumber numberWithInt:b]]) {
        b = [self generateRandom];
    }
    self.numberTwo.text = [NSString stringWithFormat:@"%d", b];
    anumber = [NSNumber numberWithInteger:b];
    [currentNumbers addObject:anumber];
    
    NSInteger c = [self generateRandom];
    while ([currentNumbers containsObject:[NSNumber numberWithInt:c]]) {
        c = [self generateRandom];
    }
    self.numberThree.text = [NSString stringWithFormat:@"%d", c];
    anumber = [NSNumber numberWithInteger:c];
    [currentNumbers addObject:anumber];
    
    NSInteger d = [self generateRandom];
    while ([currentNumbers containsObject:[NSNumber numberWithInt:d]]) {
        d = [self generateRandom];
    }
    self.numberFour.text = [NSString stringWithFormat:@"%d", d];
    anumber = [NSNumber numberWithInteger:d];
    [currentNumbers addObject:anumber];
    
    NSInteger e = [self generateRandom];
    while ([currentNumbers containsObject:[NSNumber numberWithInt:e]]) {
        e =[self generateRandom];
    }
    self.numberFive.text = [NSString stringWithFormat:@"%d", e];
    anumber = [NSNumber numberWithInteger:e];
    [currentNumbers addObject:anumber];
    
    NSInteger f = arc4random()%35 +1;
    self.powerball.text = [NSString stringWithFormat:@"%d", f];
    
    currentNumbers = nil;
    
    [self.tableView reloadData];
}

- (NSInteger)generateRandom
{
    return arc4random()%59+1;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

@end
