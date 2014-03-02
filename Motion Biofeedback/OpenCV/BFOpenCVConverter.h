//
//  BFOpenCVConverter.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 2/26/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

using namespace cv;

@interface BFOpenCVConverter : NSObject

+ (Mat)matForSampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (UIImage *)imageForMat:(Mat)mat;

@end
