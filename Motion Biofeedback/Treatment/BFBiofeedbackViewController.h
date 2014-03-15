//
//  BFBiofeedbackViewController.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/15/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BFVisualizationType)
{
    BFVisualizationTypeCircle,
    BFVisualizationTypeBar
};

@class BFBiofeedbackViewController;

@protocol BFBiofeedbackViewControllerDelegate <NSObject>

- (void)biofeedbackViowController:(BFBiofeedbackViewController *)biofeedbackViewController
            didTakeReferenceImage:(UIImage *)referenceImage;

@end

@interface BFBiofeedbackViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic) BFVisualizationType visualizationType;
@property (nonatomic) BOOL isFirstSession;

@end