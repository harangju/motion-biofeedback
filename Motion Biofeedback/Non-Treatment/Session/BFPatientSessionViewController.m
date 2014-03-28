//
//  BFPatientSessionViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/27/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFPatientSessionViewController.h"
#import "BFPatientSessionReferenceImageCell.h"
#import "Patient+Accessors.h"
#import "ReferenceImage.h"

static NSString * const CellIdentifier = @"ReferenceImageCellIdentifier";

@interface BFPatientSessionViewController ()

@property (nonatomic, strong) NSArray *allReferenceImages;

@end

@implementation BFPatientSessionViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"Session #%lu",
                  self.session.number.integerValue];
    [self initializeViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initialization

- (void)initializeViews
{
    self.referenceImageView.layer.cornerRadius = 30;
    ReferenceImage *referenceImage = self.session.referenceImage;
    self.referenceImageView.image = [UIImage imageWithData:referenceImage.imageData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
