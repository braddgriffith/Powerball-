//
//  HudView.h
//  Powerball Results
//
//  Created by Brad Grifffith on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

+ (void)hudInView:(UIView *)view text:(NSString*)text lineTwo:(NSString *)lineTwo animated:(BOOL)animated;

@end
