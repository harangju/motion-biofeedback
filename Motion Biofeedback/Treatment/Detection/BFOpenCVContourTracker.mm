//
//  BFOpenCVContourTracker.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 4/12/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVContourTracker.h"
#import "BFOpenCVEdgeDetector.h"

@interface BFOpenCVContourTracker ()

@property (nonatomic, strong) BFOpenCVEdgeDetector *edgeDetector;

@end

@implementation BFOpenCVContourTracker

- (id)init
{
    self = [super init];
    if (self) {
        self.edgeDetector = [BFOpenCVEdgeDetector new];
    }
    return self;
}

- (void)processFrameFromFrame:(const cv::Mat &)inputFrame
                      toFrame:(cv::Mat &)outputFrame
{
    cv::Mat newMat(inputFrame.rows,
                   inputFrame.cols,
                   CV_8UC1, cv::Scalar(0,0,255));
    
    
//    [self.edgeDetector getEdges:newMat
//                        fromMat:inputFrame];
//    
//    std::vector<std::vector<cv::Point>> contours;
//    std::vector<cv::Vec4i> hierarchy;
//    
//    cv::findContours(newMat,
//                     contours, hierarchy, CV_RETR_TREE,
//                     CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
//    
//    cv::vector<cv::vector<cv::Point> > contours_poly( contours.size() );
//    std::vector<cv::Point2f>center( contours.size() );
//    std::vector<float>radius( contours.size() );
//    
//    for (int i = 0; i < contours.size(); i++)
//    {
//        cv::approxPolyDP(cv::Mat(contours[i]),
//                         contours_poly[i], 2, true);
//        cv::minEnclosingCircle((cv::Mat)contours_poly[i],
//                               center[i], radius[i]);
//    }
//    
//    cv::Mat drawing = cv::Mat::zeros(newMat.size(), CV_8UC3);
//    cv::RNG rng(12345);
//    NSLog(@"#circles: %lu", contours.size());
//    for (int i = 0; i < contours.size(); i++)
//    {
//        cv::Scalar color = cv::Scalar(rng.uniform(0, 255),
//                                      rng.uniform(0,255),
//                                      rng.uniform(0,255));
////        cv::drawContours(outputFrame,
////                         contours_poly,
////                         i, color);
//        cv::circle(outputFrame,
//                   center[i], radius[i],
//                   color);
//    }
}

- (CGPoint)absoluteDeltaFromFrame:(const cv::Mat &)inputFrame
{
    return CGPointZero;
}

@end
