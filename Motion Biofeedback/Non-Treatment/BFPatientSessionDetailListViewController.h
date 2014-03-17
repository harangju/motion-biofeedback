//
//  BFPatientSessionDetailListViewController.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"

@interface BFPatientSessionDetailListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) Session *session;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
