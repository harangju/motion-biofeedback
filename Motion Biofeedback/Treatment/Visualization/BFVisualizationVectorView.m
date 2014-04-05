//
//  BFVisualizationVectorView.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 4/5/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFVisualizationVectorView.h"
#import "BFVisualizationCircleDrawingView.h"

static const CGFloat CenterCircleRadius = 20;
static const CGFloat DeltaCircleRadius = 20;

@interface BFVisualizationVectorView ()

@property (nonatomic, strong) BFVisualizationCircleDrawingView *centerCircleDrawingView;
@property (nonatomic, strong) BFVisualizationCircleDrawingView *deltaCircleDrawingView;

@end

@implementation BFVisualizationVectorView

#pragma mark - LifeCycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    self.lineWidth = 3;
    self.lineColor = [UIColor yellowColor];
    
    self.centerCircleDrawingView = [[BFVisualizationCircleDrawingView alloc] initWithFrame:self.bounds];
    self.centerCircleDrawingView.circleCenter = self.center;
    self.centerCircleDrawingView.circleRadius = CenterCircleRadius;
    self.centerCircleDrawingView.circleWidth = CenterCircleRadius * 2;
    self.centerCircleDrawingView.circleColor = [UIColor blueColor];
    self.centerCircleDrawingView.layer.opacity = 0.8;
    [self addSubview:self.centerCircleDrawingView];
    
    self.deltaCircleDrawingView = [[BFVisualizationCircleDrawingView alloc] initWithFrame:self.bounds];
    self.deltaCircleDrawingView.circleCenter = self.center;
    self.deltaCircleDrawingView.circleRadius = DeltaCircleRadius;
    self.deltaCircleDrawingView.circleWidth = DeltaCircleRadius * 2;
    self.deltaCircleDrawingView.circleColor = [UIColor greenColor];
    self.deltaCircleDrawingView.layer.opacity = 0.8;
    [self addSubview:self.deltaCircleDrawingView];
}

- (void)setHeadPosition:(CGPoint)headPosition
{
    _headPosition = headPosition;
    self.deltaCircleDrawingView.circleCenter = headPosition;
    [self.deltaCircleDrawingView setNeedsDisplay];
    [self setNeedsDisplay];
}

- (void)setDeltaColor:(UIColor *)deltaColor
{
    _deltaColor = deltaColor;
    self.deltaCircleDrawingView.circleColor = deltaColor;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.center];
    [path addLineToPoint:self.headPosition];
    path.lineWidth = self.lineWidth;
    [self.lineColor setStroke];
    [path stroke];
}

@end
