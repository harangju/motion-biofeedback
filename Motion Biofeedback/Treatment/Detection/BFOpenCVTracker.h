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
    cv::Mat _previousImage;
    cv::Mat _nextImage;
    cv::Mat _mask;
    std::vector<unsigned char> _status;
    std::vector<float> _error;
    cv::Ptr<cv::FeatureDetector> _detector;
    cv::Mat _previousDescriptors;
    cv::Mat _nextDescriptors;
    cv::ORB _orbFeatureEngine;
    cv::BFMatcher _orbMatcher;
    
    CGPoint _previousAveragePoint;
}

@property (nonatomic) NSInteger maxNumberOfPoints;

// only use one method in a tracking session
- (void)processFrameFromFrame:(const cv::Mat &)inputFrame
                      toFrame:(cv::Mat &)outputFrame;
- (CGPoint)naiveDeltaFromFrame:(const cv::Mat &)inputFrame;
- (CGPoint)absoluteDeltaFromFrame:(const cv::Mat &)inputFrame;

@end
