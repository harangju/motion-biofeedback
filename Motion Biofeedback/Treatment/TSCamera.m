//
//  TSCamera.m
//  twoSense
//
//  Created by Harang Ju on 2/25/14.
//  Copyright (c) 2014 twoSense. All rights reserved.
//

#import "TSCamera.h"

@interface TSCamera ()

// AVFoundation Components
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL isReady;

@property (nonatomic) BOOL video;

@end

@implementation TSCamera

#pragma mark - Setup

+ (id)camera
{
//    static TSCamera *camera = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        camera = [[self alloc] init];
//    });
//    return camera;
    TSCamera *camera = [[TSCamera alloc] initWithVideo:NO];
    return camera;
}

+ (id)videoCamera
{
    TSCamera *camera = [[TSCamera alloc] initWithVideo:YES];
    return camera;
}

- (id)initWithVideo:(BOOL)video
{
    self = [super init];
    if (self)
    {
        self.video = video;
        [self configureCamera];
    }
    return self;
}

- (void)configureCamera
{
    // get devices
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count == 0)
    {
        NSLog(@"no camera devices found");
        return;
    }
    else
    {
//        self.captureDevice = devices[self.cameraType];
        self.captureDevice = devices[1];
    }
    
    NSLog(@"capture device - %@", self.captureDevice);
    // get the session
    self.captureSession = [AVCaptureSession new];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    // get device input
    NSError *deviceInputError;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice
                                                                         error:&deviceInputError];
    if (deviceInputError)
    {
        NSLog(@"error getting device input");
        return;
    }
    NSLog(@"capture input - %@", input);
    // get device output
    if (self.video)
    {
        self.videoDataOutput = [AVCaptureVideoDataOutput new];
        self.videoDataOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
        // add inputs & outputs to session
        if ([self.captureSession canAddInput:input])
        {
            [self.captureSession addInput:input];
        }
        if ([self.captureSession canAddOutput:self.videoDataOutput])
        {
            [self.captureSession addOutput:self.videoDataOutput];
        }
    }
    else
    {
        self.imageOutput = [AVCaptureStillImageOutput new];
        self.imageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
        NSLog(@"image output - %@", self.imageOutput);
        // add inputs & outputs to session
        if ([self.captureSession canAddInput:input])
        {
            [self.captureSession addInput:input];
        }
        if ([self.captureSession canAddOutput:self.imageOutput])
        {
            [self.captureSession addOutput:self.imageOutput];
        }
    }
    NSLog(@"done making session - %@", self.captureSession);
    // make preview layer
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    NSLog(@"made video preview layer %@", self.videoPreviewLayer);
    // ready
    self.isReady = YES;
}

#pragma mark - Capture Image

- (void)start
{
    _isOn = YES;
    [self.captureSession startRunning];
}

- (void)stop
{
    _isOn = NO;
    [self.captureSession stopRunning];
}

- (void)captureImageWithCompletionHandler:(TSCameraImageCaptureCompletionHandler)completionHandler
{
    // get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.imageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    if (!videoConnection)
    {
        
    }
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer,
                                                                      NSError *error)
     {
         // get a UIImage
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         NSLog(@"%@", image);
         // call completion handler
         if (completionHandler)
         {
             completionHandler(image);
         }
     }];
}

#pragma mark - Accessors/Getters

- (void)setCameraType:(TSCameraType)cameraType
{
    if (cameraType != self.cameraType)
    {
        self.cameraType = cameraType;
        if (self.captureSession)
        {
            NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            
            [self.captureSession beginConfiguration];
            
            [self.captureSession removeInput:[[self.captureSession inputs] lastObject]];
            
            if (self.cameraType >= 0 &&
                self.cameraType < [devices count])
            {
                self.captureDevice = [devices objectAtIndex:cameraType];
            }
            else
            {
                self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            }
            
            // Create device input
            NSError *error = nil;
            AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice
                                                                                 error:&error];
            [self.captureSession addInput:input];
            
            [self.captureSession commitConfiguration];
        }
    }
}

@end
