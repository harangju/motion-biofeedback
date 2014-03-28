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
    
    self.lineChartView.dataSource = self;
    self.lineChartView.delegate = self;
    self.lineChartView.backgroundColor = [UIColor clearColor];
    [self.lineChartView reloadData];
    
    // get delta points
    self.deltaPoints = self.session.deltaPoints.allObjects.mutableCopy;
    // sort delta points
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp"
                                                                     ascending:YES];
    [self.deltaPoints sortUsingDescriptors:@[sortDescriptor]];
    // reload chart
    [self.lineChartView reloadData];
    [self.lineChartView setState:JBChartViewStateCollapsed];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.lineChartView setState:JBChartViewStateExpanded
                        animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - LineChartView DataSource

- (NSInteger)numberOfPointsInLineChartView:(JBLineChartView *)lineChartView
{
    return self.deltaPoints.count;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView heightForIndex:(NSInteger)index
{
    DeltaPoint *deltaPoint = self.deltaPoints[index];
    return deltaPoint.x.floatValue;
}

- (UIColor *)lineColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor whiteColor];
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [self.lineChartView reloadData];
    __weak typeof(self) weakSelf = self;
    [self.lineChartView setState:JBChartViewStateCollapsed
                        animated:YES
                        callback:^
     {
         [weakSelf.lineChartView setState:JBChartViewStateExpanded
                                 animated:YES];
     }];
}

@end
