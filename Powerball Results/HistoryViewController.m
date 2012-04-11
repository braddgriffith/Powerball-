//
//  HistoryViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"

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
    self.spinner.center = CGPointMake(CGRectGetMidX(self.tableView.bounds) + 0.5f, CGRectGetMidY(self.tableView.bounds) + 0.5f);
    [self.spinner setColor:[UIColor blackColor]];
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
    
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    NSLog(@"History has %d selections", [self.selections count]);
    
    if(self.selections.count > [self.tableView numberOfRowsInSection:0]) {
        [self insertRow]; 
    }
}

-(void)insertRow
{
    int rows = self.selections.count - [self.tableView numberOfRowsInSection:0];
    int newRowIndex = 0;
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (newRowIndex=0; newRowIndex<rows; newRowIndex++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
        [indexPaths insertObject:indexPath atIndex:newRowIndex];
    }
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    indexPaths = nil;
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
    HistoryCell *selectionCell = (HistoryCell *)cell;
    Selection *selection = [selections objectAtIndex:indexPath.row];
    
    if ([selection.selectionPowerball length] > 0) {
        selectionCell.powerballLabel.text = selection.selectionPowerball;
    } else {
        selectionCell.powerballLabel.text = @"(?)";
    }
    selectionCell.dateLabel.text = selection.drawingDate; 
    NSString *selectionList = [selection.selectionOne stringByAppendingString:@","];
    selectionList = [selectionList stringByAppendingString:selection.selectionTwo];
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
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [selections removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
