//
//  BFPatientDetailViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFPatientDetailViewController.h"

static NSString * const CellIdentifier = @"PatientDetailCellIdentifier";

@interface BFPatientDetailViewController ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@property (nonatomic, strong) UIBarButtonItem *viewPatientsButton;

@end

@implementation BFPatientDetailViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *menuImage = [UIImage imageNamed:@"menu"];
    self.viewPatientsButton = [[UIBarButtonItem alloc] initWithImage:menuImage
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(patientButtonTapped:)];
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait ||
        self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        self.navigationItem.leftBarButtonItem = self.viewPatientsButton;
    }
    
    self.title = [NSString stringWithFormat:@"%@ %@",
                  self.patient.firstName, self.patient.lastName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Buttons

- (IBAction)startButtonTapped:(UIButton *)button
{
    
}

- (void)patientButtonTapped:(UIBarButtonItem *)item
{
    
}

#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    return cell;
}

#pragma mark - UI

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.imageHeightConstraint.constant = 300;
        self.tableViewHeightConstraint.constant = 340;
        self.navigationItem.leftBarButtonItem = nil;
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
             toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        self.imageHeightConstraint.constant = 400;
        self.tableViewHeightConstraint.constant = 480;
        self.navigationItem.leftBarButtonItem = self.viewPatientsButton;
    }
}

@end
