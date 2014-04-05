//
//  BFVisualizationVectorView.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 4/5/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFVisualizationVectorView.h"
#import "BFVisualizationCircleDrawingView.h"

@interface BFVisualizationVectorView ()

@property (nonatomic, strong) BFVisualizationCircleDrawingView *circleDrawingViewCenter;
@property (nonatomic, strong) BFVisualizationCircleDrawingView *circleDrawingViewDelta;

@end

@implementation BFVisualizationVectorView

#pragma mark - LifeCycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor blueColor];
}



@end
