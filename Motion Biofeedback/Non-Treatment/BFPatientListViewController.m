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

@interface BFPatientListViewController () <BFAddPatientViewController>

@property (nonatomic, strong) NSMutableArray *patients;

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
    self.patients = [[Patient findAll] mutableCopy];
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
    UINavigationController *patientNavVC = [self.storyboard instantiateViewControllerWithIdentifier:AddPatientNavVCIdentifier];
    BFAddPatientViewController *patientVC = patientNavVC.viewControllers.firstObject;
    patientVC.delegate = self;
    [self presentViewController:patientNavVC
                       animated:YES
                     completion:nil];
}

#pragma mark - AddPatientVC Delegate

- (void)addPatientViewController:(BFAddPatientViewController *)addPatientVC
                   didAddPatient:(Patient *)patient
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstName == %@ AND lastName == %@",
                              addPatientVC.patient.firstName,
                              addPatientVC.patient.lastName];
    Patient *newPatient = [Patient findAllWithPredicate:predicate].lastObject;
    [self.patients insertObject:newPatient
                        atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
