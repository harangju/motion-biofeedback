//
//  BFBiofeedbackMatchReferencePhase.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/16/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFBiofeedbackPhase.h"

@class BFBiofeedbackMatchReferencePhase;

@protocol BFBiofeedbackMatchReferencePhaseDelegate <NSObject>

- (void)biofeedbackMatchReferencePhaseFaceInEllipse:(BFBiofeedbackMatchReferencePhase *)biofeedbackPhase;
- (void)biofeedbackMatchReferencePhaseFaceNotInEllipse:(BFBiofeedbackMatchReferencePhase *)biofeedbackPhase;
- (void)biofeedbackMatchReferencePhase:(BFBiofeedbackMatchReferencePhase *)biofeedbackPhase
                              faceRect:(cv::Rect)faceRect;

@end

@interface BFBiofeedbackMatchReferencePhase : BFBiofeedbackPhase

@property (nonatomic) CGRect faceEllipseRectFramePortrait;
@property (nonatomic) CGRect faceEllipseRectFrameLandscape;

@property (nonatomic, weak) id <BFBiofeedbackMatchReferencePhaseDelegate> matchReferenceDelegate;

@end
