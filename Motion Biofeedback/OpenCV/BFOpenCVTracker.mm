//
//  BFOpenCVTracker.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVTracker.h"

static const char * TrackingAlgorithmKLT           = "KLT";
static const char * TrackingAlgorithmBRIEF         = "BRIEF";
static const char * TrackingAlgorithmORB           = "ORB";

@implementation BFOpenCVTracker

#pragma mark - Setup

- (id)init
{
    self = [super init];
    if (self)
    {
        self.maxNumberOfPoints = 50;
        _detector = cv::FeatureDetector::create("FAST");
    }
    return self;
}

#pragma mark - Image Processing

- (void)processFrameFromFrame:(const cv::Mat &)inputFrame
                      toFrame:(cv::Mat &)outputFrame
{
    inputFrame.copyTo(outputFrame);
    
    if (_mask.rows != inputFrame.rows ||
        _mask.cols != inputFrame.cols)
    {
        _mask.create(inputFrame.rows,
                     inputFrame.cols,
                     CV_8UC1);
        NSLog(@"created mask");
    }
    
    _nextImage = inputFrame;
    
    if (_previousPoints.size() > 0)
    {
        cv::calcOpticalFlowPyrLK(_previousImage,
                                 _nextImage,
                                 _previousPoints,
                                 _nextPoints,
                                 _status,
                                 _error);
//        NSLog(@"calculated optical flow");
    }
    
    _mask = cv::Scalar(255);
    
    std::vector<cv::Point2f> trackedPoints;
    
    for (size_t i = 0; i < _status.size(); i++)
    {
        if (_status[i])
        {
            trackedPoints.push_back(_nextPoints[i]);
            
            cv::circle(_mask,
                       _previousPoints[i],
                       15,
                       cv::Scalar(0),
                       CV_FILLED);
            cv::line(outputFrame,
                     _previousPoints[i],
                     _nextPoints[i],
                     CV_RGB(0,250,0));
            cv::circle(outputFrame,
                       _nextPoints[i],
                       3,
                       CV_RGB(0,250,0),
                       CV_FILLED);
        }
//        NSLog(@"making circles");
    }
//    NSLog(@"tracked points %lu", trackedPoints.size());
    
    BOOL needDetectAdditionalPoints = trackedPoints.size() < self.maxNumberOfPoints;
    if (needDetectAdditionalPoints)
    {
        _detector->detect(_nextImage,
                          _nextKeyPoints,
                          _mask);
        NSInteger pointsToDetect = self.maxNumberOfPoints - trackedPoints.size();
        if (_nextKeyPoints.size() > pointsToDetect)
        {
            std::random_shuffle(_nextKeyPoints.begin(),
                                _nextKeyPoints.end());
            _nextKeyPoints.resize(pointsToDetect);
        }
//        NSLog(@"Detected additional %lu points.",
//              _nextKeyPoints.size());
        for (size_t i = 0; i < _nextKeyPoints.size(); i++)
        {
            trackedPoints.push_back(_nextKeyPoints[i].pt);
            cv::circle(outputFrame,
                       _nextKeyPoints[i].pt,
                       5,
                       cv::Scalar(255, 0, 255),
                       -1);
        }
    }
    
    _previousPoints = trackedPoints;
    _nextImage.copyTo(_previousImage);
    
}

@end
