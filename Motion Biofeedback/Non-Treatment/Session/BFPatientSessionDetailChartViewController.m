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
    
    self.lineChartXView.dataSource = self;
    self.lineChartXView.delegate = self;
//    self.lineChartXView.backgroundColor = [UIColor clearColor];
    [self.lineChartXView reloadData];
    
    self.lineChartYView.dataSource = self;
    self.lineChartYView.delegate = self;
//    self.lineChartYView.backgroundColor = [UIColor clearColor];
    [self.lineChartYView reloadData];
    
    self.lineChartXView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.lineChartXView.layer.borderWidth = 1;
    
    self.lineChartYView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.lineChartYView.layer.borderWidth = 1;
    
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
    // reload chart
    [self.lineChartXView reloadData];
    [self.lineChartXView setState:JBChartViewStateCollapsed];
    
    [self.lineChartYView reloadData];
    [self.lineChartYView setState:JBChartViewStateCollapsed];
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
