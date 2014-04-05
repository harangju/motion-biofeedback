//
//  BFVisualizationCircleDrawingView.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 4/3/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFVisualizationCircleDrawingView.h"

@implementation BFVisualizationCircleDrawingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
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
    self.circleWidth = 10;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *circle = [self makeCircleWithCenter:self.circleCenter
                                               radius:self.circleRadius];
    circle.lineWidth = self.circleWidth;
    [circle closePath];
    [[UIColor clearColor] setFill];
    [circle fill];
    [self.circleColor setStroke];
    [circle stroke];
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
