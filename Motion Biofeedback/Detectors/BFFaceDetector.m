//
//  BFFaceDetector.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/2/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFFaceDetector.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@interface BFFaceDetector ()

@property (nonatomic, strong) CIDetector *detector;

@end

@implementation BFFaceDetector

- (id)init
{
    self = [super init];
    if (self) {
        NSDictionary *options = @{CIDetectorAccuracy: CIDetectorAccuracyLow};
        self.detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                           context:nil
                                           options:options];
    }
    return self;
}

- (CIFaceFeature *)detectFacesInCIImage:(CIImage *)image
{
    NSArray *features = [self.detector featuresInImage:image];
    if (features.firstObject)
    {
        CIFaceFeature *faceFeature = (CIFaceFeature *)features.firstObject;
        NSLog(@"%@", faceFeature);
    }
    return features.firstObject;
}

@end
