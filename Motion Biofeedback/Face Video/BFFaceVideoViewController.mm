//
//  BFFaceVideoViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFFaceVideoViewController.h"
#import "BFOpenCVConverter.h"

static CGFloat FaceRectCircleMatchCenterDifferentThreshold = 25;

@interface BFFaceVideoViewController ()

@end

@implementation BFFaceVideoViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeVideoCamera];
    [self initializeDetectors];
    [self.videoCamera addTarget:self.previewImageView];
    [self.videoCamera startCameraCapture];
    [self initializeCircleView];
//    [self initializeCircleLayer];
//    [self.view.layer addSublayer:self.circleLayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initialization

- (void)initializeVideoCamera
{
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh
                                                           cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.delegate = self;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
}

- (void)initializeDetectors
{
    self.tracker = [BFOpenCVTracker new];
    self.faceDetector = [BFOpenCVFaceDetector new];
}

- (void)initializeCircleLayer
{
    CGPoint center = CGPointMake(self.view.bounds.size.width/2.0,
                                 self.view.bounds.size.height/2.0);
    self.circleLayer = [[BFCircleLayer alloc] initAtLocation:center
                                                      radius:200];
}

- (void)initializeCircleView
{
    CGPoint center = CGPointMake(self.circleView.bounds.size.width/2.0,
                                 self.circleView.bounds.size.height/2.0);
    self.circleView.circleCenter = center;
    self.circleView.circleRadius = 200;
}

#pragma mark - GPUImage VideoCamera Delegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // get mat
    cv::Mat mat = [BFOpenCVConverter matForSampleBuffer:sampleBuffer];
    transpose(mat, mat);
    
    // processs video
    [self processFrame:mat withVideoRect:[self videoRectFromBuffer:sampleBuffer]];
}

- (CGRect)videoRectFromBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CGRect videoRect = CGRectMake(0.0f, 0.0f,
                                  CVPixelBufferGetHeight(pixelBuffer),
                                  CVPixelBufferGetWidth(pixelBuffer));
    return videoRect;
}

#pragma mark - Video Processing

- (void)processFrame:(cv::Mat &)mat withVideoRect:(CGRect)videoRect
{
    if (self.lockFaceRect)
    {
        
    }
    else
    {
        // get face rect
        std::vector<cv::Rect> faceRects = [self.faceDetector faceFrameFromMat:mat];
        if (faceRects.size() > 0)
        {
            cv::Rect faceRect = faceRects.front();
            BOOL faceIsInsideCircle = [self faceRectIsInsideCircle:faceRect
                                                       inVideoRect:videoRect
                                                               mat:mat];
            if (faceIsInsideCircle)
            {
                NSLog(@"inside circle");
                self.circleView.circleColor = [UIColor blueColor].CGColor;
            }
//            else
//            {
//                self.circleView.circleColor = [UIColor redColor].CGColor;
//            }
            [self.circleView setNeedsLayout];
        }
    }
}

- (BOOL)faceRectIsInsideCircle:(cv::Rect)faceRect
                   inVideoRect:(CGRect)videoRect
                           mat:(cv::Mat &)mat
{
    CGPoint faceRectCenter = CGPointMake(faceRect.x + faceRect.width/2.0,
                                         faceRect.y + faceRect.height/2.0);
    CGPoint frameCenter = CGPointMake(videoRect.origin.x + videoRect.size.width/2.0,
                                      videoRect.origin.y + videoRect.size.height/2.0);
    CGFloat centerCloseness = MAX(ABS(faceRectCenter.x - frameCenter.x),
                                  ABS(faceRectCenter.y - frameCenter.y));
    CGFloat circleRadiusInVideoFrame = mat.rows * (self.circleView.circleRadius/self.view.bounds.size.height);
    CGFloat topOfCircle = faceRectCenter.y - circleRadiusInVideoFrame;
    CGFloat bottomOfCircle = faceRectCenter.y + circleRadiusInVideoFrame;
    NSLog(@"center %f top %f bottom %f", centerCloseness, topOfCircle, bottomOfCircle);
    return (centerCloseness < FaceRectCircleMatchCenterDifferentThreshold &&
            faceRect.y > topOfCircle && (faceRect.y + faceRect.height) < bottomOfCircle);
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    self.videoCamera.outputImageOrientation = toInterfaceOrientation;
}


@end
