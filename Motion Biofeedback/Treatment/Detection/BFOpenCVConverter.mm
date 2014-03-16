//
//  BFOpenCVHelper.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 2/26/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVConverter.h"

@implementation BFOpenCVConverter

+ (Mat)matForSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    OSType format = CVPixelBufferGetPixelFormatType(pixelBuffer);
    CGRect videoRect = CGRectMake(0.0f, 0.0f,
                                  CVPixelBufferGetWidth(pixelBuffer),
                                  CVPixelBufferGetHeight(pixelBuffer));
//    Mat mat(videoRect.size.width, videoRect.size.height, );
    if (format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
    {
        // For grayscale mode, the luminance channel of the YUV data is used
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        unsigned char *baseaddress = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        Mat mat(videoRect.size.height, videoRect.size.width, CV_8UC1, baseaddress, 0);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        return mat.clone();
    }
    else if (format == kCVPixelFormatType_32BGRA)
    {
        // For color mode a 4-channel cv::Mat is created from the BGRA data
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        unsigned char *baseaddress = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
        Mat mat(videoRect.size.height, videoRect.size.width, CV_8UC4, baseaddress, 0);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        return mat.clone();
    }
    else
    {
        NSLog(@"Unsupported video format");
    }
    return Mat();
}

+ (UIImage *)imageForMat:(Mat)mat
{
    NSData *data = [NSData dataWithBytes:mat.data
                                  length:mat.elemSize() * mat.total()];
    CGColorSpaceRef colorSpace;
    if (mat.elemSize() == 1)
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else
    {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(mat.cols, //width
                                        mat.rows, //height
                                        8, //bits per component
                                        8 * mat.elemSize(), //bits per pixel
                                        mat.step[0], //bytesPerRow
                                        colorSpace, //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault, // bitmap info
                                        provider, //CGDataProviderRef
                                        NULL, //decode
                                        false, //should interpolate
                                        kCGRenderingIntentDefault //intent
                                        );
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return finalImage;
}

+ (CGAffineTransform)affineTransformForVideoFrame:(CGRect)videoFrame
                                      inViewFrame:(CGRect)viewFrame
                                      orientation:(AVCaptureVideoOrientation)videoOrientation
                         videoPreviewLayerGravity:(NSString *)videoGravity
{
    CGSize viewSize = viewFrame.size;
    CGFloat widthScale = 1.0f;
    CGFloat heightScale = 1.0f;
    
    // Move origin to center so rotation and scale are applied correctly
    CGAffineTransform t = CGAffineTransformMakeTranslation(-videoFrame.size.width / 2.0f, -videoFrame.size.height / 2.0f);
    
    switch (videoOrientation) {
        case AVCaptureVideoOrientationPortrait:
            widthScale = viewSize.width / videoFrame.size.width;
            heightScale = viewSize.height / videoFrame.size.height;
            break;
            
        case AVCaptureVideoOrientationPortraitUpsideDown:
            t = CGAffineTransformConcat(t, CGAffineTransformMakeRotation(M_PI));
            widthScale = viewSize.width / videoFrame.size.width;
            heightScale = viewSize.height / videoFrame.size.height;
            break;
            
        case AVCaptureVideoOrientationLandscapeRight:
            t = CGAffineTransformConcat(t, CGAffineTransformMakeRotation(M_PI_2));
            widthScale = viewSize.width / videoFrame.size.height;
            heightScale = viewSize.height / videoFrame.size.width;
            break;
            
        case AVCaptureVideoOrientationLandscapeLeft:
            t = CGAffineTransformConcat(t, CGAffineTransformMakeRotation(-M_PI_2));
            widthScale = viewSize.width / videoFrame.size.height;
            heightScale = viewSize.height / videoFrame.size.width;
            break;
    }
    
    // Adjust scaling to match video gravity mode of video preview
    if (videoGravity == AVLayerVideoGravityResizeAspect) {
        heightScale = MIN(heightScale, widthScale);
        widthScale = heightScale;
    }
    else if (videoGravity == AVLayerVideoGravityResizeAspectFill) {
        heightScale = MAX(heightScale, widthScale);
        widthScale = heightScale;
    }
    
    // Apply the scaling
    t = CGAffineTransformConcat(t, CGAffineTransformMakeScale(widthScale, heightScale));
    
    // Move origin back from center
    t = CGAffineTransformConcat(t, CGAffineTransformMakeTranslation(viewSize.width / 2.0f, viewSize.height / 2.0f));
    
    return t;
}

+ (void)getGrayMat:(cv::Mat &)gray
           fromMat:(cv::Mat &)input
{
    const int numChannes = input.channels();
    
    if (numChannes == 4)
    {
        cv::cvtColor(input, gray, CV_BGRA2GRAY);
    }
    else if (numChannes == 3)
    {
        cv::cvtColor(input, gray, CV_BGR2GRAY);
    }
    else if (numChannes == 1)
    {
        gray = input;
    }
}

@end
