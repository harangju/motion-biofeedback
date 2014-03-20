//
//  BFOpenCVTracker.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVTracker.h"

@interface BFOpenCVTracker ()

@property (nonatomic) BOOL averagePointReferenceSaved;
@property (nonatomic) CGPoint averagePointReference;

@end

@implementation BFOpenCVTracker

#pragma mark - Setup

- (id)init
{
    self = [super init];
    if (self)
    {
        self.maxNumberOfPoints = 75;
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
            
            cv::circle(_mask, _previousPoints[i], 15, cv::Scalar(0), CV_FILLED);
            cv::line(outputFrame, _previousPoints[i], _nextPoints[i], CV_RGB(0,250,0));
            cv::circle(outputFrame, _nextPoints[i], 3, CV_RGB(0,250,0), CV_FILLED);
        }
//        NSLog(@"making circles");
    }
//    NSLog(@"tracked points %lu", trackedPoints.size());
    
    BOOL needDetectAdditionalPoints = trackedPoints.size() < self.maxNumberOfPoints;
    if (needDetectAdditionalPoints)
    {
        _detector->detect(_nextImage, _nextKeyPoints, _mask);
        NSInteger pointsToDetect = self.maxNumberOfPoints - trackedPoints.size();
        if (_nextKeyPoints.size() > pointsToDetect)
        {
            std::random_shuffle(_nextKeyPoints.begin(), _nextKeyPoints.end());
            _nextKeyPoints.resize(pointsToDetect);
        }
        for (size_t i = 0; i < _nextKeyPoints.size(); i++)
        {
            trackedPoints.push_back(_nextKeyPoints[i].pt);
            cv::circle(outputFrame, _nextKeyPoints[i].pt, 5, cv::Scalar(255, 0, 255), -1);
        }
    }
    
    _previousPoints = trackedPoints;
    _nextImage.copyTo(_previousImage);
}

- (CGPoint)naiveDeltaFromFrame:(const cv::Mat &)inputFrame
{
    if (_mask.rows != inputFrame.rows ||
        _mask.cols != inputFrame.cols)
    {
        _mask.create(inputFrame.rows,
                     inputFrame.cols,
                     CV_8UC1);
        NSLog(@"created mask");
    }
    // next image is the "current" image
    _nextImage = inputFrame;
    // if there are any previous points
    // calculate the flow
    if (_previousPoints.size() > 0)
    {
        cv::calcOpticalFlowPyrLK(_previousImage, _nextImage,
                                 _previousPoints, _nextPoints,
                                 _status, _error);
    }
    // I don't know what this does
    _mask = cv::Scalar(255);
    // get the tracked points
    std::vector<cv::Point2f> trackedPoints;
    // by iterating through here
    for (size_t i = 0; i < _status.size(); i++)
    {
        if (_status[i])
        {
            trackedPoints.push_back(_nextPoints[i]);
        }
    }
    // if need additional poitns
    BOOL needDetectAdditionalPoints = trackedPoints.size() < self.maxNumberOfPoints;
    if (needDetectAdditionalPoints)
    {
        // get them
        _detector->detect(_nextImage, _nextKeyPoints, _mask);
        NSInteger pointsToDetect = self.maxNumberOfPoints - trackedPoints.size();
        // get rid of the extras
        if (_nextKeyPoints.size() > pointsToDetect)
        {
            std::random_shuffle(_nextKeyPoints.begin(), _nextKeyPoints.end());
            _nextKeyPoints.resize(pointsToDetect);
        }
        // add them to tracked points
        for (size_t i = 0; i < _nextKeyPoints.size(); i++)
        {
            trackedPoints.push_back(_nextKeyPoints[i].pt);
        }
    }
    // calculate delta from points
    // get the average point
    CGPoint averagePoint;
    CGFloat totalX = 0;
    CGFloat totalY = 0;
    for (int i = 0; i < trackedPoints.size(); i++)
    {
        cv::Point2f point = trackedPoints[i];
        totalX += point.x;
        totalY += point.y;
    }
    averagePoint.x = totalX / trackedPoints.size();
    averagePoint.y = totalY / trackedPoints.size();
    // save average point as reference
    // if needed
    if (!self.averagePointReferenceSaved)
    {
        self.averagePointReference = averagePoint;
        self.averagePointReferenceSaved = YES;
    }
    // find delta
    CGPoint deltaPoint;
//    deltaPoint.x = averagePoint.x - _previousAveragePoint.x;
//    deltaPoint.y = averagePoint.y - _previousAveragePoint.y;
    deltaPoint.x = averagePoint.x - self.averagePointReference.x;
    deltaPoint.y = averagePoint.y - self.averagePointReference.y;
    // if no previous average point
    // return zero
//    if (_previousAveragePoint.x == 0 && _previousAveragePoint.y == 0)
    if (self.averagePointReference.x == 0 && self.averagePointReference.y == 0)
    {
        deltaPoint = CGPointZero;
    }
    // next values become previous values
    _previousAveragePoint = averagePoint;
    _previousPoints = trackedPoints;
    _nextImage.copyTo(_previousImage);
    return deltaPoint;
}

- (CGPoint)absoluteDeltaFromFrame:(const cv::Mat &)inputFrame
{
    if (_mask.rows != inputFrame.rows ||
        _mask.cols != inputFrame.cols)
    {
        _mask.create(inputFrame.rows,
                     inputFrame.cols,
                     CV_8UC1);
        NSLog(@"created mask");
    }
    // next image is the "current" image
    _nextImage = inputFrame;
    // if there are any previous points
    // calculate the flow
    if (_previousPoints.size() > 0)
    {
        cv::calcOpticalFlowPyrLK(_previousImage, _nextImage,
                                 _previousPoints, _nextPoints,
                                 _status, _error);
    }
    // I don't know what this does
    _mask = cv::Scalar(255);
    // get the tracked points
    std::vector<cv::Point2f> trackedPoints;
    // by iterating through here
    for (size_t i = 0; i < _status.size(); i++)
    {
        if (_status[i])
        {
            trackedPoints.push_back(_nextPoints[i]);
        }
    }
    // if need additional poitns
    BOOL needDetectAdditionalPoints = trackedPoints.size() < self.maxNumberOfPoints;
    if (needDetectAdditionalPoints)
    {
        // get them
        _detector->detect(_nextImage, _nextKeyPoints, _mask);
        NSInteger pointsToDetect = self.maxNumberOfPoints - trackedPoints.size();
        // get rid of the extras
        if (_nextKeyPoints.size() > pointsToDetect)
        {
            std::random_shuffle(_nextKeyPoints.begin(), _nextKeyPoints.end());
            _nextKeyPoints.resize(pointsToDetect);
        }
        // add them to tracked points
        for (size_t i = 0; i < _nextKeyPoints.size(); i++)
        {
            trackedPoints.push_back(_nextKeyPoints[i].pt);
        }
    }
    // calculate delta from points
    // get the average point
    CGPoint averagePoint;
    CGFloat totalX = 0;
    CGFloat totalY = 0;
    for (int i = 0; i < trackedPoints.size(); i++)
    {
        cv::Point2f point = trackedPoints[i];
        totalX += point.x;
        totalY += point.y;
    }
    averagePoint.x = totalX / trackedPoints.size();
    averagePoint.y = totalY / trackedPoints.size();
    // save average point as reference
    // if needed
    if (!self.averagePointReferenceSaved)
    {
        self.averagePointReference = averagePoint;
        self.averagePointReferenceSaved = YES;
    }
    // find delta
    CGPoint deltaPoint;
    //    deltaPoint.x = averagePoint.x - _previousAveragePoint.x;
    //    deltaPoint.y = averagePoint.y - _previousAveragePoint.y;
    deltaPoint.x = averagePoint.x - self.averagePointReference.x;
    deltaPoint.y = averagePoint.y - self.averagePointReference.y;
    // if no previous average point
    // return zero
    //    if (_previousAveragePoint.x == 0 && _previousAveragePoint.y == 0)
    if (self.averagePointReference.x == 0 && self.averagePointReference.y == 0)
    {
        deltaPoint = CGPointZero;
    }
    // next values become previous values
    _previousAveragePoint = averagePoint;
    _previousPoints = trackedPoints;
    _nextImage.copyTo(_previousImage);
    return deltaPoint;
}

@end
