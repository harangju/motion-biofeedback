//
//  BFViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/1/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFViewController.h"
#import <GPUImage.h>

@interface BFViewController () <GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

@end

@implementation BFViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh
                                                           cameraPosition:AVCaptureDevicePositionFront];
    [self.videoCamera startCameraCapture];
    self.videoCamera.delegate = self;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    GPUImageView *previewView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:previewView];
    
    [self.videoCamera addTarget:previewView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - GPUImageVideoCamera Delegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    
}

@end
