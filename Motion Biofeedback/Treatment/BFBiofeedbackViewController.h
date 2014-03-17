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

typedef NS_ENUM(NSInteger, BFDimensions)
{
    BFSettingsDimensionsX,
    BFSettingsDimensionsY,
    BFSettingsDimensionsXAndY,
};

typedef NS_ENUM(NSInteger, BFBiofeedbackState)
{
    BFBiofeedbackStateCapturingReference,
    BFBiofeedbackStateMatchingReference,
    BFBiofeedbackStateMeasuringMovement,
};

@class BFBiofeedbackViewController;

@protocol BFBiofeedbackViewControllerDelegate <NSObject>

- (void)biofeedbackViewController:(BFBiofeedbackViewController *)biofeedbackViewController
            didTakeReferenceImage:(UIImage *)referenceImage;
- (UIImage *)biofeedbackViewControllerHalfReferenceImage:(BFBiofeedbackViewController *)biofeedbackViewController;

@end

@interface BFBiofeedbackViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic) BFDimensions dimensions;
@property (nonatomic) BFVisualizationType visualizationType;
@property (nonatomic) BOOL isFirstSession;

@property (nonatomic, weak) id <BFBiofeedbackViewControllerDelegate> delegate;

@end
