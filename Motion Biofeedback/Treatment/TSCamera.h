//
//  TSCamera.h
//  twoSense
//
//  Created by Harang Ju on 2/25/14.
//  Copyright (c) 2014 twoSense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, TSCameraType)
{
    TSCameraTypeBack = 0,
    TSCameraTypeFront = 1,
};

typedef void (^TSCameraImageCaptureCompletionHandler)(UIImage *image);

@interface TSCamera : NSObject

+ (id)camera;
+ (id)videoCamera;

@property (nonatomic) TSCameraType cameraType;
//@property (nonatomic, strong) NSString *qualityPreset;
//@property (nonatomic) AVCaptureFlashMode *flashMode;
//@property (nonatomic) AVCaptureFocusMode *focusMode;

// AVFoundation Components
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
@property (nonatomic, strong, readonly) AVCaptureDevice *captureDevice;
@property (nonatomic, strong, readonly) AVCaptureStillImageOutput *imageOutput; // for camera
@property (nonatomic, strong, readonly) AVCaptureVideoDataOutput *videoDataOutput; // for video camera
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, readonly) BOOL isReady;
@property (nonatomic, readonly) BOOL isOn;

- (void)start;
- (void)captureImageWithCompletionHandler:(TSCameraImageCaptureCompletionHandler)completionHandler;

@end
