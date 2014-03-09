//
//  BFCircleLayer.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface BFCircleLayer : CAShapeLayer

- (id)initAtLocation:(CGPoint)location radius:(CGFloat)radius;

@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat radius;

@end
