//
//  FeedbackViewController.h
//  Ourstar2
//
//  Created by Brad Grifffith on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FeedbackViewController : UIViewController
<MFMailComposeViewControllerDelegate> 

@property (nonatomic, strong) NSString *appLink;
@property (nonatomic, strong) NSString *emailBody;
@property (nonatomic, strong) NSString *emailSubject;
@property (nonatomic, strong) NSString *supportEmail;

- (IBAction)rateGame;
- (IBAction)sendEmail;

@end
