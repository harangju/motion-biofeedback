//
//  Session.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patient;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) Patient *patient;

@end