//
//  BFAppDelegate.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/1/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFBiofeedbackViewController.h"

@interface BFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, weak) BFBiofeedbackViewController *biofeedbackViewController;

@end
