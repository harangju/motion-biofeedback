//
//  ReferenceImage.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/28/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patient, Session;

@interface ReferenceImage : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Patient *patient;
@property (nonatomic, retain) Session *sessions;

@end
