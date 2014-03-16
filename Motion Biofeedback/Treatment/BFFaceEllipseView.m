//
//  BFFaceEllipseView.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFFaceEllipseView.h"

@implementation BFFaceEllipseView

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

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.ellipseColor = [UIColor redColor];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 5.0);
    CGContextSetStrokeColorWithColor(context, self.ellipseColor.CGColor);
    UIBezierPath *mainCircle = [UIBezierPath bezierPathWithOvalInRect:self.faceEllipseRect];
    CGContextAddPath(context, mainCircle.CGPath);
    CGContextStrokePath(context);
}

@end
