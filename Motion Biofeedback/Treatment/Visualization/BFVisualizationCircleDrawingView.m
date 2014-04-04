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
        // Initialization code
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *deltaCircle = [self makeCircleWithCenter:self.circleCenter
                                                    radius:self.circleRadius];
    deltaCircle.lineWidth = 10;
    [deltaCircle closePath];
    [[UIColor clearColor] setFill];
    [deltaCircle fill];
    [self.circleColor setStroke];
    [deltaCircle stroke];
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
