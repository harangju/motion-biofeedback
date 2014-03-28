//
//  BFPatientSessionViewController.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/27/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"

@interface BFPatientSessionViewController : UIViewController <UICollectionViewDataSource>

@property (nonatomic, strong) Session *session;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end
