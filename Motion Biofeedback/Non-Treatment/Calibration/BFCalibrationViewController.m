//
//  BFCalibrationViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/27/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFCalibrationViewController.h"
#import "BFSettings.h"

@interface BFCalibrationViewController () <UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (nonatomic) CGPoint pointA;
@property (nonatomic) CGPoint pointB;
@property (nonatomic) CGPoint oldPointA;
@property (nonatomic) CGPoint oldPointB;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizerA; // 1 touch
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizerB; // 2 touches

@property (nonatomic) BOOL panAWithA; // recognizer A moves point a

@property (nonatomic, strong) UIAlertView *millimeterAlertView;
@property (nonatomic, strong) UIAlertView *notANumberAlertView;
@property (nonatomic) BOOL shouldShowNotANumberAlertView;

@end

@implementation BFCalibrationViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeViews];
    [self initializeVideoCamera];
    self.previewImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.videoCamera addTarget:self.previewImageView];
    [self.videoCamera startCameraCapture];
    [self initializeGestureRecognizers];
    [self initializeModel];
    [self initializeAlertViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.view.window.windowLevel = UIWindowLevelNormal;
}

#pragma mark - Setup

- (void)initializeViews
{
    self.exitButton.layer.cornerRadius = 3;
    self.saveButton.layer.cornerRadius = 3;
}

- (void)initializeVideoCamera
{
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh
                                                           cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.outputImageOrientation = self.interfaceOrientation;
}

- (void)initializeGestureRecognizers
{
    self.panGestureRecognizerA = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(handlePanGesture:)];
    self.panGestureRecognizerA.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizerA];
    self.panGestureRecognizerA.maximumNumberOfTouches = 1;
//    self.panGestureRecognizerB = [[UIPanGestureRecognizer alloc] initWithTarget:self
//                                                                         action:@selector(handlePanGesture:)];
//    self.panGestureRecognizerB.delegate = self;
//    [self.view addGestureRecognizer:self.panGestureRecognizerB];
//    self.panGestureRecognizerB.minimumNumberOfTouches = 2;
//    self.panGestureRecognizerB.maximumNumberOfTouches = 2;
//    self.oldPointA = CGPointZero;
//    self.oldPointB = CGPointZero;
}

- (void)initializeModel
{
    self.pointA = CGPointMake(self.view.bounds.size.width / 4.0,
                              self.view.bounds.size.height / 2.0);
    self.pointB = CGPointMake(self.view.bounds.size.width / 4.0 * 3.0,
                              self.view.bounds.size.height / 2.0);
}

- (void)initializeAlertViews
{
    self.millimeterAlertView = [[UIAlertView alloc] initWithTitle:@"Enter width of object in mm"
                                                          message:@""
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Save", nil];
    self.millimeterAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [self.millimeterAlertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    self.notANumberAlertView = [[UIAlertView alloc] initWithTitle:@"Not a number"
                                                          message:@""
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
}

#pragma mark - Gestures

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if ([panGestureRecognizer isEqual:self.panGestureRecognizerA])
    {
        // get touch location
        CGPoint location = [panGestureRecognizer locationInView:self.view];
//        NSLog(@"A %f %f", location.x, location.y);
        // which point to move?
        if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            CGFloat distanceToA = sqrt((location.x - self.pointA.x)*(location.x - self.pointA.x) +
                                       (location.y - self.pointA.y)*(location.y - self.pointA.y));
            CGFloat distanceToB = sqrt((location.x - self.pointB.x)*(location.x - self.pointB.x) +
                                       (location.y - self.pointB.y)*(location.y - self.pointB.y));
            self.panAWithA = (distanceToA < distanceToB);
        }
        // get translation
        CGPoint translation = [panGestureRecognizer translationInView:self.view];
        if (self.panAWithA)
        {
            CGPoint pointA = self.pointA;
            pointA.x += translation.x;
            pointA.y += translation.y;
            self.pointA = pointA;
            self.rulerView.pointA = self.pointA;
        }
        else
        {
            CGPoint pointB = self.pointB;
            pointB.x += translation.x;
            pointB.y += translation.y;
            self.pointB = pointB;
            self.rulerView.pointB = self.pointB;
        }
        [self.rulerView setNeedsDisplay];
        [panGestureRecognizer setTranslation:CGPointZero
                                      inView:self.view];
    }
    else if ([panGestureRecognizer isEqual:self.panGestureRecognizerB])
    {
        // get touch location
        CGPoint location = CGPointZero;
        if (panGestureRecognizer.numberOfTouches == 1)
        {
            location = [panGestureRecognizer locationOfTouch:0
                                                      inView:self.view];
//            NSLog(@"one touch");
        }
        else if (panGestureRecognizer.numberOfTouches == 2)
        {
            location = [panGestureRecognizer locationOfTouch:1
                                                      inView:self.view];
//            NSLog(@"two touches");
        }
//        NSLog(@"B %f %f", location.x, location.y);
        // get translation
        CGPoint translation = [panGestureRecognizer translationInView:self.view];
        if (self.panAWithA)
            // should move B
        {
            CGPoint pointB = self.pointB;
            pointB.x += translation.x;
            pointB.y += translation.y;
            self.pointB = pointB;
            self.rulerView.pointB = self.pointB;
        }
        else
            // should move A
        {
            CGPoint pointA = self.pointA;
            pointA.x += translation.x;
            pointA.y += translation.y;
            self.pointA = pointA;
            self.rulerView.pointA = self.pointA;
        }
        [self.rulerView setNeedsDisplay];
        [panGestureRecognizer setTranslation:CGPointZero
                                      inView:self.view];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - IBAction

- (IBAction)exitButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)saveButtonTapped:(id)sender
{
    UITextField *textField = [self.millimeterAlertView textFieldAtIndex:0];
    textField.text = @"";
    [self.millimeterAlertView show];
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
//        NSLog(@"save");
//        CGFloat ratio = [BFSettings millimeterPerPixelRatio];
//        CGFloat distanceBetweenPoints = sqrt((self.pointA.x - self.pointB.x)*(self.pointA.x - self.pointB.x) +
//                                             (self.pointA.y - self.pointB.y)*(self.pointA.y - self.pointB.y));
//        self.statusLabel.text = [NSString stringWithFormat:@"%f mm", ratio * distanceBetweenPoints];
        // get text
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *text = textField.text;
        // see if it's a number
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([text rangeOfCharacterFromSet:notDigits].location == NSNotFound)
            // newString consists only of the digits 0 through 9
        {
            [self saveMillimeterToPixelRatio];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            self.shouldShowNotANumberAlertView = YES;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.shouldShowNotANumberAlertView)
    {
        [self.notANumberAlertView show];
        self.shouldShowNotANumberAlertView = NO;
    }
}

#pragma mark - Model

- (void)saveMillimeterToPixelRatio
{
    // get the millimeter
    UITextField *textField = [self.millimeterAlertView textFieldAtIndex:0];
    NSString *text = textField.text;
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [numberFormatter numberFromString:text];
    CGFloat millimeters = number.doubleValue;
    // get the pixel
#warning I should convert this into points in the image
    CGFloat distanceBetweenPoints = sqrt((self.pointA.x - self.pointB.x)*(self.pointA.x - self.pointB.x) +
                                         (self.pointA.y - self.pointB.y)*(self.pointA.y - self.pointB.y));
    // get the ratio
    CGFloat millimeterToPixelRatio = millimeters / distanceBetweenPoints;
//    NSLog(@"\nmm - %f \npx - %f \nratio %f", millimeters, distanceBetweenPoints, millimeterToPixelRatio);
    [BFSettings setMillimeterPerPixelRatio:millimeterToPixelRatio];
}

@end
