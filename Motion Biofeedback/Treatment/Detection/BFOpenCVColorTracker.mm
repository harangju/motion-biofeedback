//
//  BFOpenCVColorTracker.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/29/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVColorTracker.h"

@interface BFOpenCVColorTracker ()
{
    CGPoint _centerPoint;
}

@end

@implementation BFOpenCVColorTracker

- (id)init
{
    self = [super init];
    if (self)
    {
        _centerPoint = CGPointZero;
    }
    return self;
}

- (void)processFrameFromFrame:(const cv::Mat &)inputFrame
                      toFrame:(cv::Mat &)outputFrame
{
    cv::cvtColor(inputFrame, outputFrame, CV_BGR2HSV);
//    cv::Scalar min(35, 50, 50);
//    cv::Scalar max(60, 255, 255);
    cv::Scalar min(87 * (180.0/360.0), 50, 5 * (255/100));
    cv::Scalar max(180 * (180.0/360.0), 255, 255);
    cv::inRange(outputFrame, min, max, outputFrame);
}

- (CGPoint)absoluteDeltaFromFrame:(const cv::Mat &)inputFrame
{
    // get color
    cv::Mat filteredMat(inputFrame.rows, inputFrame.cols, CV_8UC1, cv::Scalar(0,0,255));
    [self processFrameFromFrame:inputFrame toFrame:filteredMat];
    
    // get point
    NSUInteger sumX = 0;
    NSUInteger sumY = 0;
    NSUInteger total = 0;
    for (int r = 0; r < filteredMat.rows; r++)
    {
        uchar *row_ptr = filteredMat.ptr(r);
        for (int c = 0; c < filteredMat.cols; c++)
        {
            int val = row_ptr[c];
            if (val > 0)
            {
                sumX += c;
                sumY += r;
                total++;
            }
        }
    }
    
    if (total == 0)
    {
        return CGPointZero;
    }
    
    CGPoint point = CGPointMake((CGFloat)sumX / (CGFloat)total,
                                (CGFloat)sumY / (CGFloat)total);
//    NSLog(@"(%d, %d)", (int)point.x, (int)point.y);
    
    // get the difference
    if (_centerPoint.x == 0 && _centerPoint.y == 0)
    {
        _centerPoint = point;
    }
    else
    {
        CGPoint delta;
        delta.x = point.x - _centerPoint.x;
        delta.y = point.y - _centerPoint.y;
        return delta;
    }
    
    return CGPointZero;
}

@end
