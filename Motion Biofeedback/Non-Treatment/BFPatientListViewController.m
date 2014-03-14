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
#import "BFPatientDetailViewController.h"

static NSString * const CellIdentifier = @"BFPatientListCellIdentifier";
static NSString * const AddPatientNavVCIdentifier = @"BFAddPatientNavVCIdentifier";

@interface BFPatientListViewController () <BFAddPatientViewController>

@property (nonatomic, strong) NSMutableArray *patients;
@property (nonatomic, strong) NSIndexPath *indexPathToRemove;

@end

@implementation BFPatientListViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchForPatients];
    [self.tableView reloadData];
    
    if (self.patients.count)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                    inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
        UINavigationController *patientDetailNavVC = self.splitViewController.viewControllers.lastObject;
        BFPatientDetailViewController *patientDetailVC = patientDetailNavVC.viewControllers.firstObject;
        patientDetailVC.patient = self.patients.firstObject;
    }
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

#pragma mark - Model

- (void)saveContext
{
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"You successfully saved your context.");
        } else if (error) {
            NSLog(@"Error saving context: %@", error.description);
        }
    }];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.indexPathToRemove = indexPath;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remove patient"
                                                            message:@"Are you sure you want to remove the patient?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Remove", nil];
        [alertView show];
    }
}
                                 
#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // ok this doesn't work but whatever
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPathToRemove];
        [cell setEditing:NO animated:YES];
    }
    else if (buttonIndex == 1) // this should be yes - for deletion
    {
        Patient *patientToRemove = self.patients[self.indexPathToRemove.row];
        // Deleting an Entity with MagicalRecord
        [patientToRemove deleteEntity];
        [self saveContext];
        [self.patients removeObjectAtIndex:self.indexPathToRemove.row];
        [self.tableView deleteRowsAtIndexPaths:@[self.indexPathToRemove]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
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
