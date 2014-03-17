//
//  BFPatientSessionDetailChartViewController.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFPatientSessionDetailChartViewController.h"
#define ARC4RANDOM_MAX 0x100000000

@interface BFPatientSessionDetailChartViewController ()

@property (nonatomic, strong) NSArray *deltaPoints;

@end

@implementation BFPatientSessionDetailChartViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lineChartView.dataSource = self;
    self.lineChartView.delegate = self;
    self.lineChartView.backgroundColor = [UIColor lightGrayColor];
    [self.lineChartView reloadData];
    
    self.deltaPoints = self.session.deltaPoints.allObjects;
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
    return (double)arc4random() / ARC4RANDOM_MAX;
}

- (UIColor *)lineColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor purpleColor];
}

@end
