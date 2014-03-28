//
//  BFPatientDetailViewController.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Patient.h"

@interface BFPatientDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic, weak) Patient *patient;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *calibrateButton;
@property (nonatomic, weak) IBOutlet UISwitch *captureReferenceSwitch;

- (void)displayPatientInfo;

@end
