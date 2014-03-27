//
//  BFCalibrationViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/27/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFCalibrationViewController.h"

@interface BFCalibrationViewController ()

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

#pragma mark - IBAction

- (IBAction)exitButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
