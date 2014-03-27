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

typedef NS_ENUM(NSInteger, BFDimension)
{
    BFDimensionX,
    BFDimensionY,
    BFDimensionXAndY,
};

typedef NS_ENUM(NSInteger, BFBiofeedbackState)
{
    BFBiofeedbackStateCapturingReference,
    BFBiofeedbackStateMatchingReference,
    BFBiofeedbackStateMeasuringMovement,
    BFBiofeedbackStateNone,
};

@class BFBiofeedbackViewController;

@protocol BFBiofeedbackViewControllerDelegate <NSObject>

- (void)biofeedbackViewController:(BFBiofeedbackViewController *)biofeedbackViewController
            didTakeReferenceImage:(UIImage *)referenceImage;
- (UIImage *)biofeedbackViewControllerHalfReferenceImage:(BFBiofeedbackViewController *)biofeedbackViewController;
- (void)biofeedbackViewController:(BFBiofeedbackViewController *)biofeedbackViewController
           didSaveWithDeltaPoints:(NSArray *)deltaPoints
                       deltaTimes:(NSArray *)deltaTimes;
- (void)biofeedbackViewControllerShouldForceQuit:(BFBiofeedbackViewController *)biofeedbackViewController;

@end

@interface BFBiofeedbackViewController : UIViewController <UIAlertViewDelegate>

// save - for transition to background
- (void)save;

// set these at start
@property (nonatomic) BFDimension dimension;
@property (nonatomic) BFVisualizationType visualizationType;
@property (nonatomic) BOOL isFirstSession;
@property (nonatomic, weak) id <BFBiofeedbackViewControllerDelegate> delegate;

@end
