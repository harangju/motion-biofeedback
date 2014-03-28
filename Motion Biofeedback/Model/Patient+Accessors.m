//
//  Patient+Accessors.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/27/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "Patient+Accessors.h"
#import "ReferenceImage.h"

@implementation Patient (Accessors)

- (NSData *)latestImageData
{
    ReferenceImage *referenceImage = self.allReferenceImages.firstObject;
    return referenceImage.imageData;
}

- (NSArray *)allReferenceImages
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp"
                                                                     ascending:NO];
    NSLog(@"array %@", [self.referenceImages.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]]);
    return [self.referenceImages.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
