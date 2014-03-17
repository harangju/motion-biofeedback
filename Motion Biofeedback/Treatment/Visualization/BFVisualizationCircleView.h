//
//  BFVisualizationCircleView.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFVisualizationView.h"

@interface BFVisualizationCircleView : BFVisualizationView

@property (nonatomic) CGPoint circleCenter;
@property (nonatomic) CGFloat circleRadius;
@property (nonatomic) CGColorRef circleColor;

@property (nonatomic) BOOL shouldShowDeltaCircle;
@property (nonatomic) CGPoint deltaCircleCenter;
@property (nonatomic) CGFloat deltaCircleRadius;
@property (nonatomic) CGColorRef deltaCircleColor;

@end
