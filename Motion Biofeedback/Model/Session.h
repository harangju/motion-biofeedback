//
//  Session.h
//  Pods
//
//  Created by Harang Ju on 3/28/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeltaPoint, Patient, ReferenceImage;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSNumber * averageSampleRate;
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
