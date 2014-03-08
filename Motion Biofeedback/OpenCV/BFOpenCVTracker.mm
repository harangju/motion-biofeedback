//
//  BFOpenCVTracker.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVTracker.h"

@implementation BFOpenCVTracker

#pragma mark - Setup

- (id)init
{
    self = [super init];
    if (self)
    {
        self.maxNumberOfPoints = 50;
        
    }
    return self;
}

#pragma mark - Image Processing

- (void)processFrameFromFrame:(const cv::Mat &)inputFrame
                      toFrame:(cv::Mat &)outputFrame
{
    inputFrame.copyTo(outputFrame);
    
    if (self.mask.rows != inputFrame.rows ||
        self.mask.cols != inputFrame.cols)
    {
        self.mask.create(inputFrame.rows,
                         inputFrame.cols,
                         CV_8UC1);
    }
    if (_previousKeyPoints.size() > 0)
    {
        
    }
}

@end
