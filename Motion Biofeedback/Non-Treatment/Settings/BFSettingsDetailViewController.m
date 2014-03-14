//
//  BFSettingsDetailViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFSettingsDetailViewController.h"

static NSString * const CellIdentifier = @"SettingsDetailCellidentifier";

@interface BFSettingsDetailViewController ()

@end

@implementation BFSettingsDetailViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Settings

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    cell.textLabel.text = self.settings[indexPath.row];
    if (indexPath.row == self.selectedIndex)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell.accessoryType != UITableViewCellAccessoryCheckmark)
        // not selected
    {
        NSLog(@"has no checkmark");
        for (UITableViewCell *cell in self.tableView.visibleCells)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedIndex = indexPath.row;
        [self.delegate settingsDetailViewController:self
                               didSelectItemAtIndex:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
