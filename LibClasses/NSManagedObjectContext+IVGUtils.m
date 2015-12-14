//
//  NSManagedObjectContext+IVGUtils.m
//  IVGUtils
//
//  Created by Douglas Sjoquist on 3/18/11.
//  Copyright 2011 Ivy Gulch, LLC. All rights reserved.
//

#import "NSManagedObjectContext+IVGUtils.h"
#import "NSArray+IVGUtils.h"
#import "NSObject+IVGUtils.h"

@implementation NSManagedObjectContext (IVGUtils)

- (id) insertNewEntityWithName:(NSString *)name {
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self];
}

- (NSArray *)fetchObjectsForEntityName:(NSString *)entityName
                         withPredicate:(id)stringOrPredicate
                            properties:(NSArray *) properties
                       sortDescriptors:(NSArray *) sortDescriptors
                                 error:(NSError **) error;
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if (sortDescriptors) {
        [request setSortDescriptors:sortDescriptors];
    }
    if (properties) {
        [request setPropertiesToFetch:properties];
    }

    if (stringOrPredicate) {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]]) {
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate];
        } else {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), stringOrPredicate);
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
    
    return [self executeFetchRequest:request error:error];
}

- (id)fetchObjectForEntityName:(NSString *)entityName
                 withPredicate:(id)stringOrPredicate
                         error:(NSError **) error;
{
    NSArray *results = [self fetchObjectsForEntityName:entityName withPredicate:stringOrPredicate properties:nil sortDescriptors:nil error:error];
    if ([results count] > 1) {
        NSLog(@"Expected one or zero records fetching from '%@' withPredicate: %@, found:\n%@", entityName, stringOrPredicate, results);
    }
    return [results firstObject];
}

- (NSManagedObjectContext *) newChildContext;
{
    NSManagedObjectContext *result = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    result.parentContext = self;
    return result;
}


- (void) save;
{
    NSError *error = nil;
    if (![self save:&error]) {
        NSAssert(NO, @"Error saving context: %@", [error localizedDescription]);
    }
}

- (BOOL) isDescendantOf:(NSManagedObjectContext *) potentialAncestor;
{
    NSManagedObjectContext *checkContext = self.parentContext;
    while ((checkContext != nil) && (checkContext != potentialAncestor)) {
        checkContext = checkContext.parentContext;
    }
    return (potentialAncestor == checkContext);
}

@end
