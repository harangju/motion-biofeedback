//
//  BFPatientListViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/13/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFPatientListViewController.h"

static NSString * const CellIdentifier = @"BFPatientListCellIdentifier";

@interface BFPatientListViewController ()

@end

@implementation BFPatientListViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    return cell;
}

@end
