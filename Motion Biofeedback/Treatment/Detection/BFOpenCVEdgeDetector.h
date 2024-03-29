//
//  BFOpenCVEdgeDetector.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 2/26/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFOpenCVEdgeDetector : NSObject

@property (nonatomic) CGFloat lowerThreshold;
@property (nonatomic) CGFloat upperThreshold;

- (void)getEdges:(cv::Mat)edges
         fromMat:(cv::Mat)mat;

@end
