//
//  NumberGeneratorViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NumberGeneratorViewController.h"

@interface NumberGeneratorViewController ()
@end

@implementation NumberGeneratorViewController

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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}
*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
