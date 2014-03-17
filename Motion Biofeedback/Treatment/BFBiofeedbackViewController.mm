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
#import "BFVisualizationView.h"
#import "BFVisualizationBarView.h"
#import "BFVisualizationCircleView.h"
#import "BFFaceEllipseView.h"
#import "BFBiofeedbackPhase.h"
#import "BFBiofeedbackCaptureReferencePhase.h"
#import "BFBiofeedbackMatchReferencePhase.h"

static NSString * const PutFaceInCircle = @"Put face inside circle";
static NSString * const HoldFace = @"Hold";

static const CGFloat FaceEllipseRectWidthPortrait = 700;
static const CGFloat FaceEllipseRectHeightPortrait = 800;
static const CGFloat FaceEllipseRectWidthLandscape = 600;
static const CGFloat FaceEllipseRectHeightLandscape = 700;
static CGRect FaceEllipseRectFramePortrait;
static CGRect FaceEllipseRectFrameLandscape;

@interface BFBiofeedbackViewController () <GPUImageVideoCameraDelegate, BFBiofeedbackPhaseDelegate, BFBiofeedbackCaptureReferencePhaseDelegate, BFBiofeedbackMatchReferencePhaseDelegate>
{
    dispatch_queue_t _faceDetectionQueue;
}

// GPUImage
@property (nonatomic, weak) IBOutlet GPUImageView *previewImageView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

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
@property (nonatomic, weak) IBOutlet UIImageView *referenceImageView;

// Phases
@property (nonatomic, strong) BFBiofeedbackCaptureReferencePhase *captureReferencePhase;
@property (nonatomic, strong) BFBiofeedbackMatchReferencePhase *matchReferencePhase;

@end

@implementation BFBiofeedbackViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _faceDetectionQueue = dispatch_queue_create("face_detection_queue",
                                                NULL);
    [self initializeVideoCamera];
    [self initializeVisualization];
    [self initializeFaceEllipseView];
    [self initializePhases];
    
    self.previewImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.videoCamera addTarget:self.previewImageView];
    [self.videoCamera startCameraCapture];
    
    [self.view bringSubviewToFront:self.exitButton];
    [self.view bringSubviewToFront:self.beginButton];
    [self.view bringSubviewToFront:self.saveButton];
    [self.view bringSubviewToFront:self.statusLabel];
    
    if (self.isFirstSession)
    {
        
    }
    else
    {
        
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
    [self.view addSubview:self.faceEllipseView];
}

- (void)initializePhases
{
    // capture reference phase
    self.captureReferencePhase = [BFBiofeedbackCaptureReferencePhase new];
    self.captureReferencePhase.delegate = self;
    self.captureReferencePhase.captureReferenceDelegate = self;
    self.captureReferencePhase.faceEllipseRectFramePortrait = FaceEllipseRectFramePortrait;
    self.captureReferencePhase.faceEllipseRectFrameLandscape = FaceEllipseRectFrameLandscape;
    
    // match referenec phase
    self.matchReferencePhase = [BFBiofeedbackMatchReferencePhase new];
    self.matchReferencePhase.delegate = self;
    self.matchReferencePhase.matchReferenceDelegate = self;
    self.matchReferencePhase.faceEllipseRectFramePortrait = FaceEllipseRectFramePortrait;
    self.matchReferencePhase.faceEllipseRectFrameLandscape = FaceEllipseRectFrameLandscape;
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
    
//    [self.captureReferencePhase processFrame:mat
//                                   videoRect:videoRect];
    
    [self.matchReferencePhase processFrame:mat
                                 videoRect:videoRect];
}

- (CGRect)videoRectFromBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CGRect videoRect = CGRectMake(0.0f, 0.0f,
                                  CVPixelBufferGetHeight(pixelBuffer),
                                  CVPixelBufferGetWidth(pixelBuffer));
    return videoRect;
}

#pragma mark - Biofeedback Phase

- (void)biofeedbackPhase:(BFBiofeedbackPhase *)biofeedbackPhase
      setStateWithString:(NSString *)string
{
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         weakSelf.statusLabel.text = string;
     }];
}

- (BOOL)biofeedbackPhaseViewIsInPortrait:(BFBiofeedbackPhase *)biofeedbackPhase
{
    return [self isUpright];
}

- (BOOL)biofeedbackPhaseViewIsInLandscape:(BFBiofeedbackPhase *)biofeedbackPhase
{
    return [self isSideways];
}

#pragma mark - Capture Reference Biofeedback Phase Delegate

- (void)biofeedbackCaptureReferencePhase:(BFBiofeedbackCaptureReferencePhase *)biofeedbackPhase
                  capturedReferenceImage:(UIImage *)referenceImage
{
    NSLog(@"captured reference image");
    [self.delegate biofeedbackViewController:self
                       didTakeReferenceImage:referenceImage];
}

- (void)biofeedbackCaptureReferencePhaseFaceInEllipse:(BFBiofeedbackCaptureReferencePhase *)biofeedbackPhase
{
    NSLog(@"capture - face in ellipse");
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [weakSelf showThatFaceIsInCircle];
     }];
}

- (void)biofeedbackCaptureReferencePhaseFaceNotInEllipse:(BFBiofeedbackCaptureReferencePhase *)biofeedbackPhase
{
    NSLog(@"capture - face not in ellipse");
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [weakSelf showThatFaceIsNotInCircle];
     }];
}

#pragma mark - Match Reference Biofeedback Phase Delegate

- (void)biofeedbackMatchReferencePhaseFaceInEllipse:(BFBiofeedbackMatchReferencePhase *)biofeedbackPhase
{
    NSLog(@"match - face in ellipse");
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [weakSelf showThatFaceIsInCircle];
         weakSelf.referenceImageView.image = [self.delegate biofeedbackViewControllerHalfReferenceImage:self];
     }];
}

- (void)biofeedbackMatchReferencePhaseFaceNotInEllipse:(BFBiofeedbackMatchReferencePhase *)biofeedbackPhase
{
    NSLog(@"match - face not in ellipse");
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [weakSelf showThatFaceIsNotInCircle];
         weakSelf.referenceImageView.image = nil;
     }];
}

#pragma mark - UI

- (void)showThatFaceIsInCircle
{
    self.faceEllipseView.ellipseColor = [UIColor greenColor];
    [self.faceEllipseView setNeedsDisplay];
}

- (void)showThatFaceIsNotInCircle
{
    self.faceEllipseView.ellipseColor = [UIColor redColor];
    [self.faceEllipseView setNeedsDisplay];
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
