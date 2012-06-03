//
//  IntroAnimation.h
//  Powerball Results
//
//  Created by Brad Grifffith on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroAnimation : UIView

//    [HudView hudInView:self.navigationController.view text:@"Saved!" lineTwo:@"Check MyPicks" animated:YES];
//+ (void)hudInView:(UIView *)view text:(NSString*)text lineTwo:(NSString *)lineTwo animated:(BOOL)animated;

+(void)encourageSomething:(UIView *)view withImage:(NSString *)imageName atStartY:(int)startY withText:(NSString *)labelText withYOffset:(int)yOffset atStartX:(int)startX atLabelStartX:(int)labelStartX withDirection:(NSString *)direction;
+(void)removeEncouragement;


@end