//
//  BFOpenCVTracker.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVTracker.h"

@implementation BFOpenCVTracker

#pragma mark - Setup

- (id)init
{
    self = [super init];
    if (self)
    {
        self.maxNumberOfPoints = 50;
    }
    return self;
}

#pragma mark - Image Processing

- (void)processFrameFromFrame:(const Mat &)inputFrame
                      toFrame:(Mat &)outputFrame
{
    inputFrame.copyTo(outputFrame);
    
    
}

@end
