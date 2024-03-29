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
static NSString * const SettingsNavVCIdentifier = @"BFSettingsNavVC";

@interface BFPatientListViewController () <BFAddPatientViewController>

@property (nonatomic, strong) NSMutableArray *patients;
@property (nonatomic, strong) NSIndexPath *indexPathToRemove;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

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
        self.selectedIndexPath = indexPath;
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
        Patient *patient = self.patients.firstObject;
        [self setInDetailVCPatient:patient];
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

- (void)setInDetailVCPatient:(Patient *)patient
{
    UINavigationController *patientDetailNavVC = self.splitViewController.viewControllers.lastObject;
    BFPatientDetailViewController *patientDetailVC = patientDetailNavVC.viewControllers.firstObject;
    patientDetailVC.patient = patient;
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
    NSMutableString *name = [NSMutableString string];
    if (patient.firstName)
    {
        [name appendFormat:@"%@", patient.firstName];
    }
    if (patient.lastName)
    {
        [name appendFormat:@" %@", patient.lastName];
    }
    cell.textLabel.text = name;
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

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Patient *patient = self.patients[indexPath.row];
    self.selectedIndexPath = indexPath;
    [self setInDetailVCPatient:patient];
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
        [self.patients removeObjectAtIndex:self.indexPathToRemove.row];
        // Deleting an Entity with MagicalRecord
        [patientToRemove deleteEntity];
        [self saveContext];
        // update table
        [self.tableView deleteRowsAtIndexPaths:@[self.indexPathToRemove]
                              withRowAnimation:UITableViewRowAnimationFade];
        // update detail
        if (self.selectedIndexPath == self.indexPathToRemove)
        {
            UINavigationController *masterNav = self.navigationController;
            UINavigationController *detailNav = masterNav.splitViewController.viewControllers.lastObject;
            BFPatientDetailViewController *detailVC = (BFPatientDetailViewController *)detailNav.topViewController;
            if (self.patients.count == 0)
            {
                detailVC.patient = nil;
            }
            else
            {
                Patient *patientToSelect = self.patients.firstObject;
                detailVC.patient = patientToSelect;
                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0
                                                                 inSection:0];
                [self.tableView selectRowAtIndexPath:firstIndexPath
                                            animated:YES
                                      scrollPosition:UITableViewScrollPositionTop];
            }
            [detailVC displayPatientInfo];
        }
        else if (self.selectedIndexPath.row > self.indexPathToRemove.row)
        {
            self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row - 1
                                                        inSection:self.selectedIndexPath.section];
            [self.tableView selectRowAtIndexPath:self.selectedIndexPath
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
        }
        else
        {
            [self.tableView selectRowAtIndexPath:self.selectedIndexPath
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
        }
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

- (IBAction)settingsButtonTapped:(id)sender
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:SettingsNavVCIdentifier];
    [self presentViewController:vc
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
    
    if (self.patients.count == 1)
    {
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        UINavigationController *masterNav = self.navigationController;
        UINavigationController *detailNav = masterNav.splitViewController.viewControllers.lastObject;
        BFPatientDetailViewController *detailVC = (BFPatientDetailViewController *)detailNav.topViewController;
        detailVC.patient = patient;
        [detailVC displayPatientInfo];
    }
    
    self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row + 1
                                                inSection:self.selectedIndexPath.section];
    [self.tableView selectRowAtIndexPath:self.selectedIndexPath
                                animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
}

@end
