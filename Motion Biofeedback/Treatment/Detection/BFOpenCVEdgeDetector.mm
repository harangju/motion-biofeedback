//
//  BFOpenCVEdgeDetector.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 2/26/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFOpenCVEdgeDetector.h"

static CGFloat DefaultLowerThreshold = 50;
static CGFloat DefaultUpperThreshold = 100;

@implementation BFOpenCVEdgeDetector

- (id)init
{
    self = [super init];
    if (self) {
        if (self.lowerThreshold == 0)
        {
            self.lowerThreshold = DefaultLowerThreshold;
        }
        if (self.upperThreshold == 0)
        {
            self.upperThreshold = DefaultUpperThreshold;
        }
    }
    return self;
}

- (void)getEdges:(cv::Mat)edges
         fromMat:(cv::Mat)mat
{
    cv::GaussianBlur(mat, edges, cv::Size(5, 5), 5);
    cv::Canny(edges, edges, self.lowerThreshold, self.upperThreshold);
}

@end
