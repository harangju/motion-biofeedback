//
//  BFPatientListViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/13/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFPatientListViewController.h"
#import "Patient.h"
#import "BFAddPatientViewController.h"

static NSString * const CellIdentifier = @"BFPatientListCellIdentifier";
static NSString * const AddPatientNavVCIdentifier = @"BFAddPatientNavVCIdentifier";

@interface BFPatientListViewController ()

@property (nonatomic, strong) NSArray *patients;

@end

@implementation BFPatientListViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchForPatients];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Set Up

- (void)fetchForPatients
{
    self.patients = [Patient findAll];
    NSLog(@"patients - %@", self.patients);
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.patients.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    Patient *patient = self.patients[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",
                           patient.firstName, patient.lastName];
    return cell;
}

#pragma mark - IBAction

- (IBAction)addButtonTapped:(id)sender
{
    BFAddPatientViewController *patientVC = [self.storyboard instantiateViewControllerWithIdentifier:AddPatientNavVCIdentifier];
    [self presentViewController:patientVC
                       animated:YES
                     completion:nil];
}

@end
