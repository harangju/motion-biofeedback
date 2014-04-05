//
//  BFVisualizationCircleView.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFVisualizationCircleView.h"
#import "BFVisualizationCircleDrawingView.h"

@interface BFVisualizationCircleView ()

@property (nonatomic) CGPoint viewCenter;

@property (nonatomic, strong) BFVisualizationCircleDrawingView *circleDrawingView;

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
    self.circleDrawingView = [[BFVisualizationCircleDrawingView alloc] initWithFrame:self.bounds];
    self.circleDrawingView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.circleDrawingView];
    
    self.centerCircleWidth = 10;
    self.deltaCircleWidth = 10;
    
    self.viewCenter = self.center;
    self.headPosition = self.center;
    self.centerCircleColor = [UIColor blueColor];
    self.deltaColor = [UIColor redColor];
}

- (void)drawCenterCircle
{
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.opacity = 0.4;
    circleLayer.frame = self.bounds;
    circleLayer.path = [self makeCircleWithCenter:self.viewCenter
                                           radius:self.centerCircleRadius].CGPath;
    circleLayer.position = self.viewCenter;
    circleLayer.fillColor = self.centerCircleColor.CGColor;
    circleLayer.strokeColor = self.centerCircleColor.CGColor;
    circleLayer.lineWidth = 10;
    [self.layer insertSublayer:circleLayer atIndex:0];
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

#pragma mark - Setters

- (void)setDeltaCircleRadius:(CGFloat)deltaCircleRadius
{
    _deltaCircleRadius = deltaCircleRadius;
    self.circleDrawingView.circleRadius = deltaCircleRadius;
    [self.circleDrawingView setNeedsDisplay];
}

- (void)setHeadPosition:(CGPoint)headPosition
{
    _headPosition = headPosition;
    self.circleDrawingView.circleCenter = headPosition;
    [self.circleDrawingView setNeedsDisplay];
}

- (void)setDeltaColor:(UIColor *)deltaColor
{
    _deltaColor = deltaColor;
    self.circleDrawingView.circleColor = deltaColor;
    [self.circleDrawingView setNeedsDisplay];
}

- (void)setDeltaCircleWidth:(CGFloat)deltaCircleWidth
{
    _deltaCircleWidth = deltaCircleWidth;
    self.circleDrawingView.circleWidth = deltaCircleWidth;
    [self.circleDrawingView setNeedsDisplay];
}

@end
