//
//  BFBiofeedbackMeasureMovementPhase.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/16/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFBiofeedbackPhase.h"

@class BFBiofeedbackMeasureMovementPhase;

@protocol BFBiofeedbackMeasureMovementPhaseDelegate <NSObject>

// this is synchronous with processFrame:videoRect:
// I made this a protocol call for consistency
- (void)biofeedbackMeasureMovementPhase:(BFBiofeedbackMeasureMovementPhase *)biofeedbackPhase
                         withNaiveDelta:(CGPoint)delta;

@end

@interface BFBiofeedbackMeasureMovementPhase : BFBiofeedbackPhase

@property (nonatomic) cv::Rect faceRect;

@property (nonatomic, weak) id <BFBiofeedbackMeasureMovementPhaseDelegate> measureMovementDelegate;

@end
