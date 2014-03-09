//
//  BFFaceVideoViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFFaceVideoViewController.h"

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
    [self initializeCircleLayer];
    [self.view.layer addSublayer:self.circleLayer];
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
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
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
                                                      radius:50];
}

#pragma mark - GPUImage VideoCamera Delegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    self.videoCamera.outputImageOrientation = toInterfaceOrientation;
//    [self moveCircleLayerToPosition];
}

#pragma mark - Circle Layer

- (void)moveCircleLayerToPosition
{
//    CGPoint location = CGPointMake(self.view.bounds.size.width/2.0,
//                                   self.view.bounds.size.height/2.0);
//    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
//    {
//        location = CGPointMake(self.view.bounds.size.height/2.0,
//                               self.view.bounds.size.width/2.0);
//    }
//    self.circleLayer.center = location;
}

@end
