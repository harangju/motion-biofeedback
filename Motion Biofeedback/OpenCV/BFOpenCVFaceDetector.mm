//
//  BFOpenCVFaceDetector.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 2/26/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVFaceDetector.h"

// Name of face cascade resource file without xml extension
NSString * const kFaceCascadeFilename = @"haarcascade_frontalface_alt2";
const int kHaarOptions =  CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;

@interface BFOpenCVFaceDetector ()
{
    cv::CascadeClassifier _faceCascade;
    BOOL _isProcessingFrame;
}

@end

@implementation BFOpenCVFaceDetector

- (id)init
{
    self = [super init];
    if (self) {
        // Load the face Haar cascade from resources
        NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:kFaceCascadeFilename
                                                                    ofType:@"xml"];
        if (!_faceCascade.load(faceCascadePath.UTF8String))
        {
            NSLog(@"Could not load face cascade: %@", faceCascadePath);
        }
    }
    return self;
}

- (std::vector<cv::Rect>)faceFrameFromMat:(cv::Mat)mat
{
    _isProcessingFrame = YES;
    std::vector<cv::Rect> faces;
    _faceCascade.detectMultiScale(mat, faces, 1.1, 3, kHaarOptions, cv::Size(60, 60));
    NSLog(@"face count - %lu", faces.size());
    return faces;
    _isProcessingFrame = NO;
}

@end
