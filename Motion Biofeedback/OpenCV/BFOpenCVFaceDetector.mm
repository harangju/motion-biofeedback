//
//  BFOpenCVFaceDetector.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 2/26/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVFaceDetector.h"

@implementation BFOpenCVFaceDetector

+ (cv::Rect)faceFrameFromMat:(cv::Mat)mat
{
    std::vector<cv::Rect> faces;
    
    return faces.front();
}

@end
