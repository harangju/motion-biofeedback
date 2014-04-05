//
//  BFVisualizationBarView.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFVisualizationBarView.h"

static const CGFloat CentralBarHeight = 120;
static const CGFloat CentralBarWidth = 20;

@interface BFVisualizationBarView ()

@property (nonatomic, strong) CALayer *barLayer;
@property (nonatomic, strong) CALayer *centralBarLayer;

@end

@implementation BFVisualizationBarView

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [self setup];
}

#pragma mark - Setup

- (void)setup
{
    self.barColor = [UIColor greenColor];
    
    self.barLayer = [CALayer layer];
    self.barLayer.backgroundColor = self.barColor.CGColor;
    
    [self.layer insertSublayer:self.barLayer
                       atIndex:0];
    
    self.centralBarLayer = [CALayer layer];
    self.centralBarLayer.backgroundColor = [UIColor redColor].CGColor;
    self.centralBarLayer.opacity = 0.8;
    [self.layer insertSublayer:self.centralBarLayer
                       atIndex:0];
    self.centralBarLayer.frame = CGRectMake((self.bounds.size.width - CentralBarWidth) / 2.0,
                                            (self.bounds.size.height - CentralBarHeight) / 2.0,
                                            CentralBarWidth, CentralBarHeight);
}



#pragma mark - Setters

- (void)setHeadPosition:(CGPoint)headPosition
{
    _headPosition = headPosition;
    // something here
}

@end
