//
//  BFPatientDetailViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFPatientDetailViewController.h"
#import "Session.h"
#import "BFBiofeedbackViewController.h"

static NSString * const CellIdentifier = @"PatientDetailCellIdentifier";
static NSString * const SessionDetailSegueIdentifier = @"SessionDetailSegueIdentifier";
static NSString * const BiofeedbackSegueIdentifier = @"BiofeedbackSegueIdentifier";
static NSString * const PopoverStoryboardID = @"PatientListNavVC";

static const CGFloat TableViewHeightVertical = 460;
static const CGFloat TableViewHeightHorizontal = 320;

@interface BFPatientDetailViewController () <BFBiofeedbackViewControllerDelegate>

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
        self.startButton.enabled = YES;
    }
}

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // split vc
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // debugging
    self.imageView.layer.borderWidth = 1;
    self.imageView.layer.borderColor = [UIColor greenColor].CGColor;
    self.imageView.layer.cornerRadius = 30;
    
    [self adjustHeightAccordingToInterfaceOrientation:self.interfaceOrientation];
    
    if (!self.patient)
    {
        self.startButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self displayPatientInfo];
}

#pragma mark - Model

- (void)displayPatientInfo
{
    // show name in title
    self.title = [NSString stringWithFormat:@"%@ %@",
                  self.patient.firstName, self.patient.lastName];
    // load sessions
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number"
                                                                     ascending:YES];
    self.sessions = [self.patient.sessions.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
    // load image
    if (self.patient.referenceImageData)
    {
        self.imageView.image = [UIImage imageWithData:self.patient.referenceImageData];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.layer.borderWidth = 0;
    }
    else
    {
        self.imageView.image = nil;
        self.imageView.backgroundColor = [UIColor lightGrayColor];
        self.imageView.layer.borderWidth = 1;
    }
}

- (void)saveContext
{
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreWithCompletion:^(BOOL success,
                                                                                   NSError *error)
     {
         if (success)
         {
             NSLog(@"You successfully saved your context.");
         }
         else if (error)
         {
             NSLog(@"Error saving context: %@", error.description);
         }
     }];
}

#pragma mark - Buttons

- (IBAction)startButtonTapped:(UIButton *)button
{
    
}

- (void)patientButtonTapped:(UIBarButtonItem *)item
{
    [self.popover presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem
                         permittedArrowDirections:UIPopoverArrowDirectionDown
                                         animated:YES];
}

#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.sessions.count;
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
//    Session *session = self.sessions[indexPath.row];
//    cell.textLabel.text = [NSString stringWithFormat:@"Session #%@",
//                           session.number];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
//                                 session.startTime];
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
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        self.imageHeightConstraint.constant = 400;
        self.tableViewHeightConstraint.constant = TableViewHeightVertical;
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
    if ([segue.identifier isEqualToString:SessionDetailSegueIdentifier])
    {
        
    }
    else if ([segue.identifier isEqualToString:BiofeedbackSegueIdentifier])
    {
        self.view.window.windowLevel = UIWindowLevelStatusBar + 1;
        BFBiofeedbackViewController *biofeedbackVC = (BFBiofeedbackViewController *)segue.destinationViewController;
        biofeedbackVC.delegate = self;
        if (self.patient.sessions.count == 0)
        {
            biofeedbackVC.isFirstSession = YES;
        }
    }
}

#pragma mark - SplitViewController Delegate

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    self.navigationItem.leftBarButtonItem = barButtonItem;
    barButtonItem.target = self;
    barButtonItem.action = @selector(patientButtonTapped:);
    barButtonItem.image = [UIImage imageNamed:@"menu"];
    self.popover = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - BiofeedbackViewController Delegate

- (void)biofeedbackViewController:(BFBiofeedbackViewController *)biofeedbackViewController
            didTakeReferenceImage:(UIImage *)referenceImage
{
    self.patient.referenceImageData = UIImageJPEGRepresentation(referenceImage,
                                                                0.9);
    [self saveContext];
}

- (UIImage *)biofeedbackViewControllerHalfReferenceImage:(BFBiofeedbackViewController *)biofeedbackViewController
{
    CGRect viewBounds = biofeedbackViewController.view.bounds;
    CGSize size = viewBounds.size;
    return [self imageByCroppingToRightHalf:self.imageView.image
                                     toSize:size];
}

- (UIImage *)imageByCroppingToRightHalf:(UIImage *)image toSize:(CGSize)size
{
    CGFloat x = (image.size.width - size.width) / 2.0;
    CGFloat y = (image.size.height - size.height) / 2.0;
    
    CGFloat centerX = x + (size.width - x) / 2.0;
    CGRect cropRectRightHalf = CGRectMake(centerX, y,
                                          size.width / 2.0,
                                          size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRectRightHalf);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

@end
