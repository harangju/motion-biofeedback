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

@end

@interface BFSettingsDetailViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSInteger row;
@property (nonatomic, strong) NSArray *settings;
@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, weak) id <BFSettingsDetailViewControllerDelegate> delegate;

@end
