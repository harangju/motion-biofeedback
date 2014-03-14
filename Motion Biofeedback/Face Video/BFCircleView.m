//
//  BFCircleView.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFCircleView.h"

@implementation BFCircleView

#pragma mark - LifeCycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.circleColor = [UIColor redColor].CGColor;
    self.deltaCircleColor = [UIColor redColor].CGColor;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // main circle
    CGContextSetLineWidth(context, 5.0);
    CGContextSetStrokeColorWithColor(context, self.circleColor);
    UIBezierPath *mainCircle = [self makeCircleWithCenter:self.circleCenter
                                                   radius:self.circleRadius];
    CGContextAddPath(context, mainCircle.CGPath);
    // delta circle
    if (self.shouldShowDeltaCircle)
    {
        CGContextSetStrokeColorWithColor(context, self.deltaCircleColor);
        UIBezierPath *deltaCircle = [self makeCircleWithCenter:self.deltaCircleCenter
                                                        radius:self.deltaCircleRadius];
        CGContextAddPath(context, deltaCircle.CGPath);
    }
    CGContextStrokePath(context);
}

- (UIBezierPath *)makeCircleWithCenter:(CGPoint)center radius:(CGFloat)radius
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:center
                    radius:radius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];
    
    return path;
}

@end
