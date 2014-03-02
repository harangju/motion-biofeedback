//
//  BFOpenCVFaceDetector.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 2/26/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFOpenCVFaceDetector : NSObject

+ (cv::Rect)faceFrameFromMat:(cv::Mat)mat;

@end
