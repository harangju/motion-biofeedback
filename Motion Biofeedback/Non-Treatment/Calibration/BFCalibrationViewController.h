//
//  BFCalibrationViewController.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/27/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>
#import "BFCalibrationRulerView.h"

@interface BFCalibrationViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *exitButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (nonatomic, weak) IBOutlet GPUImageView *previewImageView;
@property (nonatomic, weak) IBOutlet BFCalibrationRulerView *rulerView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

@end
