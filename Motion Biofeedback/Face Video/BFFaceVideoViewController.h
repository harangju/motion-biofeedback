//
//  BFFaceVideoViewController.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/8/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>

@interface BFFaceVideoViewController : UIViewController <GPUImageVideoCameraDelegate>

@property (nonatomic, weak) IBOutlet GPUImageView *previewImageView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

@end
