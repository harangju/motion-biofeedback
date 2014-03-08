//
//  BFOpenCVTracker.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>

using namespace cv;

// using KLT Tracking

@interface BFOpenCVTracker : NSObject

@property (nonatomic) NSInteger maxNumberOfPoints;

@property (nonatomic) Mat previousImage;

@end
