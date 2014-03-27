//
//  BFCalibrationRulerView.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/27/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFCalibrationRulerView.h"

static const CGFloat CircleRadius = 18.0;
static const CGFloat CircleLineWidth = 2.0;
static const CGFloat LineWidth = 2.0;

@implementation BFCalibrationRulerView

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [self setup];
}

#pragma mark - Setup

- (void)setup
{
    self.pointA = CGPointMake(self.bounds.size.width / 4.0,
                              self.bounds.size.height / 2.0);
    self.pointB = CGPointMake(self.bounds.size.width / 4.0 * 3.0,
                              self.bounds.size.height / 2.0);
    self.color = [UIColor blueColor];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    // color
    [self.color setStroke];
    // circle A
    UIBezierPath *circleA = [self makeCircleWithCenter:self.pointA
                                                radius:CircleRadius];
    circleA.lineWidth = CircleLineWidth;
    [circleA stroke];
    UIBezierPath *circleACenter = [self makeCircleWithCenter:self.pointA
                                                      radius:1];
    [circleACenter stroke];
    // circle B
    UIBezierPath *circleB = [self makeCircleWithCenter:self.pointB
                                                radius:CircleRadius];
    circleB.lineWidth = CircleLineWidth;
    [circleB stroke];
    UIBezierPath *circleBCenter = [self makeCircleWithCenter:self.pointB
                                                      radius:1];
    [circleBCenter stroke];
    // line
    UIBezierPath *line = [UIBezierPath bezierPath];
    line.lineWidth = LineWidth;
    [line moveToPoint:self.pointA];
    [line addLineToPoint:self.pointB];
    [line stroke];
}

- (UIBezierPath *)makeCircleWithCenter:(CGPoint)center
                                radius:(CGFloat)radius
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
