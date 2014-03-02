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
        return mat;
    }
    else if (format == kCVPixelFormatType_32BGRA)
    {
        // For color mode a 4-channel cv::Mat is created from the BGRA data
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        unsigned char *baseaddress = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
        Mat mat(videoRect.size.height, videoRect.size.width, CV_8UC4, baseaddress, 0);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        return mat;
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

@end
