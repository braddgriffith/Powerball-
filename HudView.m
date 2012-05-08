//
//  HudView.m
//  Ourstar2
//
//  Created by Brad Grifffith on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HudView.h"

@interface HudView ()
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *lineTwo;
@end

@implementation HudView

@synthesize text, lineTwo;

- (void)animateHUD:(BOOL)animated
{
    if (animated) 
    {
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        self.alpha = 1.0f;
        self.transform = CGAffineTransformIdentity;
        
        [UIView commitAnimations];
        
        [self performSelector:@selector(removeHUD) withObject:nil afterDelay:0.6];
    }
}

- (void)removeHUD
{
    self.alpha = 1.0f;
    self.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationCurveLinear 
                     animations:^{
                         self.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    
}

+ (void)hudInView:(UIView *)view text:(NSString*)text lineTwo:(NSString *)lineTwo animated:(BOOL)animated
{
    HudView *hudView = [[HudView alloc] initWithFrame:view.bounds];
    hudView.opaque = NO;
    hudView.alpha = 0.0;
    hudView.text = text;
    hudView.lineTwo = lineTwo;
    
    [view addSubview:hudView];
    
    [hudView animateHUD:animated];
    
    hudView = nil;
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat boxWidth = 138.0f; //was 96.0
    const CGFloat boxHeight = 118.0f;
    
    CGRect boxRect = CGRectMake(
                                roundf(self.bounds.size.width - boxWidth) / 2.0f,
                                roundf(self.bounds.size.height - boxHeight) / 2.0f,
                                boxWidth,
                                boxHeight);
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
    [[UIColor colorWithWhite:0.0f alpha:0.75] setFill];
    [roundedRect fill];
    
    UIImage *image = [UIImage imageNamed:@"Checkmark"];
    
    CGPoint imagePoint = CGPointMake(
                                     self.center.x - roundf(image.size.width / 2.0f),
                                     self.center.y - roundf(image.size.height / 2.0f) - boxHeight / 8.0f);
    
    [image drawAtPoint:imagePoint];
    
    [[UIColor whiteColor] set];
    
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    CGSize textSize = [self.text sizeWithFont:font];
    
    CGPoint textPoint = CGPointMake(
                                    self.center.x - roundf(textSize.width / 2.0f),
                                    self.center.y - roundf(textSize.height / 2.0f) + boxHeight / 6.0 -5);
    
    CGSize lineTwoSize = [self.lineTwo sizeWithFont:font];
    
    CGPoint lineTwoPoint = CGPointMake(
                                       self.center.x - roundf(lineTwoSize.width / 2.0f),
                                       self.center.y - roundf(lineTwoSize.height / 2.0f) + boxHeight / 3.0f -5);
    
    [self.text drawAtPoint:textPoint withFont:font];
    [self.lineTwo drawAtPoint:lineTwoPoint withFont:font];
}

@end
