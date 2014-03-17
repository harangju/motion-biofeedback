//
//  BFVisualizationCircleView.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFVisualizationCircleView.h"

@interface BFVisualizationCircleView ()

@property (nonatomic) CGPoint viewCenter;

@end

@implementation BFVisualizationCircleView

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
    self.viewCenter = self.center;
    self.headPosition = self.center;
    self.centerCircleColor = [UIColor redColor];
    self.deltaCircleColor = [UIColor redColor];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *mainCircle = [self makeCircleWithCenter:self.viewCenter
                                                   radius:self.centerCircleRadius];
    [mainCircle closePath];
    [self.centerCircleColor setFill];
    [mainCircle fill];
    
    UIBezierPath *deltaCircle = [self makeCircleWithCenter:self.headPosition
                                                    radius:self.deltaCircleRadius];
    deltaCircle.lineWidth = 10;
    [deltaCircle closePath];
    [[UIColor clearColor] setFill];
    [deltaCircle fill];
    [self.deltaCircleColor setStroke];
    [deltaCircle stroke];
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    // main circle
//    CGContextSetLineWidth(context, 5.0);
//    CGContextSetFillColorWithColor(context, self.centerCircleColor);
//    CGContextSetStrokeColorWithColor(context, self.centerCircleColor);
//    UIBezierPath *mainCircle = [self makeCircleWithCenter:self.viewCenter
//                                                   radius:self.centerCircleRadius];
//    CGContextAddPath(context, mainCircle.CGPath);
//    // delta circle
//    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
//    CGContextSetStrokeColorWithColor(context, self.deltaCircleColor);
//    UIBezierPath *deltaCircle = [self makeCircleWithCenter:self.headPosition
//                                                    radius:self.deltaCircleRadius];
//    CGContextAddPath(context, deltaCircle.CGPath);
//    
//    CGContextStrokePath(context);
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
