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

- (NSManagedObjectContext *) createChildContext;
{
    NSManagedObjectContext *result = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    result.parentContext = self;
    return result;
}

- (BOOL) saveContextRecursively:(BOOL) recursively error:(NSError **) error;
{
    return [self saveContextRecursively:recursively modifiedPropertyName:@"modifiedTimestamp" error:error];
}

- (BOOL) saveContextRecursively:(BOOL) recursively modifiedPropertyName:(NSString *) modifiedPropertyName error:(NSError **) error;
{
    if (modifiedPropertyName) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(objectContextWillSave:)
                                                     name:NSManagedObjectContextWillSaveNotification
                                                   object:self];
    }
    [self setAssociatedUserInfoObject:modifiedPropertyName forKey:@"modifiedPropertyName"];

    BOOL result = YES;
    NSManagedObjectContext *useContext = self;
    while (useContext && result) {
        if ([useContext hasChanges] && ![useContext save:error]) {
            result = NO;
            if (error) {
                NSLog(@"save error: %@\n%@", [*error localizedDescription], [*error userInfo]);
            }
        }
        useContext = recursively ? useContext.parentContext : nil;
    }

    if (modifiedPropertyName) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:self];
    }
    [self setAssociatedUserInfoObject:nil forKey:@"modifiedPropertyName"];

    return result;
}

- (void) objectContextWillSave:(NSNotification*) notification;
{
    NSString *modifiedPropertyName = [self associatedUserInfoObjectForKey:@"modifiedPropertyName"];
    if (modifiedPropertyName == nil) {
        return;
    }

    NSManagedObjectContext* context = [notification object];
    NSSet* allModified = [context.insertedObjects setByAddingObjectsFromSet:context.updatedObjects];
    NSMutableSet *modifiable = [NSMutableSet setWithCapacity:[allModified count]];
    for (NSManagedObject *modified in allModified) {
        if ([[modified.entity attributesByName] objectForKey:modifiedPropertyName] != nil) {
            [modifiable addObject:modified];
        }
    }

    NSDate *now = [NSDate date];
    NSString *setterName = [NSString stringWithFormat:@"set%@%@:", [[modifiedPropertyName substringToIndex:1] uppercaseString], [modifiedPropertyName substringFromIndex:1]];
    [modifiable makeObjectsPerformSelector:NSSelectorFromString(setterName) withObject:now];
}

- (id) insertNewEntityWithName:(NSString *)name {
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self];
}

- (NSArray *)fetchObjectsForEntityName:(NSString *)entityName
                         withPredicate:(id)stringOrPredicate
                                 error:(NSError **) error;
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
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
    NSArray *results = [self fetchObjectsForEntityName:entityName withPredicate:stringOrPredicate error:error];
    if ([results count] > 1) {
        NSLog(@"Expected one or zero records fetching from '%@' withPredicate: %@, found:\n%@", entityName, stringOrPredicate, results);
    }
    return [results objectAtIndex:0 outOfRange:nil];
}

#pragma mark - Class methods

+ (NSURL *) writeableDatabaseUrl:(NSString *) databaseName error:(NSError **) errorPointer {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *writableDBPath = [docDir stringByAppendingPathComponent:databaseName];
    
    NSURL *storeUrl = [NSURL fileURLWithPath:writableDBPath];
    
    if([fileManager fileExistsAtPath:writableDBPath]) {
        return storeUrl;
    }
    
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    if ([fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:errorPointer]) {
        return storeUrl;
    }
    return nil;
}

+ (NSManagedObjectContext *) newManagedObjectContextForDatastore:(NSURL *) storeUrl error:(NSError **) errorPointer {
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:errorPointer];
    if (!persistentStore) {
        return nil;
    }
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: persistentStoreCoordinator];
    return managedObjectContext;
}

@end
