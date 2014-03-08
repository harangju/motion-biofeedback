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
#import "BFOpenCVTracker.h"

@interface BFViewController () <GPUImageVideoCameraDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imagePreviewView;
@property (nonatomic, weak) IBOutlet GPUImageView *previewView;

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic) cv::Mat currentMat;

@property (nonatomic, strong) BFOpenCVFaceDetector *faceDetector;
@property (nonatomic, strong) BFOpenCVEdgeDetector *edgeDetector;
@property (nonatomic, strong) BFOpenCVTracker *tracker;

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
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    // initialize detectors
    self.faceDetector = [BFOpenCVFaceDetector new];
    self.edgeDetector = [BFOpenCVEdgeDetector new];
    self.tracker = [BFOpenCVTracker new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - GPUImageVideoCamera Delegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // get mat
    cv::Mat mat = [BFOpenCVConverter matForSampleBuffer:sampleBuffer];
    transpose(mat, mat);
    
    cv::Mat output;
    [self.tracker processFrameFromFrame:mat
                                toFrame:output];
    
    self.currentMat = output;
    
//    // get face
//    std::vector<cv::Rect> faces = [self.faceDetector faceFrameFromMat:mat];
//    
//    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CGRect videoRect = CGRectMake(0.0f, 0.0f,
//                                  CVPixelBufferGetHeight(pixelBuffer),
//                                  CVPixelBufferGetWidth(pixelBuffer));
//    // display faces
//    [self displayFaces:faces
//          forVideoRect:videoRect
//      videoOrientation:AVCaptureVideoOrientationLandscapeRight
//                inView:self.view];
//    
//    if (faces.size() == 0)
//    {
//        return;
//    }
//    
//    cv::Rect faceRect = faces.front();
//    cv::Mat faceMat = mat(faceRect);
//    cv::Mat edges;
//    [self.edgeDetector getEdges:faceMat fromMat:faceMat];
//    self.currentMat = faceMat;
}

#pragma mark - IBAction

- (IBAction)captureButtonTapped:(id)sender
{
    self.imagePreviewView.image = [BFOpenCVConverter imageForMat:self.currentMat];
}

- (void)displayFaces:(const std::vector<cv::Rect> &)faces
        forVideoRect:(CGRect)rect
    videoOrientation:(AVCaptureVideoOrientation)videoOrientation
              inView:(UIView *)view
{
    NSArray *sublayers = [NSArray arrayWithArray:[view.layer sublayers]];
    NSUInteger sublayersCount = sublayers.count;
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
    
    for (int i = 0; i < faces.size(); i++)
    {
        CGRect faceRect;
        faceRect.origin.x = faces[i].x;
        faceRect.origin.y = faces[i].y;
        faceRect.size.width = faces[i].width;
        faceRect.size.height = faces[i].height;
        
        faceRect = CGRectApplyAffineTransform(faceRect, t);
        
        CALayer *featureLayer = nil;
        
        while (!featureLayer &&
               currentSublayer < sublayersCount)
        {
			CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
			if ([currentLayer.name isEqualToString:@"FaceLayer"])
            {
				featureLayer = currentLayer;
				currentLayer.hidden = NO;
			}
		}
        
        if (!featureLayer)
        {
            // Create a new feature marker layer
			featureLayer = [[CALayer alloc] init];
            featureLayer.name = @"FaceLayer";
            featureLayer.borderColor = [[UIColor redColor] CGColor];
            featureLayer.borderWidth = 5.0f;
			[self.view.layer addSublayer:featureLayer];
		}
        featureLayer.frame = faceRect;
    }
    
    [CATransaction commit];
}

@end
