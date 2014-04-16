//
//  BFOpenCVCircleTracker.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 4/12/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVCircleTracker.h"

@interface BFOpenCVCircleTracker ()
{
    cv::Point _centerPoint;
    cv::Point _previousPoint;
}

@end

@implementation BFOpenCVCircleTracker

- (id)init
{
    self = [super init];
    if (self) {
        _centerPoint.x = 0;
        _centerPoint.y = 0;
    }
    return self;
}

- (void)processFrameFromFrame:(const cv::Mat &)inputFrame
                      toFrame:(cv::Mat &)outputFrame
{
    cv::Mat blurredMat = [self blurredMatFromMat:inputFrame];
    std::vector<cv::Vec3f> circles = [self circlesFromMat:blurredMat];
    int brightestCircleIndex = [self brightestCircleIndexFromCircles:circles
                                                               inMat:blurredMat];
    
    NSLog(@"#circles: %lu", circles.size());
    for (int i = 0; i < circles.size(); i++)
    {
        cv::Point center(cvRound(circles[i][0]),
                         cvRound(circles[i][1]));
        int radius = cvRound(circles[i][2]);
        if (i == brightestCircleIndex)
        {
            cv::circle(blurredMat, center, 3, cv::Scalar(0,0,255));
        }
        cv::circle(blurredMat, center, radius, cv::Scalar(0,0,255));
    }
    outputFrame = blurredMat;
}

- (NSValue *)absoluteDeltaFromFrame:(const cv::Mat &)inputFrame
{
    cv::Mat blurredMat = [self blurredMatFromMat:inputFrame];
    std::vector<cv::Vec3f> circles = [self circlesFromMat:blurredMat];
    if (circles.size() == 0)
    {
        NSLog(@"no circles");
        return nil;
    }
    int brightestCircleIndex = [self brightestCircleIndexFromCircles:circles
                                                               inMat:blurredMat];
    cv::Vec3f brightestCircle = circles[brightestCircleIndex];
    cv::Point brightestCircleCenter(cvRound(brightestCircle[0]),
                                    cvRound(brightestCircle[1]));
//    int radius = cvRound(brightestCircle[2]);
    if (_centerPoint.x == 0 && _centerPoint.y == 0)
        // just started
    {
        _centerPoint = brightestCircleCenter;
    }
    else
        // there is a previous center point
    {
        CGPoint deltaPoint;
        deltaPoint.x = brightestCircleCenter.x - _centerPoint.x;
        deltaPoint.y = brightestCircleCenter.y - _centerPoint.y;
        CGPoint incrementalDeltaPoint;
        incrementalDeltaPoint.x = brightestCircleCenter.x - _previousPoint.x;
        incrementalDeltaPoint.y = brightestCircleCenter.y - _previousPoint.y;
        _previousPoint.x = incrementalDeltaPoint.x;
        _previousPoint.y = incrementalDeltaPoint.y;
        if (MAX(incrementalDeltaPoint.x, incrementalDeltaPoint.y) > 50)
        {
            return nil;
        }
        return [NSValue valueWithCGPoint:deltaPoint];
    }
    return nil;
}

- (std::vector<cv::Vec3f>)circlesFromMat:(cv::Mat)mat
{
    std::vector<cv::Vec3f> circles;
    cv::HoughCircles(mat, circles, CV_HOUGH_GRADIENT, 1,
                     mat.rows/8, 80, 20, 0, 0);
//                     mat.rows/8, 100, 20, 0, 0);
    return circles;
}

- (cv::Mat)blurredMatFromMat:(const cv::Mat &)mat
{
    cv::Mat blurredMat(mat.rows, mat.cols, CV_8UC1, cv::Scalar(0,0,255));
    cv::GaussianBlur(mat, blurredMat, cv::Size(9, 9), 2, 2);
    return blurredMat;
}

- (int)brightestCircleIndexFromCircles:(std::vector<cv::Vec3f>)circles
                                 inMat:(cv::Mat &)mat
{
    int biggestValue = 0;
    int brightestCircleIndex = 0;
    for (int i = 0; i < circles.size(); i++)
    {
        cv::Point center(cvRound(circles[i][0]),
                         cvRound(circles[i][1]));
        uchar *row_ptr = mat.ptr(center.y);
        int value = row_ptr[center.x];
//        NSLog(@"val %d", value);
        if (value > biggestValue)
        {
            biggestValue = value;
            brightestCircleIndex = i;
        }
    }
//    NSLog(@"brightest circle index %d \t value %d",
//          brightestCircleIndex, biggestValue);
    return brightestCircleIndex;
}

@end
