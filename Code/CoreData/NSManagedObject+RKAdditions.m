//
//  NSManagedObject+RKAdditions.m
//  RestKit
//
//  Created by Blake Watters on 3/14/12.
//  Copyright (c) 2009-2012 RestKit. All rights reserved.
//

#import "NSManagedObject+RKAdditions.h"
#import "NSManagedObjectContext+RKAdditions.h"
#import "RKLog.h"
#import "RKManagedObjectStore.h"

@implementation NSManagedObject (RKAdditions)

- (BOOL)hasBeenDeleted
{
    NSManagedObject *managedObjectClone = [[self managedObjectContext] existingObjectWithID:[self objectID] error:nil];
    return (managedObjectClone == nil) ? YES : NO;
}

- (BOOL)isNew
{
    NSDictionary *vals = [self committedValuesForKeys:nil];
    return [vals count] == 0;
}

- (void)copyTransientAttributesFromManagedObject:(NSManagedObject *)managedObject
{
    static NSMutableDictionary *transientAttributesMap = nil;
    
    if (!transientAttributesMap) {
        transientAttributesMap = [[NSMutableDictionary alloc] init];
    }
    
    NSArray *transientAttributes = [transientAttributesMap objectForKey:self.entity.name];
    
    if (!transientAttributes) {
        NSEntityDescription *entity = [self entity];
        
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        for (NSString *key in entity.attributesByName) {
            NSAttributeDescription *attribute = [entity.attributesByName objectForKey:key];
            if (attribute.isTransient) {
                [keys addObject:key];
            }
        }
        transientAttributes = [keys copy];
        [transientAttributesMap setObject:self.entity.name forKey:transientAttributes];
    }
    
    for (NSString *key in transientAttributes) {
        id value = [managedObject valueForKey:key];
        if (value) {
            [self setValue:value forKey:key];
        }
    }
}

@end
