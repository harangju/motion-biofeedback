//
//  BFPatientSessionDetailListViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFPatientSessionDetailListViewController.h"
#import "DeltaPoint.h"

static NSString * const CellIdentifier = @"SessionDetailListCellIdentifier";

@interface BFPatientSessionDetailListViewController ()

@property (nonatomic, strong) NSArray *deltaPoints;

@end

@implementation BFPatientSessionDetailListViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.deltaPoints = self.session.deltaPoints.allObjects;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deltaPoints.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    DeltaPoint *deltaPoint = self.deltaPoints[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"(%f, %f)",
                           deltaPoint.x.floatValue, deltaPoint.y.floatValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                 deltaPoint.timestamp];
    return cell;
}

@end
