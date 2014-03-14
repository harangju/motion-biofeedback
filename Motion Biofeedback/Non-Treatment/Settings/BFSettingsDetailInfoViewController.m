//
//  BFSettingsDetailInfoViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFSettingsDetailInfoViewController.h"

@interface BFSettingsDetailInfoViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;

@end

@implementation BFSettingsDetailInfoViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.text = self.text;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
