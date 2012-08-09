//
//  IntroAnimation.m
//  Powerball Results
//
//  Created by Brad Grifffith on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IntroAnimation.h"

int IAarrowWidth = 32;
int IAarrowHeight = 38;
int IAarrowBounce = 5;
int IAhorizArrowHeight = 32;
int IAhorizArrowWidth = 38;

bool IAplayAnimationForImage = YES;

int IAencourageLabelWidth = 200;
int IAencourageLabelHeight = 22;
float IAencourageAlpha = 0.8;

static UIImageView *theArrowView;
static UILabel *encourageLabel;


@implementation IntroAnimation

-(void)animateImageBounce:(NSString *)direction inView:(UIImageView *)imageView
{
    if([direction isEqualToString:@"vertical"]) {
        [UIView animateWithDuration:0.5 delay:0 options:( 
                                                         UIViewAnimationOptionCurveEaseIn | 
                                                         UIViewAnimationOptionAutoreverse |  
                                                         UIViewAnimationOptionAllowUserInteraction) 
                         animations:^{
                             imageView.center = CGPointMake(imageView.center.x, imageView.center.y+IAarrowBounce);} 
                         completion:^(BOOL finished){
                             if (finished && IAplayAnimationForImage){
                                 imageView.center = CGPointMake(imageView.center.x,imageView.center.y-IAarrowBounce); 
                                 [self animateImageBounce:@"vertical" inView:imageView];
                             }
                         }
         ]; 
    } else {
        [UIView animateWithDuration:0.5 delay:0 options:( 
                                                         UIViewAnimationOptionCurveEaseIn | 
                                                         UIViewAnimationOptionAutoreverse |  
                                                         UIViewAnimationOptionAllowUserInteraction) 
                         animations:^{
                             imageView.center = CGPointMake(imageView.center.x+IAarrowBounce, imageView.center.y);} 
                         completion:^(BOOL finished){
                             if (finished && IAplayAnimationForImage){
                                 imageView.center = CGPointMake(imageView.center.x-IAarrowBounce, imageView.center.y); 
                                 [self animateImageBounce:@"horizontal" inView:imageView];
                             }
                         }
         ]; 
    }
}

-(void)animateTextBounce:(UILabel *)label withDirection:(NSString *)direction
{
    if([direction isEqualToString:@"vertical"]) {
        [UIView animateWithDuration:0.5 delay:0 options:( 
                                                         UIViewAnimationOptionCurveEaseIn | 
                                                         UIViewAnimationOptionAutoreverse |  
                                                         UIViewAnimationOptionAllowUserInteraction) 
                         animations:^{
                             label.center = CGPointMake(label.center.x, label.center.y+IAarrowBounce);} 
                         completion:^(BOOL finished){
                             if (finished && IAplayAnimationForImage){
                                 label.center = CGPointMake(label.center.x, label.center.y-IAarrowBounce); 
                                 [self animateTextBounce:label withDirection:@"vertical"];
                             }
                         }
         ]; 
    } else {
        [UIView animateWithDuration:0.5 delay:0 options:( 
                                                         UIViewAnimationOptionCurveEaseIn | 
                                                         UIViewAnimationOptionAutoreverse |  
                                                         UIViewAnimationOptionAllowUserInteraction) 
                         animations:^{
                             label.center = CGPointMake(label.center.x+IAarrowBounce, label.center.y);} 
                         completion:^(BOOL finished){
                             if (finished && IAplayAnimationForImage){
                                 label.center = CGPointMake(label.center.x-IAarrowBounce, label.center.y); 
                                 [self animateTextBounce:label withDirection:@"horizontal"];
                             }
                         }
         ]; 
    }
}

+(void)encourageSomething:(UIView *)view withImage:(NSString *)imageName atStartY:(int)startY withText:(NSString *)labelText withYOffset:(int)yOffset atStartX:(int)startX atLabelStartX:(int)labelStartX withDirection:(NSString *)direction
{
    IntroAnimation *introAnimation = [[IntroAnimation alloc] initWithFrame:view.bounds];
    
    CGRect frame;
    if ([imageName isEqualToString:@"09-arrow-west@2x.png"]) {
        frame = CGRectMake(startX, startY, IAhorizArrowWidth, IAhorizArrowHeight);
    } else {
        frame = CGRectMake(startX, startY, IAarrowWidth, IAarrowHeight);
    }
    theArrowView = [[UIImageView alloc] initWithFrame:frame];
    
    theArrowView.image = [UIImage imageNamed:imageName];
    theArrowView.alpha = IAencourageAlpha;
    [view addSubview:theArrowView];
    
    frame = CGRectMake(labelStartX, startY-yOffset, IAencourageLabelWidth, IAencourageLabelHeight);
    encourageLabel = [[UILabel alloc] initWithFrame:frame];
    encourageLabel.backgroundColor = [UIColor clearColor];
    encourageLabel.textAlignment = UITextAlignmentCenter;
    encourageLabel.font = [UIFont boldSystemFontOfSize:16];
    encourageLabel.text = labelText;
    encourageLabel.textColor = [UIColor whiteColor];
    [encourageLabel setAlpha:IAencourageAlpha];
    [encourageLabel sizeToFit];
    encourageLabel.lineBreakMode = UILineBreakModeWordWrap;
    encourageLabel.numberOfLines = 0;
    [view addSubview:encourageLabel];
    
    IAplayAnimationForImage = YES;
    [introAnimation animateImageBounce:direction inView:theArrowView];
    [introAnimation animateTextBounce:(encourageLabel) withDirection:direction];
    NSLog(@"animated:%@",labelText);
}

+(void)removeEncouragement
{
    [encourageLabel removeFromSuperview];
    [theArrowView removeFromSuperview];
    IAplayAnimationForImage = NO;
    NSLog(@"removed animation");
}


@end
