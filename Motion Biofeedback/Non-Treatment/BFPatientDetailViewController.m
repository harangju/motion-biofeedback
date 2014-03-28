//
//  BFPatientDetailViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFPatientDetailViewController.h"
#import "Patient+Accessors.h"
#import "Session.h"
#import "BFBiofeedbackViewController.h"
#import "BFSettings.h"
#import "DeltaPoint.h"
#import <SVProgressHUD.h>
#import "BFAppDelegate.h"
#import "BFPatientSessionViewController.h"
#import "ReferenceImage.h"

static NSDateFormatter *_dateFormatter = nil;

static NSString * const CellIdentifier = @"PatientDetailCellIdentifier";
static NSString * const SessionDetailSegueIdentifier = @"SessionDetailSegueIdentifier";
static NSString * const BiofeedbackSegueIdentifier = @"BiofeedbackSegueIdentifier";
static NSString * const CalibrationSegueIdentifier = @"CalibrationSegueIdentifier";
static NSString * const PopoverStoryboardID = @"PatientListNavVC";

static const CGFloat TableViewHeightVertical = 460;
static const CGFloat TableViewHeightHorizontal = 320;

@interface BFPatientDetailViewController () <BFBiofeedbackViewControllerDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@property (nonatomic, strong) UIBarButtonItem *viewPatientsButton;
@property (nonatomic, strong) UIPopoverController *popover;

@property (nonatomic, strong) NSArray *sessions;

@property (nonatomic, strong) UIImage *referenceImage;

@end

@implementation BFPatientDetailViewController

+ (void)initialize
{
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.dateFormat = @"MMM d, yyyy, h:mm a";
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    _dateFormatter.locale = usLocale;
}

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

    self.imageView.layer.cornerRadius = 30;
    self.startButton.layer.cornerRadius = 10;
    self.calibrateButton.layer.cornerRadius = 10;
    
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
    NSMutableString *name = [NSMutableString stringWithString:@""];
    if (self.patient.firstName)
    {
        [name appendFormat:@"%@", self.patient.firstName];
    }
    if (self.patient.lastName)
    {
        [name appendFormat:@" %@", self.patient.lastName];
    }
    self.title = name;
    // load sessions
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number"
                                                                     ascending:YES];
    self.sessions = [self.patient.sessions.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
    // load image
    if (self.patient.latestImageData)
    {
        self.imageView.image = [UIImage imageWithData:self.patient.latestImageData];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.layer.borderWidth = 0;
    }
    else
    {
        self.imageView.image = [UIImage imageNamed:@"empty_profile"];
        self.imageView.backgroundColor = [UIColor lightGrayColor];
    }
    // enable/disable start button
    if (!self.patient)
    {
        self.startButton.enabled = NO;
    }
    // enable/disable switch
    if (self.patient)
    {
        if (self.patient.sessions.count == 0)
        {
            [self.captureReferenceSwitch setOn:YES animated:YES];
            self.captureReferenceSwitch.userInteractionEnabled = NO;
        }
        else
        {
            [self.captureReferenceSwitch setOn:NO animated:YES];
            self.captureReferenceSwitch.userInteractionEnabled = YES;
        }
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

- (void)patientButtonTapped:(UIBarButtonItem *)item
{
    [self.popover presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem
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
    cell.textLabel.text = [NSString stringWithFormat:@"Session #%@",
                           session.number];
    NSTimeInterval durationInSeconds = [session.endTime timeIntervalSinceDate:session.startTime];
    NSTimeInterval durationInMinutes = durationInSeconds/60;
    NSString *durationString = [NSString stringWithFormat: @"%.1f", durationInMinutes];;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\t\t%@ minutes",
                                 [_dateFormatter stringFromDate:session.startTime],
                                 durationString];
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
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        Session *session = self.sessions[indexPath.row];
        BFPatientSessionViewController *sessionViewController = segue.destinationViewController;
        sessionViewController.session = session;
    }
    else if ([segue.identifier isEqualToString:BiofeedbackSegueIdentifier])
    {
        self.view.window.windowLevel = UIWindowLevelStatusBar + 1;
        BFBiofeedbackViewController *biofeedbackVC = (BFBiofeedbackViewController *)segue.destinationViewController;
        biofeedbackVC.delegate = self;
        // set settings
        if (self.patient.sessions.count == 0)
        {
            biofeedbackVC.shouldCaptureReferenceImage = YES;
        }
        else
        {
            biofeedbackVC.shouldCaptureReferenceImage = self.captureReferenceSwitch.on;
        }
        BFSettingsDimension dimension = [BFSettings dimension];
        if (dimension == BFSettingsDimensionsX)
        {
            biofeedbackVC.dimension = BFDimensionX;
        }
        else if (dimension == BFSettingsDimensionsY)
        {
            biofeedbackVC.dimension = BFDimensionY;
        }
        else if (dimension == BFSettingsDimensionsXAndY)
        {
            biofeedbackVC.dimension = BFDimensionXAndY;
        }
        BFSettingsVisualization visualization = [BFSettings visualization];
        if (visualization == BFSettingsVisualizationCircle)
        {
            biofeedbackVC.visualizationType = BFVisualizationTypeCircle;
        }
        else if (visualization == BFSettingsVisualizationBar)
        {
            biofeedbackVC.visualizationType = BFVisualizationTypeBar;
        }
        // connect to app delegate
        BFAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        appDelegate.biofeedbackViewController = biofeedbackVC;
    }
    else if ([segue.identifier isEqualToString:CalibrationSegueIdentifier])
    {
        self.view.window.windowLevel = UIWindowLevelStatusBar + 1;
        
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
    self.referenceImage = referenceImage;
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

- (void)biofeedbackViewController:(BFBiofeedbackViewController *)biofeedbackViewController
           didSaveWithDeltaPoints:(NSArray *)deltaPoints
                       deltaTimes:(NSArray *)deltaTimes
{
    NSParameterAssert(deltaPoints.count == deltaTimes.count);
    
    // create session
    Session *session = [Session createEntity];
    session.number = @(self.patient.sessions.count + 1);
    
    // get points
    NSMutableSet *points = [NSMutableSet set];
    for (int i = 0; i < deltaPoints.count; i++)
    {
        NSValue *value = deltaPoints[i];
        CGPoint point = [value CGPointValue];
        NSNumber *timeNumber = deltaTimes[i];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeNumber.integerValue];
        DeltaPoint *deltaPoint = [DeltaPoint createEntity];
        deltaPoint.timestamp = date;
        // convert to mm
        CGFloat millimeterToPixelRatio = [BFSettings millimeterPerPixelRatio];
        if (millimeterToPixelRatio == 0) millimeterToPixelRatio = 1; // heh~
        deltaPoint.x = @(point.x * millimeterToPixelRatio);
        deltaPoint.y = @(point.y * millimeterToPixelRatio);
        [points addObject:deltaPoint];
        
        // set session start & end times
        if (i == 0)
            // first point
        {
            session.startTime = date;
        }
        else if (i == deltaPoints.count - 1)
            // last point
        {
            session.endTime = date;
        }
    }
    // add points to session
    [session addDeltaPoints:points];
    
    // get average sampling rate
    NSTimeInterval duration = [session.endTime timeIntervalSinceDate:session.startTime];
    CGFloat samplingRate = points.count / duration;
    NSLog(@"sampling rate - %f", samplingRate);
    session.averageSampleRate = @(samplingRate);
    
    // add session to patient
    [self.patient addSessionsObject:session];
    
    // add reference image
    if (self.referenceImage)
    {
        ReferenceImage *referenceImage = [ReferenceImage createEntity];
        referenceImage.timestamp = session.startTime;
        referenceImage.imageData = UIImageJPEGRepresentation(self.referenceImage,
                                                             0.9);
        [self.patient addReferenceImagesObject:referenceImage];
    }
    
    // add reference image to session
    NSArray *referenceImages = self.patient.allReferenceImages;
    ReferenceImage *referenceImage = referenceImages.firstObject;
    session.referenceImage = referenceImage;
    
    // save
    [self saveContext];
    
    // dismiss viewController
    [biofeedbackViewController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

- (void)biofeedbackViewControllerShouldForceQuit:(BFBiofeedbackViewController *)biofeedbackViewController
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [biofeedbackViewController dismissViewControllerAnimated:YES
                                                       completion:nil];
         [SVProgressHUD showErrorWithStatus:@"You have moved too far out."];
     }];
}

@end
