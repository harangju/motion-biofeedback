//
//  BFOpenCVTracker.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>

// using KLT Tracking

@interface BFOpenCVTracker : NSObject
{
    std::vector<cv::KeyPoint> _previousKeyPoints;
    std::vector<cv::KeyPoint> _nextKeyPoints;
    std::vector<cv::Point2f> _previousPoints;
    std::vector<cv::Point2f> _nextPoints;
}

@property (nonatomic) NSInteger maxNumberOfPoints;

@property (nonatomic) cv::Mat previousImage;
@property (nonatomic) cv::Mat nextImage;
@property (nonatomic) cv::Mat mask;

- (void)processFrameFromFrame:(const cv::Mat &)inputFrame
                      toFrame:(cv::Mat &)outputFrame;

@end
