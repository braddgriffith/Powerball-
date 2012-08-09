//
//  IntroAnimation.h
//  Powerball Results
//
//  Created by Brad Grifffith on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroAnimation : UIView

+(void)encourageSomething:(UIView *)view withImage:(NSString *)imageName atStartY:(int)startY withText:(NSString *)labelText withYOffset:(int)yOffset atStartX:(int)startX atLabelStartX:(int)labelStartX withDirection:(NSString *)direction;
+(void)removeEncouragement;


@end