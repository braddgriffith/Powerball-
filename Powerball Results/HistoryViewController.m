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

bool inserting;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
//    if (self.selections > 0) {
//        self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    }
    
    NSLog(@"History has %d selections", [self.selections count]);
    inserting = NO;
    
    if(self.selections.count > [self.tableView numberOfRowsInSection:0]) {
        inserting = YES;
        [self insertRow]; 
        inserting = NO;
        [self performSelector:@selector(rowsFade:) withObject:nil afterDelay:1.0];
    } 
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [self.spinner removeFromSuperview];
    self.spinner = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [self.selections count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{        
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    
    int nodeCount = [self.selections count];
    int row = indexPath.row;
    float shade = (float)(nodeCount-row)/(float)nodeCount;

    if (inserting) {
        cell.backgroundViewForColor.backgroundColor = [UIColor colorWithRed:100.0/255.0 green:190.0/255.0 blue:10.0/255.0 alpha:1];
    } else {
        cell.backgroundViewForColor.backgroundColor = [UIColor colorWithRed:100.0/255.0 green:190.0/255.0 blue:10.0/255.0 alpha:(shade == 0 ? 1.0 :shade)];
    }
    
//    UIView backgroundCircle = [UIView alloc] initWithFrame:(CGRect)
//    [backgroundCircle 
//    [cell addSubview:backgroundCircle];
    
    Selection *selection = [selections objectAtIndex:indexPath.row];
    if (selection.selectionPowerball) {
        cell.powerballLabel.text = [selection.selectionPowerball stringValue];//stringValue];
    } else {
        cell.powerballLabel.text = @"(?)";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //create a date formatter
    [dateFormatter setDateFormat:@"M/d/yyyy"];
    cell.dateLabel.text = [dateFormatter stringFromDate:selection.drawingDate]; 
    
    NSString *selectionList = [[selection.selectionOne stringValue] stringByAppendingString:@"-"];
    selectionList = [selectionList stringByAppendingString:[selection.selectionTwo stringValue]];
    selectionList = [selectionList stringByAppendingString:@"-"];
    selectionList = [selectionList stringByAppendingString:[selection.selectionThree stringValue]];
    selectionList = [selectionList stringByAppendingString:@"-"];
    selectionList = [selectionList stringByAppendingString:[selection.selectionFour stringValue]];
    selectionList = [selectionList stringByAppendingString:@"-"];
    selectionList = [selectionList stringByAppendingString:[selection.selectionFive stringValue]];
    
    cell.numbersLabel.text = selectionList;

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
    //[query whereKey:@"userID" equalTo:selection.userID];
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
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)rowsFade:(id)obj
{
    int allRows = [self.tableView numberOfRowsInSection:0];
    int allRowIndex = 0;
    NSMutableArray *allIndexPaths = [[NSMutableArray alloc] init];
    for (allRowIndex=0; allRowIndex<allRows; allRowIndex++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:allRowIndex inSection:0];
        [allIndexPaths insertObject:indexPath atIndex:allRowIndex];
    }
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:allIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    allIndexPaths = nil;
}

-(void)insertRow
{
    int rows = [self.selections count] - [self.tableView numberOfRowsInSection:0];
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

@end
