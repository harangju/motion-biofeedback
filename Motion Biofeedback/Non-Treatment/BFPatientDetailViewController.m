//
//  BFPatientDetailViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFPatientDetailViewController.h"
#import "Session.h"

static NSString * const CellIdentifier = @"PatientDetailCellIdentifier";
static NSString * const SessionDetailIdentifier = @"SessionDetailIdentifier";

static const CGFloat TableViewHeightVertical = 460;
static const CGFloat TableViewHeightHorizontal = 320;

@interface BFPatientDetailViewController ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@property (nonatomic, strong) UIBarButtonItem *viewPatientsButton;
@property (nonatomic, strong) UIPopoverController *popover;

@property (nonatomic, strong) NSArray *sessions;

@end

@implementation BFPatientDetailViewController

#pragma mark - Getters/Setters

- (void)setPatient:(Patient *)patient
{
    if (_patient != patient)
    {
        _patient = patient;
        [self displayPatientInfo];
    }
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIImage *menuImage = [UIImage imageNamed:@"menu"];
//    self.viewPatientsButton = [[UIBarButtonItem alloc] initWithImage:menuImage
//                                                               style:UIBarButtonItemStylePlain
//                                                              target:self
//                                                              action:@selector(patientButtonTapped:)];
//    if (self.interfaceOrientation == UIInterfaceOrientationPortrait ||
//        self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
//    {
//        self.navigationItem.leftBarButtonItem = self.viewPatientsButton;
//    }
    
    [self adjustHeightAccordingToInterfaceOrientation:self.interfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Model

- (void)displayPatientInfo
{
    self.title = [NSString stringWithFormat:@"%@ %@",
                  self.patient.firstName, self.patient.lastName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number"
                                                                     ascending:YES];
    self.sessions = [self.patient.sessions.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}

#pragma mark - Buttons

- (IBAction)startButtonTapped:(UIButton *)button
{
    
}

- (void)patientButtonTapped:(UIBarButtonItem *)item
{
    UIViewController *masterVC = self.splitViewController.viewControllers.firstObject;
    self.popover = [[UIPopoverController alloc] initWithContentViewController:masterVC];
    [self.popover presentPopoverFromBarButtonItem:item
                         permittedArrowDirections:UIPopoverArrowDirectionDown
                                         animated:YES];
}

#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sessions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    Session *session = self.sessions[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",
                           session.number];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                 session.date];
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UI

- (void)adjustHeightAccordingToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.imageHeightConstraint.constant = 300;
        self.tableViewHeightConstraint.constant = TableViewHeightHorizontal;
        self.navigationItem.leftBarButtonItem = nil;
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        self.imageHeightConstraint.constant = 400;
        self.tableViewHeightConstraint.constant = TableViewHeightVertical;
        self.navigationItem.leftBarButtonItem = self.viewPatientsButton;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [self adjustHeightAccordingToInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SessionDetailIdentifier])
    {
        
    }
}

@end
