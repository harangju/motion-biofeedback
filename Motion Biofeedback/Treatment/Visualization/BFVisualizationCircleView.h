//
//  BFVisualizationCircleView.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFVisualizationView.h"

@interface BFVisualizationCircleView : BFVisualizationView

@property (nonatomic) CGFloat centerCircleRadius;
@property (nonatomic) CGFloat deltaCircleRadius;
@property (nonatomic) CGFloat centerCircleWidth;
@property (nonatomic) CGFloat deltaCircleWidth;

@property (nonatomic, strong) UIColor *centerCircleColor;

- (void)drawCenterCircle;

@end
