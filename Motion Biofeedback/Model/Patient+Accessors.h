//
//  Patient+Accessors.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/27/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "Patient.h"

@interface Patient (Accessors)

- (NSData *)latestImageData;
- (NSArray *)allImageData; // latest image first

@end
