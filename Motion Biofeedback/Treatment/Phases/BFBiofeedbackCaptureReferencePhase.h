//
//  BFBiofeedbackCaptureReferencePhase.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/16/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFBiofeedbackPhase.h"

@class BFBiofeedbackCaptureReferencePhase;

@protocol BFBiofeedbackCaptureReferencePhaseDelegate <NSObject>

- (void)biofeedbackCaptureReferencePhase:(BFBiofeedbackCaptureReferencePhase *)biofeedbackPhase
                  capturedReferenceImage:(UIImage *)referenceImage;
- (void)biofeedbackCaptureReferencePhaseFaceInEllipse:(BFBiofeedbackCaptureReferencePhase *)biofeedbackPhase;
- (void)biofeedbackCaptureReferencePhaseFaceNotInEllipse:(BFBiofeedbackCaptureReferencePhase *)biofeedbackPhase;

@end

@interface BFBiofeedbackCaptureReferencePhase : BFBiofeedbackPhase

@property (nonatomic) CGRect faceEllipseRectFramePortrait;
@property (nonatomic) CGRect faceEllipseRectFrameLandscape;

@property (nonatomic, weak) id <BFBiofeedbackCaptureReferencePhaseDelegate> captureReferenceDelegate;

@end
