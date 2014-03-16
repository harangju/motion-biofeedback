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
@property (nonatomic, strong) BFFaceEllipseView *faceEllipseView;

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
    self.faceEllipseView = [[BFFaceEllipseView alloc] initWithFrame:self.view.bounds];
//    self.faceEllipseView.hidden = YES;
    [self.view addSubview:self.faceEllipseView];
}

#pragma mark - GPUImage VideoCamera Delegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // get mat
    cv::Mat mat = [BFOpenCVConverter matForSampleBuffer:sampleBuffer];
    transpose(mat, mat);
    
    // detect face
//    if (!self.isDetectingFace)
//    {
//        self.isDetectingFace = YES;
//        __weak typeof(self) weakSelf = self;
//        dispatch_async(_faceDetectionQueue, ^{
//            std::vector<cv::Rect> faceRects = [self.faceDetector faceFrameFromMat:mat];
//            NSLog(@"aoe %lu", faceRects.size());
//            weakSelf.isDetectingFace = NO;
//        });
//    }
    
    if (self.shouldTakeReferenceImage)
    {
        
    }
}

//- (CGRect)videoRectFromBuffer:(CMSampleBufferRef)sampleBuffer
//{
//    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CGRect videoRect = CGRectMake(0.0f, 0.0f,
//                                  CVPixelBufferGetHeight(pixelBuffer),
//                                  CVPixelBufferGetWidth(pixelBuffer));
//    return videoRect;
//}

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
    self.videoCamera.outputImageOrientation = toInterfaceOrientation;
}

@end
