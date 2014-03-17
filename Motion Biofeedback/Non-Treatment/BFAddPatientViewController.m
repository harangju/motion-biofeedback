//
//  BFAddPatientViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFAddPatientViewController.h"

@implementation BFAddPatientViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.patient = [Patient createEntity];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Model

- (void)saveContext
{
    id <BFAddPatientViewController> delegate = self.delegate;
    Patient *patient = self.patient;
    __weak typeof(self) weakSelf = self;
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreWithCompletion:^(BOOL success,
                                                                                   NSError *error)
     {
         if (success) {
             NSLog(@"You successfully saved your context.");
             [[NSOperationQueue mainQueue] addOperationWithBlock:^
              {
                  [delegate addPatientViewController:weakSelf
                                       didAddPatient:patient];
              }];
         } else if (error) {
             NSLog(@"Error saving context: %@", error.description);
         }
     }];
}

#pragma mark - IBAction

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)item
{
    [self.patient deleteEntity];
    [self saveContext];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)doneButtonTapped:(UIBarButtonItem *)item
{
    if (!self.firstNameTextField.text.length ||
        !self.lastNameTextField.text.length)
    {
        return;
    }
    [self.lastNameTextField resignFirstResponder];
    [self saveContext];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - TextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.firstNameTextField])
    {
        self.patient.firstName = textField.text;
    }
    else if ([textField isEqual:self.lastNameTextField])
    {
        self.patient.lastName = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.firstNameTextField])
    {
        [self.lastNameTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.lastNameTextField])
    {
        [self.lastNameTextField resignFirstResponder];
        [self saveContext];
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
    return YES;
}

@end
