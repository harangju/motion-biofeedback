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
#import "BFSettings.h"

@interface BFBiofeedbackMeasureMovementPhase ()

@property (nonatomic, strong) BFOpenCVTracker *tracker;
@property (nonatomic, strong) BFOpenCVColorTracker *colorTracker;

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
    
    self.detectionAlgorithm = [BFSettings detection];
}

#pragma mark - Image Processing

- (void)processFrame:(cv::Mat)mat
           videoRect:(CGRect)videoRect
{
    if (self.detectionAlgorithm == BFSettingsDetectionFeature)
    {
        CGPoint absoluteDelta = [self.tracker absoluteDeltaFromFrame:mat];
        [self.measureMovementDelegate biofeedbackMeasureMovementPhase:self
                                                    withAbsoluteDelta:absoluteDelta];
    }
    else
    {
        CGPoint absoluteDelta = [self.colorTracker absoluteDeltaFromFrame:mat];
        [self.measureMovementDelegate biofeedbackMeasureMovementPhase:self
                                                    withAbsoluteDelta:absoluteDelta];
    }
}

@end
