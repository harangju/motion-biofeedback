//
//  BFFaceVideoViewController.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>
#import "BFOpenCVTracker.h"
#import "BFOpenCVFaceDetector.h"

#import "BFCircleView.h"

@interface BFFaceVideoViewController : UIViewController <GPUImageVideoCameraDelegate>

@property (nonatomic, weak) IBOutlet GPUImageView *previewImageView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

@property (nonatomic, strong) BFOpenCVTracker *tracker;
@property (nonatomic, strong) BFOpenCVFaceDetector *faceDetector;

// for debugging
@property (nonatomic) cv::Mat currentMat;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic) cv::Rect faceRect;
@property (nonatomic) BOOL lockFaceRect;
@property (nonatomic) cv::Size matSize;

@property (nonatomic) CGPoint faceRectCenterInView;

@property (nonatomic) BOOL faceInCircle;
@property (nonatomic) BOOL readyToBegin;
@property (nonatomic, strong) NSTimer *readyTimer;

@property (nonatomic, weak) IBOutlet BFCircleView *circleView;

@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@end
