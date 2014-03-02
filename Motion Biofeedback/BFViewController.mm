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
#import "BFOpenCVFaceDetector.h"

using namespace cv;

@interface BFViewController () <GPUImageVideoCameraDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imagePreviewView;
@property (nonatomic, weak) IBOutlet GPUImageView *previewView;

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic) Mat currentMat;

@property (nonatomic, strong) BFOpenCVFaceDetector *faceDetector;

@end

@implementation BFViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // camera
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh
                                                           cameraPosition:AVCaptureDevicePositionFront];
    [self.videoCamera startCameraCapture];
    self.videoCamera.delegate = self;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [self.videoCamera addTarget:self.previewView];
    
    // initialize detectors
    self.faceDetector = [BFOpenCVFaceDetector new];
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
    
    [self.faceDetector faceFrameFromMat:mat];
    
}

#pragma mark - IBAction

- (IBAction)captureButtonTapped:(id)sender
{
    self.imagePreviewView.image = [BFOpenCVConverter imageForMat:self.currentMat];
    
}



+ (void)matHere:(cv::Mat)mat
{
    
}







- (void)displayFaces:(const std::vector<cv::Rect> &)faces
        forVideoRect:(CGRect)rect
    videoOrientation:(AVCaptureVideoOrientation)videoOrientation
              inView:(UIView *)view
{
    NSArray *sublayers = [NSArray arrayWithArray:[self.view.layer sublayers]];
    int sublayersCount = [sublayers count];
    int currentSublayer = 0;
    
    if (faces.size() > 0)
    {
        cv::Rect faceRect = faces[0];
        NSLog(@"%d %d %d %d", faceRect.x, faceRect.y, faceRect.width, faceRect.height);
    }
    
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	// hide all the face layers
	for (CALayer *layer in sublayers) {
        NSString *layerName = [layer name];
		if ([layerName isEqualToString:@"FaceLayer"])
			[layer setHidden:YES];
	}
    
    // Create transform to convert from vide frame coordinate space to view coordinate space
    CGAffineTransform t = [BFOpenCVConverter affineTransformForVideoFrame:rect
                                                              inViewFrame:view.frame
                                                              orientation:AVCaptureVideoOrientationPortrait
                                                 videoPreviewLayerGravity:AVLayerVideoGravityResizeAspectFill];
    
    for (int i = 0; i < faces.size(); i++) {
        
        CGRect faceRect;
        faceRect.origin.x = faces[i].x;
        faceRect.origin.y = faces[i].y;
        faceRect.size.width = faces[i].width;
        faceRect.size.height = faces[i].height;
        
        faceRect = CGRectApplyAffineTransform(faceRect, t);
        
        CALayer *featureLayer = nil;
        
        while (!featureLayer && (currentSublayer < sublayersCount)) {
			CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
			if ([[currentLayer name] isEqualToString:@"FaceLayer"]) {
				featureLayer = currentLayer;
				[currentLayer setHidden:NO];
			}
		}
        
        if (!featureLayer) {
            // Create a new feature marker layer
			featureLayer = [[CALayer alloc] init];
            featureLayer.name = @"FaceLayer";
            featureLayer.borderColor = [[UIColor redColor] CGColor];
            featureLayer.borderWidth = 10.0f;
			[self.view.layer addSublayer:featureLayer];
		}
        
        featureLayer.frame = faceRect;
    }
    
    [CATransaction commit];
}

@end
