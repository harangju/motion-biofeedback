//
//  BFSettingsViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFSettingsViewController.h"
#import "BFSettingsDetailViewController.h"

static NSString * const SettingsDetailVCSegue = @"SettingsDetailVCSegue";

@interface BFSettingsViewController ()

@property (nonatomic, strong) NSString *selectedSettings;

@end

@implementation BFSettingsViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Buttons

- (IBAction)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedSettings = cell.textLabel.text;
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    [self performSegueWithIdentifier:SettingsDetailVCSegue
                              sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SettingsDetailVCSegue])
    {
        BFSettingsDetailViewController *detailVC = (BFSettingsDetailViewController *)segue.destinationViewController;
        detailVC.title = self.selectedSettings;
    }
}

@end
