//
//  BFViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/1/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFViewController.h"
#import <GPUImage.h>
#import "BFOpenCVConverter.h"
#import "BFOpenCVEdgeDetector.h"

using namespace cv;

@interface BFViewController () <GPUImageVideoCameraDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imagePreviewView;
@property (nonatomic, weak) IBOutlet GPUImageView *previewView;

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic) Mat currentMat;

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
    [self.videoCamera addTarget:self.previewView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - GPUImageVideoCamera Delegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    Mat mat = [BFOpenCVConverter matForSampleBuffer:sampleBuffer];
    transpose(mat, mat);
    NSLog(@"cols %d", mat.cols);
    self.currentMat = mat;
}

#pragma mark - IBAction

- (IBAction)captureButtonTapped:(id)sender
{
    self.imagePreviewView.image = [BFOpenCVConverter imageForMat:self.currentMat];
}

@end
