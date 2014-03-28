//
//  Patient.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/28/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ReferenceImage, Session;

@interface Patient : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *referenceImages;
@property (nonatomic, retain) NSSet *sessions;
@end

@interface Patient (CoreDataGeneratedAccessors)

- (void)addReferenceImagesObject:(ReferenceImage *)value;
- (void)removeReferenceImagesObject:(ReferenceImage *)value;
- (void)addReferenceImages:(NSSet *)values;
- (void)removeReferenceImages:(NSSet *)values;

- (void)addSessionsObject:(Session *)value;
- (void)removeSessionsObject:(Session *)value;
- (void)addSessions:(NSSet *)values;
- (void)removeSessions:(NSSet *)values;

@end
