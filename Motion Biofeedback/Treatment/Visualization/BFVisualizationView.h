//
//  BFVisualizationView.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFVisualizationView : UIView

// visualization
@property (nonatomic) CGPoint headPosition;

// settings
@property (nonatomic, strong) UIColor *deltaColor;
//@property (nonatomic, strong) UIColor 

@end
