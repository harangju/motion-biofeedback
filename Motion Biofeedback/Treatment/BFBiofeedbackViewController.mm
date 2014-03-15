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

@interface BFBiofeedbackViewController () <GPUImageVideoCameraDelegate>

// GPUImage
@property (nonatomic, weak) IBOutlet GPUImageView *previewImageView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

// OpenCV
@property (nonatomic, strong) BFOpenCVTracker *tracker;
@property (nonatomic, strong) BFOpenCVFaceDetector *faceDetector;

// Views
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (nonatomic, weak) IBOutlet UIButton *beginButton;

// States
@property (nonatomic) BOOL shouldTakeReferenceImage;

@end

@implementation BFBiofeedbackViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeVideoCamera];
    [self initializeDetectors];
    self.previewImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.videoCamera addTarget:self.previewImageView];
    [self.videoCamera startCameraCapture];
    
    if (self.isFirstSession)
    {
        self.shouldTakeReferenceImage = YES;
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

#pragma mark - GPUImage VideoCamera Delegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // get mat
    cv::Mat mat = [BFOpenCVConverter matForSampleBuffer:sampleBuffer];
    transpose(mat, mat);
    
    if (self.shouldTakeReferenceImage)
    {
        
    }
    
    
    
//
//    self.matSize = cv::Size(mat.cols, mat.rows);
//    
//    // processs video
//    [self processFrame:mat withVideoRect:[self videoRectFromBuffer:sampleBuffer]];
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
