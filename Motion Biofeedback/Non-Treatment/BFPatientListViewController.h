//
//  BFPatientListViewController.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/13/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFPatientListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
