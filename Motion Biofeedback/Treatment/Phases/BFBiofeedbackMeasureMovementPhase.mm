//
//  BFBiofeedbackMeasureMovementPhase.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/16/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFBiofeedbackMeasureMovementPhase.h"
#import "BFOpenCVTracker.h"

@interface BFBiofeedbackMeasureMovementPhase ()

@property (nonatomic, strong) BFOpenCVTracker *tracker;

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
}

#pragma mark - Image Processing

- (void)processFrame:(cv::Mat)mat
           videoRect:(CGRect)videoRect
{
    cv::Mat faceMat = mat(self.faceRect);
    
    CGPoint naiveDelta = [self.tracker naiveDeltaFromFrame:faceMat];
    [self.measureMovementDelegate biofeedbackMeasureMovementPhase:self
                                                   withNaiveDelta:naiveDelta];
}

@end
