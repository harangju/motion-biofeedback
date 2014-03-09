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
        self.strokeColor = [UIColor redColor].CGColor;
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

@end
