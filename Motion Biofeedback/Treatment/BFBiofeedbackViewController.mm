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
#import "BFBiofeedbackMeasureMovementPhase.h"

static const CGFloat FaceEllipseRectWidthPortrait = 700;
static const CGFloat FaceEllipseRectHeightPortrait = 800;
static const CGFloat FaceEllipseRectWidthLandscape = 600;
static const CGFloat FaceEllipseRectHeightLandscape = 700;
static CGRect FaceEllipseRectFramePortrait;
static CGRect FaceEllipseRectFrameLandscape;

static const CGFloat VisualizationCircleRadius = 300;

@interface BFBiofeedbackViewController () <GPUImageVideoCameraDelegate, BFBiofeedbackPhaseDelegate, BFBiofeedbackCaptureReferencePhaseDelegate, BFBiofeedbackMatchReferencePhaseDelegate, BFBiofeedbackMeasureMovementPhaseDelegate>

// GPUImage
@property (nonatomic, weak) IBOutlet GPUImageView *previewImageView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

// Visualization
@property (nonatomic, strong) BFVisualizationView *visualizationView;
@property (nonatomic, weak) IBOutlet BFVisualizationBarView *visualizationBarView;
@property (nonatomic, weak) IBOutlet BFVisualizationCircleView *visualizationCircleView;

// Voice
//@property (nonatomic, strong) AVSpeechSynthesizer *voice;

// Views
@property (nonatomic, weak) IBOutlet UIButton *exitButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (nonatomic, weak) IBOutlet UIButton *beginButton;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIImageView *referenceImageView;
@property (nonatomic, weak) IBOutlet BFFaceEllipseView *faceEllipseView;

// Phases
@property (nonatomic, strong) BFBiofeedbackCaptureReferencePhase *captureReferencePhase;
@property (nonatomic, strong) BFBiofeedbackMatchReferencePhase *matchReferencePhase;
@property (nonatomic, strong) BFBiofeedbackMeasureMovementPhase *measureMovementPhase;
@property (nonatomic, weak) BFBiofeedbackPhase *referencePhase;

// States
@property (nonatomic) BFBiofeedbackState state;

// OpenCV
@property (nonatomic) cv::Rect faceRect;

// Model
@property (nonatomic) CGPoint faceCenter;

@end

@implementation BFBiofeedbackViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // initialization
    [self initializeVideoCamera];
    [self initializeFaceEllipseView];
    [self initializePhases];
    [self initializeVisualization];
    self.faceCenter = self.view.center;
    
    // configuration
    [self configure];
    
    // bring buttons to the front
    [self.view bringSubviewToFront:self.exitButton];
    [self.view bringSubviewToFront:self.beginButton];
    [self.view bringSubviewToFront:self.saveButton];
    [self.view bringSubviewToFront:self.statusLabel];
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
    
    // measure movement phase
    self.measureMovementPhase = [BFBiofeedbackMeasureMovementPhase new];
    self.measureMovementPhase.delegate = self;
    self.measureMovementPhase.measureMovementDelegate = self;
}

- (void)initializeVisualization
{
    self.visualizationCircleView.centerCircleColor = [UIColor blueColor];
    self.visualizationCircleView.deltaCircleColor = [UIColor greenColor];
    self.visualizationCircleView.centerCircleRadius = VisualizationCircleRadius;
    self.visualizationCircleView.deltaCircleRadius = VisualizationCircleRadius;
}

- (void)configure
{
    // first session
    if (self.isFirstSession && NO)
    {
        self.state = BFBiofeedbackStateCapturingReference;
        self.referencePhase = self.captureReferencePhase;
    }
    else
    {
        self.state = BFBiofeedbackStateMatchingReference;
        self.referencePhase = self.matchReferencePhase;
    }
    // visualization
    if (self.visualizationType == BFVisualizationTypeBar)
    {
        self.visualizationView = self.visualizationBarView;
    }
    else
    {
        self.visualizationView = self.visualizationCircleView;
    }
    // camera
    self.previewImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.videoCamera addTarget:self.previewImageView];
    [self.videoCamera startCameraCapture];
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
    
    if (self.state == BFBiofeedbackStateCapturingReference ||
        self.state == BFBiofeedbackStateMatchingReference)
    {
        [self.referencePhase processFrame:mat
                                videoRect:videoRect];
    }
    else if (self.state == BFBiofeedbackStateMeasuringMovement)
    {
        cv::Mat faceMat = mat(self.faceRect);
        [self.measureMovementPhase processFrame:faceMat
                                      videoRect:videoRect];
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

#pragma mark - Biofeedback Phase Delegate

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
    if (self.state == BFBiofeedbackStateCapturingReference)
    {
        NSLog(@"captured reference image");
        [self.delegate biofeedbackViewController:self
                           didTakeReferenceImage:referenceImage];
        __weak typeof(self) weakSelf = self;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             weakSelf.beginButton.hidden = NO;
             weakSelf.statusLabel.text = @"Tap Begin to begin";
         }];
    }
}

- (void)biofeedbackCaptureReferencePhaseFaceInEllipse:(BFBiofeedbackCaptureReferencePhase *)biofeedbackPhase
{
    if (self.state == BFBiofeedbackStateCapturingReference)
    {
        NSLog(@"capture - face in ellipse");
        __weak typeof(self) weakSelf = self;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [weakSelf showThatFaceIsInCircle];
         }];
    }
}

- (void)biofeedbackCaptureReferencePhaseFaceNotInEllipse:(BFBiofeedbackCaptureReferencePhase *)biofeedbackPhase
{
    if (self.state == BFBiofeedbackStateCapturingReference)
    {
        NSLog(@"capture - face not in ellipse");
        __weak typeof(self) weakSelf = self;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [weakSelf showThatFaceIsNotInCircle];
             weakSelf.beginButton.hidden = YES;
         }];
    }
}

- (void)biofeedbackCaptureReferencePhase:(BFBiofeedbackCaptureReferencePhase *)biofeedbackPhase
                                faceRect:(cv::Rect)faceRect
{
    if (self.state == BFBiofeedbackStateCapturingReference)
    {
        self.faceRect = faceRect;
    }
}

#pragma mark - Match Reference Biofeedback Phase Delegate

- (void)biofeedbackMatchReferencePhaseFaceInEllipse:(BFBiofeedbackMatchReferencePhase *)biofeedbackPhase
{
    if (self.state == BFBiofeedbackStateMatchingReference)
    {
        NSLog(@"match - face in ellipse");
        __weak typeof(self) weakSelf = self;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [weakSelf showThatFaceIsInCircle];
             weakSelf.referenceImageView.image = [self.delegate biofeedbackViewControllerHalfReferenceImage:self];
             weakSelf.beginButton.hidden = NO;
         }];
    }
}

- (void)biofeedbackMatchReferencePhaseFaceNotInEllipse:(BFBiofeedbackMatchReferencePhase *)biofeedbackPhase
{
    if (self.state == BFBiofeedbackStateMatchingReference)
    {
        NSLog(@"match - face not in ellipse");
        __weak typeof(self) weakSelf = self;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [weakSelf showThatFaceIsNotInCircle];
             weakSelf.referenceImageView.image = nil;
             weakSelf.beginButton.hidden = YES;
         }];
    }
}

- (void)biofeedbackMatchReferencePhase:(BFBiofeedbackMatchReferencePhase *)biofeedbackPhase
                              faceRect:(cv::Rect)faceRect
{
    if (self.state == BFBiofeedbackStateMatchingReference)
    {
        self.faceRect = faceRect;
    }
}

#pragma mark - Measure Movement Biofeedback Phase Delegate

- (void)biofeedbackMeasureMovementPhase:(BFBiofeedbackMeasureMovementPhase *)biofeedbackPhase
                         withNaiveDelta:(CGPoint)delta
{
    if (self.state == BFBiofeedbackStateMeasuringMovement)
    {
        NSLog(@"delta %d %d", (int)delta.x, (int)delta.y);
        
        // adjust faceCenter
        
        // save faceCenter
        
        // set faceCenter
        __weak typeof(self) weakSelf = self;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             weakSelf.visualizationView.headPosition = weakSelf.faceCenter;
             [weakSelf.visualizationView setNeedsDisplay];
         }];
    }
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

- (void)displayMeasuringMovementUI
{
    [self.videoCamera removeTarget:self.previewImageView];
    self.faceEllipseView.hidden = YES;
    self.previewImageView.hidden = YES;
    self.referenceImageView.hidden = YES;
    self.beginButton.hidden = YES;
    self.saveButton.hidden = NO;
    self.statusLabel.text = @"";
    self.visualizationView.hidden = NO;
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
    self.state = BFBiofeedbackStateMeasuringMovement;
    self.referencePhase.delegate = nil;
    [self displayMeasuringMovementUI];
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
