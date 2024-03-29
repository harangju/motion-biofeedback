//
//  BFPatientSessionDetailChartViewController.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JBLineChartView.h>
#import "Session.h"

@interface BFPatientSessionDetailChartViewController : UIViewController <JBLineChartViewDataSource, JBLineChartViewDelegate>

@property (nonatomic, weak) Session *session;

@property (nonatomic, strong) JBLineChartView *lineChartXView;
@property (nonatomic, strong) JBLineChartView *lineChartYView;

@end
