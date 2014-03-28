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
    // load collection view
    Patient *patient = self.session.patient;
    self.allReferenceImages = patient.allReferenceImages;
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allReferenceImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BFPatientSessionReferenceImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                                                         forIndexPath:indexPath];
    ReferenceImage *referenceImage = self.allReferenceImages[indexPath.row];
    cell.imageView.image = [UIImage imageWithData:referenceImage.imageData];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
