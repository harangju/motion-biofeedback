//
//  Session.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 4/5/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeltaPoint, Patient, ReferenceImage;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSNumber * averageSampleRate;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSNumber * samplingRateStandardDeviation;
@property (nonatomic, retain) NSSet *deltaPoints;
@property (nonatomic, retain) Patient *patient;
@property (nonatomic, retain) ReferenceImage *referenceImage;
@end

@interface Session (CoreDataGeneratedAccessors)

- (void)addDeltaPointsObject:(DeltaPoint *)value;
- (void)removeDeltaPointsObject:(DeltaPoint *)value;
- (void)addDeltaPoints:(NSSet *)values;
- (void)removeDeltaPoints:(NSSet *)values;

@end
