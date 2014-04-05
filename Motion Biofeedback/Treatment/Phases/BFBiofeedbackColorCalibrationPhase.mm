//
//  BFBiofeedbackColorCalibrationPhase.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 4/5/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFBiofeedbackColorCalibrationPhase.h"
#import "BFOpenCVColorTracker.h"

@interface BFBiofeedbackColorCalibrationPhase ()

@property (nonatomic, strong) BFOpenCVColorTracker *colorTracker;

@end

@implementation BFBiofeedbackColorCalibrationPhase

#pragma mark - LifeCycle

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup

- (void)setup
{
    self.colorTracker = [BFOpenCVColorTracker new];
}

#pragma mark - Image Processing

- (void)processFrame:(cv::Mat)mat
           videoRect:(CGRect)videoRect
{
    // filter by color
    cv::Mat filteredMat(mat.rows, mat.cols, CV_8UC1, cv::Scalar(0,0,255));
    [self.colorTracker processFrameFromFrame:mat toFrame:filteredMat];
    // get centroid
    CGPoint centroid = [self.colorTracker getCentroidOfMat:filteredMat];
    // go to the end
    uchar *row_ptr = mat.ptr(centroid.y);
    NSUInteger radius = 0;
    for (int c = centroid.x; c < mat.cols; c++)
    {
        int val = row_ptr[c];
        if (val > 0)
        {
            radius++;
        }
    }
    [self.calibrationDelegate biofeedbackColorCalibrationPhase:self
                                            didFindPixelRadius:radius];
}

@end
