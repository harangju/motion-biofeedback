//
//  BFAddPatientViewController.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Patient.h"

@class BFAddPatientViewController;

@protocol BFAddPatientViewController <NSObject>

- (void)addPatientViewController:(BFAddPatientViewController *)addPatientVC
                   didAddPatient:(Patient *)patient;

@end

@interface BFAddPatientViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Patient *patient;

@property (nonatomic, weak) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameTextField;

@property (nonatomic, weak) id <BFAddPatientViewController> delegate;

@end
