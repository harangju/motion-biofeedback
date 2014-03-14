//
//  BFSettingsDetailViewController.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BFSettingsDetailViewController;

@protocol BFSettingsDetailViewControllerDelegate <NSObject>

- (void)settingsDetailViewController:(BFSettingsDetailViewController *)settingsDetailVC
                didSelectItemAtIndex:(NSInteger)index;
- (void)settingsDetailViewController:(BFSettingsDetailViewController *)settingsDetailVC
              didDeselectItemAtIndex:(NSInteger)index;

@end

@interface BFSettingsDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *settings;

@property (nonatomic, weak) id <BFSettingsDetailViewControllerDelegate> delegate;

@end
