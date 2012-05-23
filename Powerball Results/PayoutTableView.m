//
//  PayoutTableView.m
//  Powerball Results
//
//  Created by Brad Grifffith on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PayoutTableView.h"
#import "PayoutCell.h"
#import "Payout.h"
#import <Parse/Parse.h>

@implementation PayoutTableView

@synthesize payouts, payout;
@synthesize tableView;

int headerHeight = 20;
int imageIndent = 2;
int cellHeight = 20;
//int imageWidth = 30;
//int imageHeight = 30;

UIImage *matchBall;
UIImage *specialMatchBall;
int ballIndent = 5;

bool needData = YES;

-(id) initWithCoder:(NSCoder*)aDecoder {
    NSLog(@"DECODING PAYOUT TABLE VIEW");
    
    if (! (self = [super init])) {
        return nil;
    }
    [self getPayoutData];
    matchBall = [UIImage imageNamed:@"whiteball.png"];
    specialMatchBall = [UIImage imageNamed:@"redball.png"];
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    
    if(!self.payouts && needData) {
        needData = NO;
        [self getPayoutData];
        return 0;
    } 
    int count = [self.payouts count];
    return count;
}

- (void)getPayoutData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Payouts"];
    [query orderByDescending:@"Matches"];
    [query orderByDescending:@"PBMatch"];
    query.limit = 100;
    
    NSMutableArray *localPayouts = [[NSMutableArray alloc] init]; 
    if (!self.payouts) {
        self.payouts = [[NSMutableArray alloc] init];
    }
    
    __block int counter = 0;
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Sent query.");
        if (!error) {
            NSLog(@"Successfully retrieved %d PAYOUTS.", objects.count); 
            for (PFObject *object in objects) {  
                Payout *currentPayout = [[Payout alloc] init];
                
                currentPayout.matches = [object objectForKey:@"Matches"];
                currentPayout.specialMatches = [object objectForKey:@"PBMatch"];
                currentPayout.payout = [object objectForKey:@"Payout"];
                
                [localPayouts insertObject:currentPayout atIndex:counter];                
                counter ++;
                NSLog(@"Matching %d - on %@ matches and %@ special matches, one wins: %@", counter, currentPayout.matches, currentPayout.specialMatches, currentPayout.payout);
            }
            self.payouts = localPayouts;
            [self.tableView reloadData];
        } else {
            UIAlertView * alert = [[UIAlertView alloc] 
                                   initWithTitle:@"Alert" 
                                   message:@"Couldn't connect to the network. Please try again later." 
                                   delegate:self cancelButtonTitle:@"Hide" 
                                   otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];            
        }
    }];
    query = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"PayoutCell";
    
    PayoutCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PayoutCell alloc] initWithFrame:CGRectMake(0,0,320,44)]; //initWithFrame:(CGRectZero)];
//        NSLog(@"Cell height:%@", cell.frame.size.height);
//        NSLog(@"Cell width:%@", cell.frame.size.width);
    }
    Payout *currentPayout = [self.payouts objectAtIndex:indexPath.row]; 
    
    if (!cell.matchedBallsView) {
        CGRect matchedBallsImageFrame = CGRectMake(imageIndent, 0, (matchBall.size.width * 6), matchBall.size.height); 
        cell.matchedBallsView = [[UIImageView alloc] initWithFrame:matchedBallsImageFrame];
    }
    for (int x=1; x<=[currentPayout.matches intValue]; x++) {
        CGRect rect = CGRectMake(imageIndent + (x-1) * (matchBall.size.width + ballIndent), 0, matchBall.size.width, matchBall.size.height);
        UIImageView *ballImage = [[UIImageView alloc] initWithFrame:rect];
        [cell.matchedBallsView addSubview:ballImage];  
    }
    for (int z=1; z<=[currentPayout.specialMatches intValue]; z++) {
        CGRect rect = CGRectMake(imageIndent + (z-1) * (matchBall.size.width + ballIndent), 0, matchBall.size.width, matchBall.size.height);
        UIImageView *ballImage = [[UIImageView alloc] initWithFrame:rect];
        [cell.matchedBallsView addSubview:ballImage];  
    }
    cell.prize.text = currentPayout.payout;
    cell.odds.text = currentPayout.odds;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(headerHeight,0,self.tableView.frame.size.width-40,20)];
    
    UILabel *headerMatches = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    headerMatches.textColor = [UIColor whiteColor];
    headerMatches.font = [UIFont boldSystemFontOfSize:16];
    headerMatches.textAlignment = UITextAlignmentLeft;
    headerMatches.text = @"Matches";
    headerMatches.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerMatches];
    
    UILabel *headerPayout = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, headerView.frame.size.width, headerView.frame.size.height)];
    headerPayout.textColor = [UIColor whiteColor];
    headerPayout.font = [UIFont boldSystemFontOfSize:16];
    headerPayout.textAlignment = UITextAlignmentLeft;
    headerPayout.text = @"Payout";
    headerPayout.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerPayout];
    
    UILabel *headerOdds = [[UILabel alloc] initWithFrame:CGRectMake(240, 0, headerView.frame.size.width, headerView.frame.size.height)];
    headerOdds.textColor = [UIColor whiteColor];
    headerOdds.font = [UIFont boldSystemFontOfSize:16];
    headerOdds.textAlignment = UITextAlignmentLeft;
    headerOdds.text = @"Odds";
    headerOdds.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerOdds];
    
    return headerView;
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{    
    return headerHeight;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath:(NSInteger)section 
{    
    return cellHeight;
}
@end
