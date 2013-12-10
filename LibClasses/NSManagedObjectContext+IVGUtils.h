//
//  NSManagedObjectContext+IVGUtils.h
//  IVGUtils
//
//  Created by Douglas Sjoquist on 3/18/11.
//  Copyright 2011 Ivy Gulch, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (IVGUtils)

- (NSManagedObjectContext *) createChildContext;
- (BOOL) saveContextRecursively:(BOOL) recursively error:(NSError **) error;
- (BOOL) saveContextRecursively:(BOOL) recursively modifiedPropertyName:(NSString *) modifiedProperty error:(NSError **) error;

- (id)insertNewEntityWithName:(NSString *)name;
- (NSArray *)fetchObjectsForEntityName:(NSString *)entityName
                         withPredicate:(id)stringOrPredicate
                                 error:(NSError **) error;
- (id)fetchObjectForEntityName:(NSString *)entityName
                 withPredicate:(id)stringOrPredicate
                         error:(NSError **) error;

+ (NSURL *) writeableDatabaseUrl:(NSString *) databaseName error:(NSError **) errorPointer;
+ (NSManagedObjectContext *) newManagedObjectContextForDatastore:(NSURL *) storeUrl error:(NSError **) errorPointer;


@end
