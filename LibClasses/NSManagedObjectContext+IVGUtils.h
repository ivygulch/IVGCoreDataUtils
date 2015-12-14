//
//  NSManagedObjectContext+IVGUtils.h
//  IVGUtils
//
//  Created by Douglas Sjoquist on 3/18/11.
//  Copyright 2011 Ivy Gulch, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (IVGUtils)

- (id)insertNewEntityWithName:(NSString *)name;
- (NSArray *)fetchObjectsForEntityName:(NSString *)entityName
                         withPredicate:(id)stringOrPredicate
                            properties:(NSArray *) properties
                       sortDescriptors:(NSArray *) sortDescriptors
                                 error:(NSError **) error;
- (id)fetchObjectForEntityName:(NSString *)entityName
                 withPredicate:(id)stringOrPredicate
                         error:(NSError **) error;

- (NSManagedObjectContext *) newChildContext;
- (void) save;

- (BOOL) isDescendantOf:(NSManagedObjectContext *) potentialAncestor;

@end
