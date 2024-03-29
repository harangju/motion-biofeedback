//
//  BFBiofeedbackViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFBiofeedbackViewController.h"
#import "BFOpenCVConverter.h"
#import "BFVisualizationView.h"
#import "BFVisualizationVectorView.h"
#import "BFVisualizationCircleView.h"
#import "BFFaceEllipseView.h"
#import "BFBiofeedbackPhase.h"
#import "BFBiofeedbackCaptureReferencePhase.h"
#import "BFBiofeedbackMatchReferencePhase.h"
#import "BFBiofeedbackMeasureMovementPhase.h"
#import "BFOpenCVColorTracker.h"
#import "TSCamera.h"
#import <AVFoundation/AVFoundation.h>
#import "BFBiofeedbackColorCalibrationPhase.h"
#import "BFOpenCVCircleTracker.h"
#import "BFSettings.h"

static const CGFloat FaceEllipseRectWidthPortrait = 700;
static const CGFloat FaceEllipseRectHeightPortrait = 800;
static const CGFloat FaceEllipseRectWidthLandscape = 600;
static const CGFloat FaceEllipseRectHeightLandscape = 700;
static CGRect FaceEllipseRectFramePortrait;
static CGRect FaceEllipseRectFrameLandscape;

static const CGFloat VisualizationCircleRadius = 300;

static const CGFloat MaximumAllowedDeltaFromCenter = 40;
static const CGFloat WarningDeltaFromCenter = 20;
static const CGFloat OffDeltaFromCenter = 5;

static const CGFloat FeedbackAmplificationFactor = 2.0;

@interface BFBiofeedbackViewController () <BFBiofeedbackPhaseDelegate, BFBiofeedbackCaptureReferencePhaseDelegate, BFBiofeedbackMatchReferencePhaseDelegate, BFBiofeedbackMeasureMovementPhaseDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, BFBiofeedbackColorCalibrationPhaseDelegate>

// GPUImage
@property (nonatomic, weak) IBOutlet UIView *previewView;

// Visualization
@property (nonatomic, strong) BFVisualizationView *visualizationView;
@property (nonatomic, weak) IBOutlet BFVisualizationVectorView *visualizationVectorView;
@property (nonatomic, weak) IBOutlet BFVisualizationCircleView *visualizationCircleView;

// Voice
@property (nonatomic, strong) AVSpeechSynthesizer *voice;

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
@property (nonatomic, strong) BFBiofeedbackColorCalibrationPhase *calibrationPhase;
@property (nonatomic, weak) BFBiofeedbackPhase *referencePhase;

// States
@property (nonatomic) BFBiofeedbackState state;
@property (nonatomic) BFSettingsDetection detectionMode;

// OpenCV
@property (nonatomic) cv::Rect faceRect;

// Model
@property (nonatomic) CGPoint faceCenter;
@property (nonatomic, strong) NSMutableArray *deltaPoints; // NSValue around CGPoints
@property (nonatomic, strong) NSMutableArray *deltaTimes; // NSNumber around NSTimeIntervals since 1970

// Camera
@property (nonatomic, strong) TSCamera *camera;

// Gestures
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;

// debugging
@property (nonatomic, strong) BFOpenCVCircleTracker *circleTracker;
@property (nonatomic, strong) BFOpenCVColorTracker *colorTracker;
@property (nonatomic, strong) UIImageView *imageView;


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
    [self initializeViews];
//    [self initializeVoice];
    [self initializeGestureRecognizers];
    self.deltaPoints = [NSMutableArray array];
    self.deltaTimes = [NSMutableArray array];
    self.faceCenter = self.view.center;
    
    // configuration
    [self configure];
    
    // bring buttons to the front
    [self.view bringSubviewToFront:self.exitButton];
    [self.view bringSubviewToFront:self.beginButton];
    [self.view bringSubviewToFront:self.saveButton];
    [self.view bringSubviewToFront:self.statusLabel];
    
#warning I should do this somewhere else
    // disable if free motion mode
    if ([BFSettings biofeedbackMode] == BFSettingsBiofeedbackModeFreeMotion)
    {
        for (UIView *view in self.view.subviews)
        {
            if (![view isKindOfClass:UIButton.class])
            {
                [view removeFromSuperview];
            }
        }
    }
    
    self.circleTracker = [BFOpenCVCircleTracker new];
    self.colorTracker = [BFOpenCVColorTracker new];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0,
                                                                   self.view.bounds.size.height/2.0,
                                                                   self.view.bounds.size.width/2.0,
                                                                   self.view.bounds.size.height/2.0)];
    [self.view addSubview:self.imageView];
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
    self.camera = [TSCamera videoCamera];
    self.camera.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.camera.videoPreviewLayer.frame = self.view.bounds;
    [self.previewView.layer insertSublayer:self.camera.videoPreviewLayer
                                        atIndex:0];
    dispatch_queue_t queue = dispatch_queue_create("video data output queue", NULL);
    [self.camera.videoDataOutput setSampleBufferDelegate:self
                                                   queue:queue];
    [self.camera start];
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
    
    // calibration phase
    self.calibrationPhase = [BFBiofeedbackColorCalibrationPhase new];
    self.calibrationPhase.delegate = self;
    self.calibrationPhase.calibrationDelegate = self;
}

- (void)initializeVisualization
{
    self.visualizationCircleView.centerCircleColor = [UIColor blueColor];
    self.visualizationCircleView.deltaColor = [UIColor greenColor];
    self.visualizationCircleView.centerCircleRadius = VisualizationCircleRadius;
    self.visualizationCircleView.deltaCircleRadius = VisualizationCircleRadius;
    [self.visualizationCircleView drawCenterCircle];
    
//    self.visualizationVectorView.barColor = [UIColor purpleColor];
}

- (void)initializeViews
{
    self.beginButton.layer.cornerRadius = 5;
    self.exitButton.layer.cornerRadius = 3;
    self.saveButton.layer.cornerRadius = 4;
}

- (void)initializeVoice
{
    self.voice = [AVSpeechSynthesizer new];
}

- (void)initializeGestureRecognizers
{
    self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
}

- (void)configure
{
    // first session
//    self.state = BFBiofeedbackStateMeasuringMovement;
    if (self.shouldCaptureReferenceImage)
    {
        self.state = BFBiofeedbackStateCapturingReference;
        self.referencePhase = self.captureReferencePhase;
    }
    else
    {
        self.state = BFBiofeedbackStateMatchingReference;
        self.referencePhase = self.matchReferencePhase;
    }
    // marker - circle
    self.detectionMode = [BFSettings detection];
    if (self.detectionMode == BFSettingsDetectionMarkerCircle)
    {
        self.state = BFBiofeedbackStateWaitingToBegin;
        self.beginButton.hidden = NO;
    }
    // visualization
    if (self.visualizationType == BFVisualizationTypeVector)
    {
        self.visualizationView = self.visualizationVectorView;
    }
    else
    {
        self.visualizationView = self.visualizationCircleView;
    }
}

#pragma mark - Video Data Output Delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
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
    
    if (self.detectionMode != BFSettingsDetectionMarkerColor)
    {
        cv::cvtColor(mat, mat, CV_BGR2GRAY);
    }
    
    BOOL debug = NO;
//    debug = YES;
    
    if (debug)
    {
        cv::Rect rect = cv::Rect(180 + 180/2, 320 + 320/2,
                                 360 - 180/2, 640 - 320/2);
        mat = mat(rect);
//        cv::cvtColor(mat, mat, CV_BGR2GRAY);
//        cv::cvtColor(mat, mat, CV_BGR2GRAY);
        cv::Mat filteredMat(mat.rows, mat.cols, CV_8UC1, cv::Scalar(0,0,255));
        [self.colorTracker processFrameFromFrame:mat toFrame:filteredMat];
//        [self.circleTracker processFrameFromFrame:mat toFrame:filteredMat];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             UIImage *image = [BFOpenCVConverter imageForMat:filteredMat];
             self.imageView.image = image;
         }];
    }
    
    if (self.state == BFBiofeedbackStateWaitingToBegin)
    {
        
    }
    else if (self.state == BFBiofeedbackStateCapturingReference ||
        self.state == BFBiofeedbackStateMatchingReference)
    {
        [self.referencePhase processFrame:mat
                                videoRect:videoRect];
    }
    else if (self.state == BFBiofeedbackStateCalibration)
    {
        [self.calibrationPhase processFrame:mat
                                  videoRect:videoRect];
    }
    else if (self.state == BFBiofeedbackStateMeasuringMovement)
    {
        if (self.detectionMode == BFSettingsDetectionMarkerCircle)
        {
            cv::Rect rect = cv::Rect(180 + 180/2, 320 + 320/2,
                                     360 - 180/2, 640 - 320/2);
            mat = mat(rect);
            [self.measureMovementPhase processFrame:mat
                                          videoRect:videoRect];
        }
        else
        {
            cv::Mat faceMat = mat(self.faceRect);
            [self.measureMovementPhase processFrame:faceMat
                                          videoRect:videoRect];
        }
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
//             weakSelf.statusLabel.text = @"Tap Begin to begin";
//             AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Tap Begin to begin"];
//             [weakSelf.voice stopSpeakingAtBoundary:AVSpeechBoundaryWord];
//             [weakSelf.voice speakUtterance:utterance];
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
//             AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Tap Begin to begin"];
//             utterance.rate = (AVSpeechUtteranceMinimumSpeechRate + AVSpeechUtteranceDefaultSpeechRate)/2.0;
//             [weakSelf.voice stopSpeakingAtBoundary:AVSpeechBoundaryWord];
//             [weakSelf.voice speakUtterance:utterance];
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
        if (self.dimension == BFDimensionX)
        {
            CGPoint faceCenter = self.faceCenter;
            faceCenter.x += delta.x;
            self.faceCenter = faceCenter;
        }
        else if (self.dimension == BFDimensionY)
        {
            CGPoint faceCenter = self.faceCenter;
            faceCenter.y += delta.y;
            self.faceCenter = faceCenter;
        }
        else if (self.dimension == BFDimensionXAndY)
        {
            CGPoint faceCenter = self.faceCenter;
            faceCenter.x += delta.x;
            faceCenter.y += delta.y;
            self.faceCenter = faceCenter;
        }
        
        // check for maximum allowed delta
        if (MAX(ABS(self.faceCenter.x - self.view.center.x),
                ABS(self.faceCenter.y - self.view.center.y)) > MaximumAllowedDeltaFromCenter)
        {
            [self forceQuitSession];
        }
        
        // save faceCenter & time
        [self.deltaPoints addObject:[NSValue valueWithCGPoint:delta]];
        [self.deltaTimes addObject:@([[NSDate date] timeIntervalSince1970])];
        
        // set faceCenter
        __weak typeof(self) weakSelf = self;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             weakSelf.visualizationView.headPosition = weakSelf.faceCenter;
         }];
    }
}

- (void)biofeedbackMeasureMovementPhase:(BFBiofeedbackMeasureMovementPhase *)biofeedbackPhase
                      withAbsoluteDelta:(NSValue *)delta
{
    if (delta == nil)
    {
        return;
    }
    if (self.state == BFBiofeedbackStateMeasuringMovement)
    {
        NSLog(@"delta %d %d", (int)delta.CGPointValue.x, (int)delta.CGPointValue.y);
        
        CGPoint faceCenter = CGPointZero;
        UIColor *color = [UIColor greenColor];
        
        // adjust faceCenter
        if (self.dimension == BFDimensionX)
        {
            faceCenter = self.faceCenter;
            faceCenter.x += delta.CGPointValue.x;// * FeedbackAmplificationFactor;
            if (ABS(delta.CGPointValue.x) > OffDeltaFromCenter)
            {
                if (ABS(delta.CGPointValue.x) > WarningDeltaFromCenter)
                {
                    color = [UIColor redColor];
                }
                else
                {
                    color = [UIColor yellowColor];
                }
            }
        }
        else if (self.dimension == BFDimensionY)
        {
            faceCenter = self.faceCenter;
            faceCenter.y += delta.CGPointValue.y * FeedbackAmplificationFactor;
            if (ABS(delta.CGPointValue.y) > OffDeltaFromCenter)
            {
                if (ABS(delta.CGPointValue.y) > WarningDeltaFromCenter)
                {
                    color = [UIColor redColor];
                }
                else
                {
                    color = [UIColor orangeColor];
                }
            }
        }
        else if (self.dimension == BFDimensionXAndY)
        {
            faceCenter = self.faceCenter;
            faceCenter.x += delta.CGPointValue.x * FeedbackAmplificationFactor;
            faceCenter.y += delta.CGPointValue.y * FeedbackAmplificationFactor;
            if (MAX(ABS(delta.CGPointValue.x), ABS(delta.CGPointValue.y)) > OffDeltaFromCenter)
            {
                if (MAX(ABS(delta.CGPointValue.x), ABS(delta.CGPointValue.y)) > WarningDeltaFromCenter)
                {
                    color = [UIColor redColor];
                }
                else
                {
                    color = [UIColor orangeColor];
                }
            }
        }
        
        NSLog(@"point %f %f", delta.CGPointValue.x, delta.CGPointValue.y);
        
        // check for maximum allowed delta
        if (MAX(ABS(self.faceCenter.x - self.view.center.x),
                ABS(self.faceCenter.y - self.view.center.y)) > MaximumAllowedDeltaFromCenter)
        {
            [self forceQuitSession];
        }
        
        // save faceCenter & time
        __weak typeof(self) weakSelf = self;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [weakSelf.deltaPoints addObject:delta];
             [weakSelf.deltaTimes addObject:@([NSDate timeIntervalSinceReferenceDate])];
         }];
        
        // set faceCenter
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             weakSelf.visualizationView.headPosition = faceCenter;
             weakSelf.visualizationView.deltaColor = color;
             [weakSelf.visualizationView setNeedsDisplay];
         }];
    }
}

- (void)forceQuitSession
{
    [self.camera.videoDataOutput setSampleBufferDelegate:nil queue:NULL];
    self.measureMovementPhase.delegate = nil;
    self.measureMovementPhase.measureMovementDelegate = nil;
    [self.delegate biofeedbackViewControllerShouldForceQuit:self];
}

#pragma mark - Color Calibration

- (void)biofeedbackColorCalibrationPhase:(BFBiofeedbackColorCalibrationPhase *)biofeedbackColorCalibrationPhase
                      didFindPixelRadius:(NSInteger)pixelRadius
{
    NSLog(@"calibration - pixel count: %lu", pixelRadius);
    
#warning Maybe get multiple ones and average them?
    self.state = BFBiofeedbackStateMeasuringMovement;
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
    self.faceEllipseView.hidden = YES;
    self.previewView.alpha = 0.3;
    self.referenceImageView.hidden = YES;
    self.beginButton.hidden = YES;
    self.saveButton.hidden = NO;
    self.statusLabel.text = @"";
    self.visualizationView.hidden = NO;
}

#pragma mark - Gestures

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    NSLog(@"pinch gesture with scale %f", pinchGestureRecognizer.scale);
    // pinch ellipse
    CGFloat faceWidth = FaceEllipseRectWidthPortrait * pinchGestureRecognizer.scale;
    CGFloat faceHeight = FaceEllipseRectHeightPortrait * pinchGestureRecognizer.scale;
    CGRect faceEllipseRect = CGRectMake(self.view.bounds.size.width/2.0 - faceWidth/2.0,
                                        self.view.bounds.size.height/2.0 - faceHeight/2.0,
                                        faceWidth, faceHeight);
    self.faceEllipseView.faceEllipseRect = faceEllipseRect;
    [self.faceEllipseView setNeedsDisplay];
    // update detectors
    self.matchReferencePhase.faceEllipseRectFramePortrait = faceEllipseRect;
    self.captureReferencePhase.faceEllipseRectFramePortrait = faceEllipseRect;
}

#pragma mark - IBAction

- (IBAction)exitButtonTapped:(id)sender
{
    __weak typeof(self) weakSelf = self;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to exit?"
                                                        message:@""
                                                       delegate:weakSelf
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (IBAction)beginButtonTapped:(id)sender
{
    self.state = BFBiofeedbackStateMeasuringMovement;
//    self.state = BFBiofeedbackStateCalibration;
    self.referencePhase.delegate = nil;
    [self displayMeasuringMovementUI];
}

- (IBAction)saveButtonTapped:(id)sender
{
    [self save];
}

- (void)save
{
    self.state = BFBiofeedbackStateNone;
    self.measureMovementPhase.measureMovementDelegate = nil;
    [self.delegate biofeedbackViewController:self
                      didSaveWithDeltaPoints:self.deltaPoints
                                  deltaTimes:self.deltaTimes];
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        // should cancel session
    {
        // cancel session
        // dismiss vc
        self.measureMovementPhase.measureMovementDelegate = nil;
        [self.camera.videoDataOutput setSampleBufferDelegate:nil queue:NULL];
        [self.delegate biofeedbackViewControllerWantsToExit:self];
    }
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
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

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
