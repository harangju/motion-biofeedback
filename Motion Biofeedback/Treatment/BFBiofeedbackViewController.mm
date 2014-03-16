//
//  BFBiofeedbackViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFBiofeedbackViewController.h"
#import <GPUImage.h>
#import "BFOpenCVConverter.h"
#import "BFOpenCVTracker.h"
#import "BFOpenCVFaceDetector.h"
#import "BFVisualizationView.h"
#import "BFVisualizationBarView.h"
#import "BFVisualizationCircleView.h"
#import "BFFaceEllipseView.h"

static CGFloat FaceRectCircleMatchCenterDifferentThreshold = 40;
static const CGFloat FaceEllipseRectWidthPortrait = 700;
static const CGFloat FaceEllipseRectHeightPortrait = 800;
static const CGFloat FaceEllipseRectWidthLandscape = 600;
static const CGFloat FaceEllipseRectHeightLandscape = 700;
static CGRect FaceEllipseRectFramePortrait;
static CGRect FaceEllipseRectFrameLandscape;

@interface BFBiofeedbackViewController () <GPUImageVideoCameraDelegate>
{
    dispatch_queue_t _faceDetectionQueue;
}

// GPUImage
@property (nonatomic, weak) IBOutlet GPUImageView *previewImageView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

// OpenCV
@property (nonatomic, strong) BFOpenCVTracker *tracker;
@property (nonatomic, strong) BFOpenCVFaceDetector *faceDetector;

// Visualization
@property (nonatomic, strong) BFVisualizationView *visualizationView;

// Voice
//@property (nonatomic, strong) AVSpeechSynthesizer *voice;

// Views
@property (nonatomic, weak) IBOutlet UIButton *exitButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (nonatomic, weak) IBOutlet UIButton *beginButton;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet BFFaceEllipseView *faceEllipseView;

// States
@property (nonatomic) BOOL shouldTakeReferenceImage;
@property (nonatomic) BOOL isDetectingFace;

@end

@implementation BFBiofeedbackViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _faceDetectionQueue = dispatch_queue_create("face_detection_queue",
                                                NULL);
    [self initializeVideoCamera];
    [self initializeDetectors];
    [self initializeVisualization];
    [self initializeFaceEllipseView];
    self.previewImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.videoCamera addTarget:self.previewImageView];
    [self.videoCamera startCameraCapture];
    
    [self.view bringSubviewToFront:self.exitButton];
    [self.view bringSubviewToFront:self.beginButton];
    [self.view bringSubviewToFront:self.saveButton];
    [self.view bringSubviewToFront:self.statusLabel];
    
    if (self.isFirstSession)
    {
        self.shouldTakeReferenceImage = YES;
        self.statusLabel.text = @"Taking reference photo.";
        
    }
    else
    {
        self.statusLabel.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.view.window.windowLevel = UIWindowLevelNormal;
}

#pragma mark - Initialization

- (void)initializeVideoCamera
{
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh
                                                           cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.delegate = self;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.outputImageOrientation = self.interfaceOrientation;
}

- (void)initializeDetectors
{
    self.tracker = [BFOpenCVTracker new];
    self.faceDetector = [BFOpenCVFaceDetector new];
}

- (void)initializeVisualization
{
    if (self.visualizationType == BFVisualizationTypeBar)
    {
        self.visualizationView = [[BFVisualizationBarView alloc] initWithFrame:self.view.bounds];
    }
    else
    {
        self.visualizationView = [[BFVisualizationCircleView alloc] initWithFrame:self.view.bounds];
    }
    self.visualizationView.hidden = YES;
    [self.view addSubview:self.visualizationView];
}

- (void)initializeFaceEllipseView
{
    // calculate face rect
    CGSize viewSize = self.view.bounds.size;
    FaceEllipseRectFramePortrait = CGRectMake((viewSize.width - FaceEllipseRectWidthPortrait) / 2.0,
                                              (viewSize.height - FaceEllipseRectHeightPortrait) / 2.0,
                                              FaceEllipseRectWidthPortrait,
                                              FaceEllipseRectHeightPortrait);
    FaceEllipseRectFrameLandscape = CGRectMake((viewSize.height - FaceEllipseRectWidthLandscape) / 2.0,
                                               (viewSize.width - FaceEllipseRectHeightLandscape) / 2.0,
                                               FaceEllipseRectWidthLandscape,
                                               FaceEllipseRectHeightLandscape);
    if ([self isUpright])
    {
        self.faceEllipseView.faceEllipseRect = FaceEllipseRectFramePortrait;
    }
    else if ([self isSideways])
    {
        self.faceEllipseView.faceEllipseRect = FaceEllipseRectFrameLandscape;
    }
//    self.faceEllipseView.hidden = YES;
    [self.view addSubview:self.faceEllipseView];
}

#pragma mark - GPUImage VideoCamera Delegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // get mat
    cv::Mat mat = [BFOpenCVConverter matForSampleBuffer:sampleBuffer];
    CGRect videoRect = [self videoRectFromBuffer:sampleBuffer];
    
    // orient mat
    if ([self isUpright])
    {
        cv::transpose(mat, mat);
    }
    else if ([self isSideways])
    {
        cv::flip(mat, mat, 1);
    }
    
    // detect face
    if (!self.isDetectingFace)
    {
        self.isDetectingFace = YES;
        
        // detect face in separate thread
        __weak typeof(self) weakSelf = self;
        dispatch_async(_faceDetectionQueue, ^{
            std::vector<cv::Rect> faceRects = [self.faceDetector faceFrameFromMat:mat];
            
            // detected 1 face
            if (faceRects.size() == 1)
            {
                // process face
                [self processFaceRect:faceRects[0]
                            videoRect:videoRect];
            }
            weakSelf.isDetectingFace = NO;
        });
    }
    
    if (self.shouldTakeReferenceImage)
    {
        
    }
}

#pragma mark - Image Processing

- (void)processFaceRect:(cv::Rect)faceRect
              videoRect:(CGRect)videoRect
{
    NSLog(@"asentuh %d", [self faceRectIsInsideCircleWithFaceRect:faceRect
                                                      inVideoRect:videoRect]);
    // check if face is in ellipse
    if ([self faceRectIsInsideCircleWithFaceRect:faceRect
                                     inVideoRect:videoRect])
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             self.faceEllipseView.ellipseColor = [UIColor greenColor];
             [self.faceEllipseView setNeedsDisplay];
         }];
    }
    else
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             self.faceEllipseView.ellipseColor = [UIColor redColor];
             [self.faceEllipseView setNeedsDisplay];
         }];
    }
}

- (CGRect)videoRectFromBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CGRect videoRect = CGRectMake(0.0f, 0.0f,
                                  CVPixelBufferGetHeight(pixelBuffer),
                                  CVPixelBufferGetWidth(pixelBuffer));
    return videoRect;
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
    if ([self isUpright])
    {
        topOfEllipse = FaceEllipseRectFramePortrait.origin.y;
        bottomOfEllipse = FaceEllipseRectFramePortrait.origin.y + FaceEllipseRectFramePortrait.size.height;
        faceRectCenter.y -= 40;
        faceRect.height -= 40; // random number?
    }
    else if ([self isSideways])
    {
        topOfEllipse = FaceEllipseRectFrameLandscape.origin.y;
        bottomOfEllipse = FaceEllipseRectFrameLandscape.origin.y + FaceEllipseRectFrameLandscape.size.height;
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

#pragma mark - IBAction

- (IBAction)exitButtonTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to exit?"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (IBAction)beginButtonTapped:(id)sender
{
    
}

- (IBAction)saveButtonTapped:(id)sender
{
    
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        // should cancel session
    {
        // cancel session
        // dismiss vc
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    // camera orientation
    self.videoCamera.outputImageOrientation = toInterfaceOrientation;
    // face rect orientation
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
        toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        self.faceEllipseView.faceEllipseRect = FaceEllipseRectFramePortrait;
        NSLog(@"will rotate to portrait");
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
             toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.faceEllipseView.faceEllipseRect = FaceEllipseRectFrameLandscape;
        NSLog(@"will rotate to landscape");
    }
    [self.faceEllipseView setNeedsDisplay];
}

- (BOOL)isSideways
{
    return (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (BOOL)isUpright
{
    return (self.interfaceOrientation == UIInterfaceOrientationPortrait ||
            self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
