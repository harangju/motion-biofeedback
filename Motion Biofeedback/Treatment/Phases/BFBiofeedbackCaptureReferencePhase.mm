//
//  BFBiofeedbackCaptureReferencePhase.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/16/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFBiofeedbackCaptureReferencePhase.h"
#import "BFOpenCVFaceDetector.h"
#import "BFOpenCVConverter.h"

static CGFloat FaceRectCircleMatchCenterDifferentThreshold = 40;

@interface BFBiofeedbackCaptureReferencePhase ()
{
    dispatch_queue_t _faceDetectionQueue;
}

// OpenCV
@property (nonatomic, strong) BFOpenCVFaceDetector *faceDetector;

// States
@property (nonatomic) BOOL isDetectingFace;
@property (nonatomic) BOOL shouldTakeReferenceImage;
@property (nonatomic) BOOL faceLocked;
@property (nonatomic) BOOL faceInEllipse;

// Timer
@property (nonatomic, strong) NSTimer *holdTimer;

@end

@implementation BFBiofeedbackCaptureReferencePhase

#pragma mark - LifeCycle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

#pragma mark - Setup

- (void)setup
{
    // thread
    _faceDetectionQueue = dispatch_queue_create("face_detection_queue",
                                                NULL);
    // detectors
    self.faceDetector = [BFOpenCVFaceDetector new];
}

#pragma mark - Image Processing

- (void)processFrame:(cv::Mat)mat
           videoRect:(CGRect)videoRect
{
    // detect face
    if (!self.isDetectingFace)
        // if not already
    {
        self.isDetectingFace = YES;
        
        // dispatch in thread
        __weak typeof(self) weakSelf = self;
        dispatch_async(_faceDetectionQueue, ^{
            std::vector<cv::Rect> faceRects = [self.faceDetector faceFrameFromMat:mat];
            [weakSelf processFaceRects:faceRects
                             videoRect:videoRect];
            
            // reset
            weakSelf.isDetectingFace = NO;
        });
    }
    
    // get reference image
    if (self.shouldTakeReferenceImage)
    {
        UIImage *referenceImage = [BFOpenCVConverter imageForMat:mat];
        [self.captureReferenceDelegate biofeedbackCaptureReferencePhase:self
                                                 capturedReferenceImage:referenceImage];
        self.shouldTakeReferenceImage = NO;
    }
}

- (void)processFaceRects:(std::vector<cv::Rect>)faceRects
               videoRect:(CGRect)videoRect
{
    if (faceRects.size() != 1)
        // not 1 face detected
    {
        return;
    }
    
    // 1 face detected
    cv::Rect faceRect = faceRects[0];
    
    [self.captureReferenceDelegate biofeedbackCaptureReferencePhase:self
                                                           faceRect:faceRect];
    
    // check if face is in ellipse
    if ([self faceRectIsInsideCircleWithFaceRect:faceRect
                                     inVideoRect:videoRect])
    {
        // state
        self.faceInEllipse = YES;
        
        if (!self.faceLocked)
        {
            // UI
            [self.captureReferenceDelegate biofeedbackCaptureReferencePhaseFaceInEllipse:self];
            [self.delegate biofeedbackPhase:self
                         setStateWithString:@"Hold"];
            
            // timer
            if (!self.holdTimer)
            {
                self.holdTimer = [NSTimer timerWithTimeInterval:1
                                                         target:self
                                                       selector:@selector(holdTimerFired:)
                                                       userInfo:nil
                                                        repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:self.holdTimer
                                          forMode:NSDefaultRunLoopMode];
            }
        }
    }
    else
    {
        // state
        self.faceInEllipse = NO;
        self.faceLocked = NO;
        
        // UI
        [self.captureReferenceDelegate biofeedbackCaptureReferencePhaseFaceNotInEllipse:self];
        [self.delegate biofeedbackPhase:self
                     setStateWithString:@"Put face in circle"];
        
        // timer
        [self.holdTimer invalidate];
        self.holdTimer = nil;
    }
}

- (BOOL)faceRectIsInsideCircleWithFaceRect:(cv::Rect)faceRect
                               inVideoRect:(CGRect)videoRect
{
    CGPoint faceRectCenter = CGPointMake(faceRect.x + faceRect.width/2.0,
                                         faceRect.y + faceRect.height/2.0);
    CGPoint frameCenter = CGPointMake(videoRect.origin.x + videoRect.size.width/2.0,
                                      videoRect.origin.y + videoRect.size.height/2.0);
    CGFloat topOfEllipse = 0;
    CGFloat bottomOfEllipse = 0;
    if ([self.delegate biofeedbackPhaseViewIsInPortrait:self])
    {
        topOfEllipse = self.faceEllipseRectFramePortrait.origin.y;
        bottomOfEllipse = self.faceEllipseRectFramePortrait.origin.y + self.faceEllipseRectFramePortrait.size.height;
        faceRectCenter.y -= 50;
        faceRect.height -= 50; // random number?
    }
    else if ([self.delegate biofeedbackPhaseViewIsInLandscape:self])
    {
        topOfEllipse = self.faceEllipseRectFrameLandscape.origin.y;
        bottomOfEllipse = self.faceEllipseRectFrameLandscape.origin.y + self.faceEllipseRectFrameLandscape.size.height;
        CGFloat oldCenterX = frameCenter.x;
        frameCenter.x = frameCenter.y;
        frameCenter.y = oldCenterX;
    }
    CGFloat centerCloseness = MAX(ABS(faceRectCenter.x - frameCenter.x),
                                  ABS(faceRectCenter.y - frameCenter.y));
    NSLog(@"%d %d %d %d",
          (int)faceRectCenter.x, (int)frameCenter.x,
          (int)faceRectCenter.y, (int)frameCenter.y);
    BOOL faceCenterCloseToCenter = centerCloseness < FaceRectCircleMatchCenterDifferentThreshold;
    BOOL topOfFaceBelowTopOfEllipse = faceRect.y > topOfEllipse;
    BOOL bottomOfFaceAboveBottomOfElipse = faceRect.y + faceRect.height < bottomOfEllipse;
    NSLog(@"%d %d %d",
          faceCenterCloseToCenter,
          topOfFaceBelowTopOfEllipse,
          bottomOfFaceAboveBottomOfElipse);
    return faceCenterCloseToCenter && topOfFaceBelowTopOfEllipse && bottomOfFaceAboveBottomOfElipse;
}

#pragma mark - Timer

- (void)holdTimerFired:(id)sender
{
    if (self.faceInEllipse)
    {
        self.faceLocked = YES;
        self.shouldTakeReferenceImage = YES;
    }
}

@end
