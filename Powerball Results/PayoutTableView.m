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

int headerHeight = 25;
int imageIndent = 0;
int cellHeight = 20;
int imageWidth = 16;
int imageHeight = 16;

UIImage *matchBall;
UIImage *specialMatchBall;
int ballIndent = 3;

bool needData = YES;

-(id) init
{
    NSLog(@"Init PAYOUT TABLE VIEW");
    if (! (self = [super init])) {
        return nil;
    }
    [self.tableView setBackgroundColor:[UIColor blackColor]]; //should be in init method
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; //should be in init method

    matchBall = [UIImage imageNamed:@"whiteball.png"];
    specialMatchBall = [UIImage imageNamed:@"redball.png"];
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if((!self.payouts && needData) || [self.payouts count]==0) {
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
    [query orderByDescending:@"PBMatch"];
    [query orderByDescending:@"Matches"];
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
                currentPayout.odds = [object objectForKey:@"Odds"];
                
                if (![currentPayout.payout isEqualToString:@"$0"]) {
                    [localPayouts insertObject:currentPayout atIndex:counter]; 
                    NSLog(@"Added %@",currentPayout.payout);
                    counter ++;
                }
                //NSLog(@"Matching %d - on %@ matches and %@ special matches, one wins: %@", counter, currentPayout.matches, currentPayout.specialMatches, currentPayout.payout);
            }
            NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"specialMatches" ascending:NO];
            [localPayouts sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
            highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"matches" ascending:NO];
            [localPayouts sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
            self.payouts = localPayouts;//copy:(localPayouts)];//= localPayouts;
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
        cell = [[PayoutCell alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width,44)]; //initWithFrame:
    }
    Payout *currentPayout = [self.payouts objectAtIndex:indexPath.row]; 
    
    if (!cell.matchedBallsView) {
        CGRect matchedBallsImageFrame = CGRectMake(imageIndent, 0, (imageWidth * 6), matchBall.size.height); 
        cell.matchedBallsView = [[UIImageView alloc] initWithFrame:matchedBallsImageFrame];
    }
    int x=0;
    for (x=1; x<=[currentPayout.matches intValue]; x++) {
        CGRect rect = CGRectMake(imageIndent + (x-1) * (imageWidth + ballIndent), 0, imageWidth, imageHeight);
        UIImageView *ballImage = [[UIImageView alloc] initWithFrame:rect];
        ballImage.image = matchBall;
        [cell.matchedBallsView addSubview:ballImage];  
    }
    for (int z=1; z<=[currentPayout.specialMatches intValue]; z++) {
        CGRect rect = CGRectMake(imageIndent + (z-2+x) * (imageWidth + ballIndent), 0, imageWidth, imageHeight);
        UIImageView *ballImage = [[UIImageView alloc] initWithFrame:rect];
        ballImage.image = specialMatchBall;
        [cell.matchedBallsView addSubview:ballImage];  
    }
    cell.prize.text = currentPayout.payout;
    cell.prize.textColor = [UIColor whiteColor];
    cell.odds.text = currentPayout.odds;
    cell.odds.textColor = [UIColor redColor];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(headerHeight,0,self.tableView.frame.size.width-40,20)];
    
    UILabel *headerMatches = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, headerView.frame.size.width, headerView.frame.size.height)];
    headerMatches.textColor = [UIColor whiteColor];
    headerMatches.font = [UIFont boldSystemFontOfSize:16];
    headerMatches.textAlignment = UITextAlignmentLeft;
    headerMatches.text = @"Matches";
    headerMatches.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerMatches];
    
    UILabel *headerPayout = [[UILabel alloc] initWithFrame:CGRectMake(123+imageIndent, 2, headerView.frame.size.width, headerView.frame.size.height)];
    headerPayout.textColor = [UIColor whiteColor];
    headerPayout.font = [UIFont boldSystemFontOfSize:16];
    headerPayout.textAlignment = UITextAlignmentLeft;
    headerPayout.text = @"Payout";
    headerPayout.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerPayout];
    
    UILabel *headerOdds = [[UILabel alloc] initWithFrame:CGRectMake(256, 2, headerView.frame.size.width, headerView.frame.size.height)];
    headerOdds.textColor = [UIColor redColor];
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
