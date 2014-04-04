//
//  BFPatientSessionDetailChartViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFPatientSessionDetailChartViewController.h"
#import "DeltaPoint.h"
//#define ARC4RANDOM_MAX 0x100000000

@interface BFPatientSessionDetailChartViewController ()

@property (nonatomic, strong) NSMutableArray *deltaPoints;

@property (nonatomic) CGFloat minimumDeltaX;

@end

@implementation BFPatientSessionDetailChartViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:183.0/256.0
                                                green:227.0/256.0
                                                 blue:228.0/256.0
                                                alpha:1];
    [self getData];
    [self setupCharts];
    [self.lineChartXView reloadData];
    [self.lineChartYView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.lineChartXView reloadData];
    [self.lineChartYView reloadData];
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
    self.lineChartXView.backgroundColor = [UIColor purpleColor];
    self.lineChartXView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.lineChartXView setState:JBChartViewStateCollapsed];
    [self.view addSubview:self.lineChartXView];
    
    self.lineChartYView = [[JBLineChartView alloc] init];
    self.lineChartYView.backgroundColor = [UIColor brownColor];
    self.lineChartYView.translatesAutoresizingMaskIntoConstraints = NO;
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
    self.lineChartXView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.lineChartXView.layer.borderWidth = 1;
    
    self.lineChartYView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.lineChartYView.layer.borderWidth = 1;
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
    }
}

#pragma mark - LineChartView DataSource

- (NSInteger)numberOfPointsInLineChartView:(JBLineChartView *)lineChartView
{
    return self.deltaPoints.count;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView heightForIndex:(NSInteger)index
{
    DeltaPoint *deltaPoint = self.deltaPoints[index];
    return deltaPoint.x.floatValue - self.minimumDeltaX;
}

- (UIColor *)lineColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor whiteColor];
}

- (CGFloat)lineWidthForLineChartView:(JBLineChartView *)lineChartView
{
    return 2;
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
