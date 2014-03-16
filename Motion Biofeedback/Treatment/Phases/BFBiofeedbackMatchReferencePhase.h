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

@end

@interface BFBiofeedbackMatchReferencePhase : BFBiofeedbackPhase

@property (nonatomic) CGRect faceEllipseRectFramePortrait;
@property (nonatomic) CGRect faceEllipseRectFrameLandscape;

@property (nonatomic, weak) id <BFBiofeedbackMatchReferencePhaseDelegate> matchReferenceDelegate;

@end
