//
//  BFBiofeedbackPhase.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/16/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFBiofeedbackPhase;

@protocol BFBiofeedbackPhaseDelegate <NSObject>

- (void)biofeedbackPhase:(BFBiofeedbackPhase *)biofeedbackPhase
      setStateWithString:(NSString *)string;
- (BOOL)biofeedbackPhaseViewIsInPortrait:(BFBiofeedbackPhase *)biofeedbackPhase;
- (BOOL)biofeedbackPhaseViewIsInLandscape:(BFBiofeedbackPhase *)biofeedbackPhase;

@end

@interface BFBiofeedbackPhase : NSObject

- (void)processFrame:(cv::Mat)mat
           videoRect:(CGRect)videoRect;

@property (nonatomic, weak) id <BFBiofeedbackPhaseDelegate> delegate;

@end
