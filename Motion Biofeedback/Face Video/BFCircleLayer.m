//
//  BFCircleLayer.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFCircleLayer.h"

@implementation BFCircleLayer

- (id)initAtLocation:(CGPoint)location radius:(CGFloat)radius
{
    self = [super init];
    if (self)
    {
        self.path = [[self makeCircleAtLocation:location
                                         radius:radius] CGPath];
        self.circleColor = [UIColor redColor].CGColor;
        self.strokeColor = self.circleColor;
        self.fillColor = nil;
        self.lineWidth = 3.0;
    }
    return self;
}

- (UIBezierPath *)makeCircleAtLocation:(CGPoint)location
                                radius:(CGFloat)radius
{
    self.center = location;
    self.radius = radius;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:self.center
                    radius:self.radius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];
    
    return path;
}

- (void)setCircleColor:(CGColorRef)circleColor
{
    if (_circleColor != circleColor)
    {
        _circleColor = circleColor;
        self.strokeColor = circleColor;
        [self setNeedsDisplay];
    }
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextRef context = ctx;
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGRect rectangle = CGRectMake(60,170,200,80);
    CGContextAddEllipseInRect(context, rectangle);
    CGContextStrokePath(context);
}

@end
