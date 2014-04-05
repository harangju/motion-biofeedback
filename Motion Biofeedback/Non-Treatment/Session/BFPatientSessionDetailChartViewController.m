//
//  BFPatientSessionDetailChartViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFPatientSessionDetailChartViewController.h"
#import "DeltaPoint.h"
#import "JBChartHeaderView.h"
#import "JBLineChartFooterView.h"
#import "JBChartInformationView.h"

#define kJBNumericDefaultPadding 10.0f
#define kJBNumericDefaultAnimationDuration 0.25f

CGFloat const kJBLineChartViewControllerChartHeight = 250.0f;
CGFloat const kJBLineChartViewControllerChartHeaderHeight = 75.0f;
CGFloat const kJBLineChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kJBLineChartViewControllerChartFooterHeight = 20.0f;
CGFloat const kJBLineChartViewControllerChartLineWidth = 6.0f;

static NSDateFormatter *_dateFormatter;

@interface BFPatientSessionDetailChartViewController ()

@property (nonatomic, strong) NSMutableArray *deltaPoints;

@property (nonatomic) CGFloat minimumDeltaX;
@property (nonatomic) CGFloat minimumDeltaY;

@property (nonatomic, strong) JBChartInformationView *informationXView;
@property (nonatomic, strong) JBChartInformationView *informationYView;

@end

@implementation BFPatientSessionDetailChartViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.dateFormat = @"HH:mm:ss.SSS";
    
    [self getData];
    [self setupCharts];
    [self.view layoutIfNeeded];
    [self setupHeadersAndFooters];
    [self setupInfoViews];
    
    [self.lineChartXView reloadData];
    [self.lineChartYView reloadData];
    [self.lineChartXView setState:JBChartViewStateCollapsed
                         animated:NO];
    [self.lineChartYView setState:JBChartViewStateCollapsed
                         animated:NO];
    
    [self.view bringSubviewToFront:self.lineChartXView];
    [self.view bringSubviewToFront:self.lineChartYView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.lineChartXView setState:JBChartViewStateExpanded
                         animated:YES];
    [self.lineChartYView setState:JBChartViewStateExpanded
                         animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup

- (void)setupCharts
{
    self.lineChartXView = [[JBLineChartView alloc] init];
//    self.lineChartXView.backgroundColor = [UIColor clearColor];
    self.lineChartXView.translatesAutoresizingMaskIntoConstraints = NO;
    self.lineChartXView.showsVerticalSelection = YES;
    self.lineChartXView.headerPadding = kJBLineChartViewControllerChartHeaderPadding;
    [self.lineChartXView setState:JBChartViewStateCollapsed];
    [self.view addSubview:self.lineChartXView];
    
    self.lineChartYView = [[JBLineChartView alloc] init];
//    self.lineChartYView.backgroundColor = [UIColor clearColor];
    self.lineChartYView.translatesAutoresizingMaskIntoConstraints = NO;
    self.lineChartYView.showsVerticalSelection = YES;
    self.lineChartYView.headerPadding = kJBLineChartViewControllerChartHeaderPadding;
    [self.lineChartYView setState:JBChartViewStateCollapsed];
    [self.view addSubview:self.lineChartYView];
    
    // layout
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartXView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:70]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartXView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:8]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartXView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-8]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartXView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:-8]];
    // layout - y view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartYView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:8]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartYView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:8]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartYView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-8]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartYView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-70]];
    
    self.lineChartXView.dataSource = self;
    self.lineChartXView.delegate = self;
    
    self.lineChartYView.dataSource = self;
    self.lineChartYView.delegate = self;
    
    // debugging
    self.lineChartXView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.lineChartXView.layer.borderWidth = 1;
    
    self.lineChartYView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.lineChartYView.layer.borderWidth = 1;
}

- (void)setupHeadersAndFooters
{
    // headers
    JBChartHeaderView *headerXView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(kJBNumericDefaultPadding,
                                                                                         ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartHeaderHeight * 0.5),
                                                                                         self.view.bounds.size.width - (kJBNumericDefaultPadding * 2),
                                                                                         kJBLineChartViewControllerChartHeaderHeight)];
    headerXView.titleLabel.text = @"Horizontal Delta Values (mm)";
    headerXView.titleLabel.textColor = [UIColor whiteColor];
    headerXView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerXView.titleLabel.shadowOffset = CGSizeMake(0, 1);
    headerXView.subtitleLabel.text = @"touch graph to see more";
    headerXView.subtitleLabel.textColor = [UIColor whiteColor];
    headerXView.subtitleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerXView.subtitleLabel.shadowOffset = CGSizeMake(0, 1);
    headerXView.separatorColor = [UIColor whiteColor];
    self.lineChartXView.headerView = headerXView;
    
    // headers
    JBChartHeaderView *headerYView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(kJBNumericDefaultPadding,
                                                                                         ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartHeaderHeight * 0.5),
                                                                                         self.view.bounds.size.width - (kJBNumericDefaultPadding * 2),
                                                                                         kJBLineChartViewControllerChartHeaderHeight)];
    headerYView.titleLabel.text = @"Vertical Delta Values (mm)";
    headerYView.titleLabel.textColor = [UIColor whiteColor];
    headerYView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerYView.titleLabel.shadowOffset = CGSizeMake(0, 1);
    headerYView.subtitleLabel.text = @"touch graph to see more";
    headerYView.subtitleLabel.textColor = [UIColor whiteColor];
    headerYView.subtitleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerYView.subtitleLabel.shadowOffset = CGSizeMake(0, 1);
    headerYView.separatorColor = [UIColor whiteColor];
    self.lineChartYView.headerView = headerYView;
}

- (void)getData
{
    // get delta points
    self.deltaPoints = self.session.deltaPoints.allObjects.mutableCopy;
    // sort delta points
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp"
                                                                     ascending:YES];
    [self.deltaPoints sortUsingDescriptors:@[sortDescriptor]];
    // find minimum values
    for (DeltaPoint *deltaPoint in self.deltaPoints)
    {
        if (deltaPoint.x.floatValue < self.minimumDeltaX)
        {
            self.minimumDeltaX = deltaPoint.x.floatValue;
        }
        if (deltaPoint.y.floatValue < self.minimumDeltaY)
        {
            self.minimumDeltaY = deltaPoint.y.floatValue;
        }
    }
}

- (void)setupInfoViews
{
    self.informationXView = [[JBChartInformationView alloc] initWithFrame:self.lineChartYView.frame];
    [self.informationXView setValueAndUnitTextColor:[UIColor whiteColor]];
    [self.informationXView setTitleTextColor:[UIColor whiteColor]];
    [self.informationXView setSeparatorColor:[UIColor whiteColor]];
    [self.view addSubview:self.informationXView];
    
    self.informationYView = [[JBChartInformationView alloc] initWithFrame:self.lineChartXView.frame];
    [self.informationYView setValueAndUnitTextColor:[UIColor whiteColor]];
    [self.informationYView setTitleTextColor:[UIColor whiteColor]];
    [self.informationYView setSeparatorColor:[UIColor whiteColor]];
    [self.view addSubview:self.informationYView];
}

#pragma mark - LineChartView DataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 1;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return self.deltaPoints.count;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView
   colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [UIColor whiteColor];
}

- (UIColor *)verticalSelectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor whiteColor];
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 2;
}

#pragma mark - LineChartView Delegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView
verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex
             atLineIndex:(NSUInteger)lineIndex
{
    DeltaPoint *deltaPoint = self.deltaPoints[horizontalIndex];
    CGFloat height = 0;
    if ([lineChartView isEqual:self.lineChartXView])
    {
        height = deltaPoint.x.floatValue - self.minimumDeltaX;
    }
    else if ([lineChartView isEqual:self.lineChartYView])
    {
        height = deltaPoint.y.floatValue - self.minimumDeltaY;
    }
    return height;
}

- (void)lineChartView:(JBLineChartView *)lineChartView
 didSelectLineAtIndex:(NSUInteger)lineIndex
      horizontalIndex:(NSUInteger)horizontalIndex
{
    NSLog(@"selected at index %lu", horizontalIndex);
    DeltaPoint *deltaPoint = self.deltaPoints[horizontalIndex];
    if ([lineChartView isEqual:self.lineChartXView])
    {
        NSNumber *valueNumber = deltaPoint.x;
        [self.informationXView setValueText:[NSString stringWithFormat:@"%.2f",
                                             [valueNumber floatValue]]
                                   unitText:@"mm"];
        [self.informationXView setTitleText:[NSString stringWithFormat:@"%@",
                                             [_dateFormatter stringFromDate:deltaPoint.timestamp]]];
        [self.informationXView setHidden:NO animated:YES];
        self.lineChartYView.hidden = YES;
    }
    else if ([lineChartView isEqual:self.lineChartYView])
    {
        NSNumber *valueNumber = deltaPoint.y;
        [self.informationYView setValueText:[NSString stringWithFormat:@"%.2f",
                                             [valueNumber floatValue]]
                                   unitText:@"mm"];
        [self.informationYView setTitleText:[NSString stringWithFormat:@"%@",
                                             [_dateFormatter stringFromDate:deltaPoint.timestamp]]];
        [self.informationYView setHidden:NO animated:YES];
        self.lineChartXView.hidden = YES;
    }
}

- (void)didUnselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    NSLog(@"unselected");
    if ([lineChartView isEqual:self.lineChartXView])
    {
        self.lineChartYView.hidden = NO;
        [self.informationXView setHidden:YES animated:YES];
    }
    else if ([lineChartView isEqual:self.lineChartYView])
    {
        self.lineChartXView.hidden = NO;
        [self.informationYView setHidden:YES animated:YES];
    }
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //    [self.lineChartView reloadData];
    __weak typeof(self) weakSelf = self;
    [self.lineChartXView setState:JBChartViewStateCollapsed
                         animated:YES
                         callback:^
     {
         [weakSelf.lineChartXView setState:JBChartViewStateExpanded
                                  animated:YES];
     }];
    [self.lineChartYView setState:JBChartViewStateCollapsed
                         animated:YES
                         callback:^
     {
         [weakSelf.lineChartYView setState:JBChartViewStateExpanded
                                  animated:YES];
     }];
}

@end
