//
//  BFSettingsViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFSettingsViewController.h"
#import "BFSettingsDetailViewController.h"
#import "BFSettingsDetailInfoViewController.h"
#import "BFSettings.h"

static NSString * const ContactText = @"For technical issues, contact the developer at hj4hz@virginia.edu.";
static NSString * const AcknowledgementText = @"";

static NSArray *_settings;

static NSString * const SettingsDetailVCSegue = @"SettingsDetailVCSegue";
static NSString * const SettingsDetailInfoVCSegue = @"SettingsDetailInfoVCSegue";

@interface BFSettingsViewController () <BFSettingsDetailViewControllerDelegate>

@property (nonatomic, strong) NSString *selectedSettings;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation BFSettingsViewController

+ (void)initialize
{
    _settings = @[@[@"Circle",
                    @"Bar"],
                  @[@"Horizontal (X)",
                    @"Vertical (Y)",
                    @"Horizontal & Vertical (X & Y)"]];
}

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
    NSString *segueIdentifier;
    if (indexPath.section == 0)
    {
        segueIdentifier = SettingsDetailVCSegue;
    }
    else if (indexPath.section == 1)
    {
        segueIdentifier = SettingsDetailInfoVCSegue;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedSettings = cell.textLabel.text;
    self.selectedIndexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    [self performSegueWithIdentifier:segueIdentifier
                              sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destinationVC = segue.destinationViewController;
    destinationVC.title = self.selectedSettings;
    if ([segue.identifier isEqualToString:SettingsDetailVCSegue])
    {
        BFSettingsDetailViewController *detailVC = (BFSettingsDetailViewController *)destinationVC;
        detailVC.delegate = self;
        detailVC.settings = _settings[self.selectedIndexPath.row];
        detailVC.row = self.selectedIndexPath.row;
        if (self.selectedIndexPath.row == 0)
        {
            detailVC.selectedIndex = [BFSettings visualization];
        }
        else if (self.selectedIndexPath.row == 1)
        {
            detailVC.selectedIndex = [BFSettings dimension];
        }
    }
    else if ([segue.identifier isEqualToString:SettingsDetailInfoVCSegue])
    {
        BFSettingsDetailInfoViewController *detailInfoVC = (BFSettingsDetailInfoViewController *)destinationVC;
        if (self.selectedIndexPath.row == 0)
        {
            detailInfoVC.text = ContactText;
        }
        else if (self.selectedIndexPath.row == 1)
        {
            detailInfoVC.text = AcknowledgementText;
        }
    }
}

#pragma mark - Setting Details Delegate

- (void)settingsDetailViewController:(BFSettingsDetailViewController *)settingsDetailVC
                didSelectItemAtIndex:(NSInteger)index
{
    if (settingsDetailVC.row == 0)
    {
        if (index < BFSettingsVisualizationSentry)
        {
            [BFSettings setVisualization:index];
            NSLog(@"set visualization %lu", (long)index);
        }
    }
    else if (settingsDetailVC.row == 1)
    {
        if (index < BFSettingsDimensionSentry)
        {
            [BFSettings setDimension:index];
            NSLog(@"set dimension %lu", (long)index);
        }
    }
}

@end
