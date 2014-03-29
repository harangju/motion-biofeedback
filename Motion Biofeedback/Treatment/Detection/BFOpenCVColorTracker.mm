//
//  BFOpenCVColorTracker.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/29/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVColorTracker.h"

@interface BFOpenCVColorTracker ()



@end

@implementation BFOpenCVColorTracker

- (void)processFrameFromFrame:(const cv::Mat &)inputFrame
                      toFrame:(cv::Mat &)outputFrame
{
    cv::cvtColor(inputFrame, outputFrame, CV_BGR2HSV);
    cv::inRange(outputFrame, cv::Scalar(35, 50, 50), cv::Scalar(60,255,255), outputFrame);
}

- (CGPoint)absoluteDeltaFromFrame:(const cv::Mat &)inputFrame
{
    
    return CGPointZero;
}

@end
