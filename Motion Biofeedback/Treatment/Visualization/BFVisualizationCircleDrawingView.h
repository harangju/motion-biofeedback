//
//  BFVisualizationCircleDrawingView.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 4/3/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFVisualizationCircleDrawingView : UIView

@property (nonatomic) CGPoint circleCenter;
@property (nonatomic) CGFloat circleRadius;
@property (nonatomic) CGFloat circleWidth;
@property (nonatomic, strong) UIColor *circleColor;

@end
