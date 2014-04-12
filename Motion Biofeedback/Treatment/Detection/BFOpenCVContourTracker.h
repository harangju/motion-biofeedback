//
//  BFOpenCVContourTracker.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 4/12/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFOpenCVContourTracker : NSObject

- (void)processFrameFromFrame:(const cv::Mat &)inputFrame
                      toFrame:(cv::Mat &)outputFrame;
- (CGPoint)absoluteDeltaFromFrame:(const cv::Mat &)inputFrame;

@end
