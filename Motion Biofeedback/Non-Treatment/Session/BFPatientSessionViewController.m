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
#import "BFPatientSessionDetailChartViewController.h"
#import "BFPatientSessionDetailListViewController.h"

static NSString * const CellIdentifier = @"SessionDetailCellIdentifier";
static NSString * const DataSegueIdentifier = @"SessionDetailInfoSegueIdentifier";

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

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"Average Sampling Rate: %.2F per second",
                                   self.session.averageSampleRate.floatValue];
            cell.detailTextLabel.text = @"";
            break;
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"Sampling Rate Standard Deviation: %.2F per second",
                                   self.session.samplingRateStandardDeviation.floatValue];
            cell.detailTextLabel.text = @"";
            break;
        case 2:
            cell.textLabel.text = @"View Data";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2)
    {
        [self performSegueWithIdentifier:DataSegueIdentifier
                                  sender:self];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:DataSegueIdentifier])
    {
        UITabBarController *tabBarController = segue.destinationViewController;
        BFPatientSessionDetailListViewController *listVC = tabBarController.viewControllers.firstObject;
        listVC.session = self.session;
        BFPatientSessionDetailChartViewController *chartVC = tabBarController.viewControllers.lastObject;
        chartVC.session = self.session;
    }
}

@end
