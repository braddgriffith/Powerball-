//
//  HistoryViewController.m
//  Powerball Results
//
//  Created by Brad Grifffith on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"
#import <Parse/Parse.h>

@interface HistoryViewController ()

@end

@implementation HistoryViewController

@synthesize spinner;
@synthesize selections;
@synthesize addSelection;

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    if (self.selections > 0) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    
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
    
    return count;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    HistoryCell *selectionCell = (HistoryCell *)cell;
    Selection *selection = [selections objectAtIndex:indexPath.row];
    
    if (selection.selectionPowerball) {
        selectionCell.powerballLabel.text = [selection.selectionPowerball stringValue];//stringValue];
    } else {
        selectionCell.powerballLabel.text = @"(?)";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //create a date formatter
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    selectionCell.dateLabel.text = [dateFormatter stringFromDate:selection.drawingDate]; 
    
    NSString *selectionList = [[selection.selectionOne stringValue] stringByAppendingString:@"-"];
    selectionList = [selectionList stringByAppendingString:[selection.selectionTwo stringValue]];
    selectionList = [selectionList stringByAppendingString:@"-"];
    selectionList = [selectionList stringByAppendingString:[selection.selectionThree stringValue]];
    selectionList = [selectionList stringByAppendingString:@"-"];
    selectionList = [selectionList stringByAppendingString:[selection.selectionFour stringValue]];
    selectionList = [selectionList stringByAppendingString:@"-"];
    selectionList = [selectionList stringByAppendingString:[selection.selectionFive stringValue]];
    
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
    //cell.contentView.backgroundColor = [UIColor clearColor];
    int row = indexPath.row;
    float shade = (nodeCount-row)/nodeCount;
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    backgroundView.backgroundColor = [UIColor colorWithRed:100.0/255.0 green:190.0/255.0 blue:10.0/255.0 alpha:shade];
    [cell.backgroundView addSubview:backgroundView];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Selection *selection = [self.selections objectAtIndex:indexPath.row];
    PFQuery *query = [PFQuery queryWithClassName:@"Selections"];
    [query whereKey:@"userID" equalTo:selection.userID];
    [query whereKey:@"addedDate" equalTo:selection.userChosenDate];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"The getObject request failed.");
        } else {
            NSLog(@"Successfully retrieved the object.");
            PFObject *deletedObject = [PFObject objectWithClassName:@"DeletedSelections"];
            [deletedObject setObject:object.objectId forKey:@"selectionsObjectID"];
            [deletedObject saveEventually];
        }
    }];
    
    [selections removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
