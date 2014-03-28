//
//  ReferenceImage.h
//  Pods
//
//  Created by Harang Ju on 3/28/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patient, Session;

@interface ReferenceImage : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Patient *patient;
@property (nonatomic, retain) NSSet *sessions;
@end

@interface ReferenceImage (CoreDataGeneratedAccessors)

- (void)addSessionsObject:(Session *)value;
- (void)removeSessionsObject:(Session *)value;
- (void)addSessions:(NSSet *)values;
- (void)removeSessions:(NSSet *)values;

@end
