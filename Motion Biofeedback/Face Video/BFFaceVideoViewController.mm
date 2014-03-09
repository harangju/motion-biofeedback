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
static CGFloat FaceCircleMaximumDifference = 30;

static CGFloat CircleRadius = 200;

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

- (void)initializeCircleView
{
    CGPoint center = CGPointMake(self.circleView.bounds.size.width/2.0,
                                 self.circleView.bounds.size.height/2.0);
    self.circleView.circleCenter = center;
    self.circleView.circleRadius = CircleRadius;
    self.circleView.deltaCircleRadius = CircleRadius;
}

#pragma mark - GPUImage VideoCamera Delegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // get mat
    cv::Mat mat = [BFOpenCVConverter matForSampleBuffer:sampleBuffer];
    transpose(mat, mat);
    
    self.matSize = cv::Size(mat.cols, mat.rows);
    
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
        // get mat in facerect
        cv::Mat matInFaceRect = mat(self.faceRect);
        
        // for debugging
//        cv::Mat output;
//        [self.tracker processFrameFromFrame:matInFaceRect
//                                    toFrame:output];
//        self.currentMat = output;
        
        // get delta
        CGPoint deltaPoint = [self.tracker naiveDeltaFromFrame:matInFaceRect];
        deltaPoint.x *= 5;
        deltaPoint.y *= 5;
        CGPoint deltaCircleCenter = self.faceRectCenterInView;
        deltaCircleCenter.x += deltaPoint.x;
        
        // doesn't work
//        if (deltaCircleCenter.x == NAN ||
//            ABS(deltaCircleCenter.x - self.circleView.circleCenter.x) > FaceCircleMaximumDifference)
//            // if head is too far out
//            // then return back
//        {
//            self.lockFaceRect = NO;
//            [self setStatesToDefault];
//            return;
//        }
        self.faceRectCenterInView = deltaCircleCenter;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             self.circleView.deltaCircleCenter = self.faceRectCenterInView;
             CGFloat delta = deltaCircleCenter.x - self.circleView.circleCenter.x;
             if (ABS(delta) < 5)
             {
                 self.circleView.circleColor = [UIColor greenColor].CGColor;
                 self.circleView.deltaCircleColor = [UIColor greenColor].CGColor;
                 self.statusLabel.text = @"Great! Stay there.";
                 self.statusLabel.textColor = [UIColor greenColor];
             }
             else
             {
                 self.circleView.circleColor = [UIColor blueColor].CGColor;
                 self.circleView.deltaCircleColor = [UIColor redColor].CGColor;
                 if (delta > 0)
                     // head moved right
                 {
                     self.statusLabel.text = @"Move your head to the left!";
                 }
                 else
                     // head moved left
                 {
                     self.statusLabel.text = @"Move your head to the right!";
                 }
                 self.statusLabel.textColor = [UIColor redColor];
             }
             [self.circleView setNeedsDisplay];
         }];
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
                self.faceRect = faceRect;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                 {
                     if (!self.readyToBegin)
                     {
                         self.circleView.circleColor = [UIColor blueColor].CGColor;
                         [self.circleView setNeedsDisplay];
                         self.statusLabel.text = @"Your face is inside the circle. Hold it there!";
                         self.statusLabel.textColor = [UIColor blueColor];
                         self.faceInCircle = YES;
                         if (!self.readyTimer)
                         {
                             self.readyTimer = [NSTimer timerWithTimeInterval:3
                                                                       target:self
                                                                     selector:@selector(checkIfReady)
                                                                     userInfo:nil
                                                                      repeats:NO];
                             [[NSRunLoop mainRunLoop] addTimer:self.readyTimer
                                                       forMode:NSDefaultRunLoopMode];
                         }
                     }
                 }];
            }
            else
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                 {
                     self.statusLabel.text = @"Position your face inside the circle.";
                     [self setStatesToDefault];
                 }];
            }
            
        }
    }
}

- (void)setStatesToDefault
{
    // circle view
    self.circleView.circleColor = [UIColor redColor].CGColor;
    self.circleView.shouldShowDeltaCircle = NO;
    [self.circleView setNeedsDisplay];
    // status label
    self.statusLabel.textColor = [UIColor redColor];
    // states
    self.faceInCircle = NO;
    self.readyToBegin = NO;
    // button
    self.startButton.hidden = YES;
    self.stopButton.hidden = YES;
    // invalidate timer
    [self.readyTimer invalidate];
    self.readyTimer = nil;
    // preview
    self.previewImageView.hidden = NO;
    if (![self.videoCamera.targets containsObject:self.previewImageView])
    {
        [self.videoCamera addTarget:self.previewImageView];
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
    return (centerCloseness < FaceRectCircleMatchCenterDifferentThreshold &&
            faceRect.y > topOfCircle && (faceRect.y + faceRect.height) < bottomOfCircle);
}

- (void)checkIfReady
{
    if (!self.faceInCircle)
    {
        NSLog(@"face not in circle - not ready");
        return;
    }
    else
    {
        NSLog(@"face in circle - ready");
        self.statusLabel.text = @"Ready? Tap the ready button to begin.";
        self.startButton.hidden = NO;
        self.readyToBegin = YES;
    }
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    self.videoCamera.outputImageOrientation = toInterfaceOrientation;
}

#pragma mark - IBAction

- (IBAction)startButtonTapped:(id)sender
{
    if (self.readyToBegin)
    {
        // move to delta mode
        self.lockFaceRect = YES;
        // remove old views
        self.previewImageView.hidden = YES;
        [self.videoCamera removeTarget:self.previewImageView];
        self.statusLabel.text = @"";
        // calculate center in view
        CGPoint faceRectCenter = CGPointMake(self.faceRect.x + self.faceRect.width/2.0,
                                             self.faceRect.y + self.faceRect.height/2.0);
        self.faceRectCenterInView = CGPointMake(faceRectCenter.x / self.matSize.width * self.view.bounds.size.width,
                                                self.circleView.circleCenter.y);
        // show delta circle
        self.circleView.shouldShowDeltaCircle = YES;
        self.circleView.circleColor = [UIColor blueColor].CGColor;
        // remove button
        self.startButton.hidden = YES;
        self.stopButton.hidden = NO;
    }
    // for debugging
    if (self.lockFaceRect)
    {
        self.imageView.image = [BFOpenCVConverter imageForMat:self.currentMat];
    }
}

- (IBAction)stopButtonTapped:(id)sender
{
    NSLog(@"stop button tapped");
}

@end
