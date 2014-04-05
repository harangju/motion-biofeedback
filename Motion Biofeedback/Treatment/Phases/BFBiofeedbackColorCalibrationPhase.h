//
//  BFBiofeedbackColorCalibrationPhase.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 4/5/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFBiofeedbackPhase.h"

@class BFBiofeedbackColorCalibrationPhase;

@protocol BFBiofeedbackColorCalibrationPhaseDelegate <NSObject>

- (void)biofeedbackColorCalibrationPhase:(BFBiofeedbackColorCalibrationPhase *)biofeedbackColorCalibrationPhase
                      didFindPixelRadius:(NSInteger)pixelRadius;

@end

@interface BFBiofeedbackColorCalibrationPhase : BFBiofeedbackPhase

@property (nonatomic, weak) id <BFBiofeedbackColorCalibrationPhaseDelegate> calibrationDelegate;

@end
