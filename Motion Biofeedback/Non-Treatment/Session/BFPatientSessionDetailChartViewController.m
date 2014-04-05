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
@property (nonatomic) CGFloat minimumDeltaY;

@end

@implementation BFPatientSessionDetailChartViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor colorWithRed:183.0/256.0
//                                                green:227.0/256.0
//                                                 blue:228.0/256.0
//                                                alpha:1];
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self getData];
    [self setupCharts];
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.lineChartXView reloadData];
    [self.lineChartYView reloadData];
    [self.lineChartXView setState:JBChartViewStateCollapsed
                         animated:YES];
    [self.lineChartYView setState:JBChartViewStateCollapsed
                         animated:YES];
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
    self.lineChartXView.backgroundColor = [UIColor clearColor];
    self.lineChartXView.translatesAutoresizingMaskIntoConstraints = NO;
    self.lineChartXView.showsSelection = YES;
    [self.lineChartXView setState:JBChartViewStateCollapsed];
    [self.view addSubview:self.lineChartXView];
    
    self.lineChartYView = [[JBLineChartView alloc] init];
    self.lineChartYView.backgroundColor = [UIColor clearColor];
    self.lineChartYView.translatesAutoresizingMaskIntoConstraints = NO;
    self.lineChartYView.showsSelection = YES;
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
    
    // footers
    self.lineChartXView.headerView = [[UIView alloc] init];
    self.lineChartXView.headerView.backgroundColor = [UIColor purpleColor];
    self.lineChartXView.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.lineChartXView addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartXView.headerView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.lineChartXView
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:0]];
    [self.lineChartXView addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartXView.headerView
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.lineChartXView
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0
                                                                     constant:0]];
    [self.lineChartXView addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartXView.headerView
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.lineChartXView
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:0]];
    [self.lineChartXView.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.lineChartXView.headerView
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.0
                                                                                constant:10]];
    
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
        if (deltaPoint.y.floatValue < self.minimumDeltaY)
        {
            self.minimumDeltaY = deltaPoint.y.floatValue;
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

- (UIColor *)lineColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor whiteColor];
}

- (CGFloat)lineWidthForLineChartView:(JBLineChartView *)lineChartView
{
    return 2;
}

- (UIColor *)selectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor greenColor];
}

#pragma mark - LineChartView Delegate

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectChartAtIndex:(NSInteger)index
{
    NSLog(@"selected at index %lu", index);
}

- (void)lineChartView:(JBLineChartView *)lineChartView didUnselectChartAtIndex:(NSInteger)index
{
    NSLog(@"unselected at index %lu", index);
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
