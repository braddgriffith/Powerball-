//
//  HistoryViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"
#import "SelectionCell.h"

#define kCustomRowCount 7

@interface HistoryViewController ()

@end

@implementation HistoryViewController

@synthesize spinner;
@synthesize selections;
@synthesize addSelection;

- (void)viewWillAppear:(BOOL)animated
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(320/2, 200);
    [self.spinner setColor:[UIColor blackColor]];
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
    
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.selections = [defaults objectForKey:@"selections"];

    NSLog(@"History has %d locations", [self.selections count]);
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.spinner removeFromSuperview];
    self.spinner = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [self.selections count];
    
    if (count == 0)
	{
        return kCustomRowCount;
    }
    return count;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    SelectionCell *selectionCell = (SelectionCell *)cell;
    Selection *selection = [selections objectAtIndex:indexPath.row];
    
    if ([selection.selectionPowerball length] > 0) {
        selectionCell.powerballLabel.text = selection.selectionPowerball;
    } else {
        selectionCell.powerballLabel.text = @"(?)";
    }
    selectionCell.dateLabel.text = selection.drawingDate; 
    NSString *selectionList = [selection.selectionOne stringByAppendingString:selection.selectionTwo];
    selectionList = [selectionList stringByAppendingString:@","];
    selectionList = [selectionList stringByAppendingString:selection.selectionThree];
    selectionList = [selectionList stringByAppendingString:@","];
    selectionList = [selectionList stringByAppendingString:selection.selectionFour];
    selectionList = [selectionList stringByAppendingString:@","];
    selectionList = [selectionList stringByAppendingString:selection.selectionFive];
    
    selectionCell.numbersLabel.text = selectionList;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectionCell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    int nodeCount = [self.selections count];
	
	if (nodeCount == 0) // If there's no data, add loading placeholder in the cell -- removed (&& indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
		{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:PlaceholderCellIdentifier];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
		cell.detailTextLabel.text = @"Loading…";
		
		return cell;
    } 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Selection"];
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
    return cell;
}

@end
