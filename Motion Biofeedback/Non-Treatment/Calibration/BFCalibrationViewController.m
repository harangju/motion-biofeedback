//
//  BFCalibrationViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/27/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFCalibrationViewController.h"

@interface BFCalibrationViewController () <UIGestureRecognizerDelegate>

@property (nonatomic) CGPoint pointA;
@property (nonatomic) CGPoint pointB;
@property (nonatomic) CGPoint oldPointA;
@property (nonatomic) CGPoint oldPointB;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizerA; // 1 touch
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizerB; // 2 touches

@property (nonatomic) BOOL panAWithA; // recognizer A moves point a

@end

@implementation BFCalibrationViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeViews];
    [self initializeVideoCamera];
    self.previewImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.videoCamera addTarget:self.previewImageView];
    [self.videoCamera startCameraCapture];
    [self initializeGestureRecognizers];
    [self initializeModel];
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

#pragma mark - Setup

- (void)initializeViews
{
    self.exitButton.layer.cornerRadius = 3;
}

- (void)initializeVideoCamera
{
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh
                                                           cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.outputImageOrientation = self.interfaceOrientation;
}

- (void)initializeGestureRecognizers
{
    self.panGestureRecognizerA = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(handlePanGesture:)];
    self.panGestureRecognizerA.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizerA];
    self.panGestureRecognizerA.maximumNumberOfTouches = 1;
//    self.panGestureRecognizerB = [[UIPanGestureRecognizer alloc] initWithTarget:self
//                                                                         action:@selector(handlePanGesture:)];
//    self.panGestureRecognizerB.delegate = self;
//    [self.view addGestureRecognizer:self.panGestureRecognizerB];
//    self.panGestureRecognizerB.minimumNumberOfTouches = 2;
//    self.panGestureRecognizerB.maximumNumberOfTouches = 2;
//    self.oldPointA = CGPointZero;
//    self.oldPointB = CGPointZero;
}

- (void)initializeModel
{
    self.pointA = CGPointMake(self.view.bounds.size.width / 4.0,
                              self.view.bounds.size.height / 2.0);
    self.pointB = CGPointMake(self.view.bounds.size.width / 4.0 * 3.0,
                              self.view.bounds.size.height / 2.0);
}

#pragma mark - Gestures

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if ([panGestureRecognizer isEqual:self.panGestureRecognizerA])
    {
        // get touch location
        CGPoint location = [panGestureRecognizer locationInView:self.view];
        NSLog(@"A %f %f", location.x, location.y);
        // which point to move?
        if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            CGFloat distanceToA = sqrt((location.x - self.pointA.x)*(location.x - self.pointA.x) +
                                       (location.y - self.pointA.y)*(location.y - self.pointA.y));
            CGFloat distanceToB = sqrt((location.x - self.pointB.x)*(location.x - self.pointB.x) +
                                       (location.y - self.pointB.y)*(location.y - self.pointB.y));
            self.panAWithA = (distanceToA < distanceToB);
        }
        // get translation
        CGPoint translation = [panGestureRecognizer translationInView:self.view];
        if (self.panAWithA)
        {
            CGPoint pointA = self.pointA;
            pointA.x += translation.x;
            pointA.y += translation.y;
            self.pointA = pointA;
            self.rulerView.pointA = self.pointA;
        }
        else
        {
            CGPoint pointB = self.pointB;
            pointB.x += translation.x;
            pointB.y += translation.y;
            self.pointB = pointB;
            self.rulerView.pointB = self.pointB;
        }
        [self.rulerView setNeedsDisplay];
        [panGestureRecognizer setTranslation:CGPointZero
                                      inView:self.view];
    }
    else if ([panGestureRecognizer isEqual:self.panGestureRecognizerB])
    {
        // get touch location
        CGPoint location = CGPointZero;
        if (panGestureRecognizer.numberOfTouches == 1)
        {
            location = [panGestureRecognizer locationOfTouch:0
                                                      inView:self.view];
            NSLog(@"one touch");
        }
        else if (panGestureRecognizer.numberOfTouches == 2)
        {
            location = [panGestureRecognizer locationOfTouch:1
                                                      inView:self.view];
            NSLog(@"two touches");
        }
        NSLog(@"B %f %f", location.x, location.y);
        // get translation
        CGPoint translation = [panGestureRecognizer translationInView:self.view];
        if (self.panAWithA)
            // should move B
        {
            CGPoint pointB = self.pointB;
            pointB.x += translation.x;
            pointB.y += translation.y;
            self.pointB = pointB;
            self.rulerView.pointB = self.pointB;
        }
        else
            // should move A
        {
            CGPoint pointA = self.pointA;
            pointA.x += translation.x;
            pointA.y += translation.y;
            self.pointA = pointA;
            self.rulerView.pointA = self.pointA;
        }
        [self.rulerView setNeedsDisplay];
        [panGestureRecognizer setTranslation:CGPointZero
                                      inView:self.view];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - IBAction

- (IBAction)exitButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
