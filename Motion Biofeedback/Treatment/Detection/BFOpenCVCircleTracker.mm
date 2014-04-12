//
//  BFOpenCVCircleTracker.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 4/12/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVCircleTracker.h"

@implementation BFOpenCVCircleTracker

- (void)processFrameFromFrame:(const cv::Mat &)inputFrame
                      toFrame:(cv::Mat &)outputFrame
{
    cv::GaussianBlur(inputFrame, outputFrame, cv::Size(9, 9), 2, 2 );
    
    std::vector<cv::Vec3f> circles;
    cv::HoughCircles(outputFrame, circles, CV_HOUGH_GRADIENT, 1,
                     outputFrame.rows/8, 100, 20, 0, 0);
    
    int maxVal = 0;
    int coolCircleIndex = 0;
    for (int i = 0; i < circles.size(); i++)
    {
        cv::Point center(cvRound(circles[i][0]),
                         cvRound(circles[i][1]));
        uchar *row_ptr = outputFrame.ptr(center.y);
        int val = row_ptr[center.x];
        NSLog(@"val %d", val);
        if (val > maxVal)
        {
            maxVal = val;
            coolCircleIndex = i;
        }
    }
    
    NSLog(@"index %d val %d", coolCircleIndex, maxVal);
    
    NSLog(@"#circles: %lu", circles.size());
    for (int i = 0; i < circles.size(); i++)
    {
        cv::Point center(cvRound(circles[i][0]),
                         cvRound(circles[i][1]));
        int radius = cvRound(circles[i][2]);
        if (i == coolCircleIndex)
        {
            cv::circle(outputFrame, center, 3, cv::Scalar(0,0,255));
        }
        cv::circle(outputFrame, center, radius, cv::Scalar(0,0,255));
    }
}

- (CGPoint)absoluteDeltaFromFrame:(const cv::Mat &)inputFrame
{
    return CGPointZero;
}

@end
