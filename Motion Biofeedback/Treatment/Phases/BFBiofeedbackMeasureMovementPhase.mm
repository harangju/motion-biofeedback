//
//  BFBiofeedbackMeasureMovementPhase.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/16/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFBiofeedbackMeasureMovementPhase.h"
#import "BFOpenCVTracker.h"
#import "BFOpenCVColorTracker.h"
#import "BFOpenCVCircleTracker.h"
#import "BFSettings.h"

@interface BFBiofeedbackMeasureMovementPhase ()

@property (nonatomic, strong) BFOpenCVTracker *tracker;
@property (nonatomic, strong) BFOpenCVColorTracker *colorTracker;
@property (nonatomic, strong) BFOpenCVCircleTracker *circleTracker;

@property (nonatomic) BFSettingsDetection detectionAlgorithm;

@end

@implementation BFBiofeedbackMeasureMovementPhase

#pragma mark - LifeCycle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

#pragma mark - Setup

- (void)setup
{
    self.tracker = [BFOpenCVTracker new];
    self.colorTracker = [BFOpenCVColorTracker new];
    self.circleTracker = [BFOpenCVCircleTracker new];
    
    self.detectionAlgorithm = [BFSettings detection];
}

#pragma mark - Image Processing

- (void)processFrame:(cv::Mat)mat
           videoRect:(CGRect)videoRect
{
//    NSLog(@"measure movement: processing frame");
//    CGPoint absoluteDelta = CGPointZero;
    NSValue *absoluteDelta = nil;
    if (self.detectionAlgorithm == BFSettingsDetectionFeature)
    {
        CGPoint point = [self.tracker absoluteDeltaFromFrame:mat];
        absoluteDelta = [NSValue valueWithCGPoint:point];
    }
    else if (self.detectionAlgorithm == BFSettingsDetectionMarkerColor)
    {
        CGPoint point = [self.colorTracker absoluteDeltaFromFrame:mat];
        absoluteDelta = [NSValue valueWithCGPoint:point];
    }
    else if (self.detectionAlgorithm == BFSettingsDetectionMarkerCircle)
    {
        absoluteDelta = [self.circleTracker absoluteDeltaFromFrame:mat];
    }
    [self.measureMovementDelegate biofeedbackMeasureMovementPhase:self
                                                withAbsoluteDelta:absoluteDelta];
}

@end
