//
//  IVGPersistenceManager.m
//  IVGCoreDataUtils
//
//  Created by Douglas Sjoquist on 12/10/15.
//  Copyright © 2015 Ivy Gulch, LLC. All rights reserved.
//

#import "IVGContextManager.h"
#import "NSManagedObjectContext+IVGUtils.h"

@interface IVGContextManager()
@property (nonatomic,copy,readwrite) NSString *modelName;
@property (nonatomic,strong,readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSManagedObjectContext *privateContext;
@end

@implementation IVGContextManager

- (instancetype) initWithModelName:(NSString *) modelName
                          callback:(IVGPersistenceInitializationCallback) callback;
{
    if ((self = [super init])) {
        _modelName = [modelName copy];
        [self initializeWithCallback:callback];
    }
    return self;
}

#pragma mark - public methods

- (void) save;
{
    if (!self.privateContext.hasChanges && !self.managedObjectContext.hasChanges) {
        return;
    }

    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        BOOL success = [self.managedObjectContext save:&error];
        NSAssert(success, @"Error saving main context: %@", [error localizedDescription]);

        [self.privateContext performBlock:^{
            NSError *error = nil;
            BOOL success = [self.privateContext save:&error];
            NSAssert(success, @"Error saving private context: %@", [error localizedDescription]);
        }];
    }];
}

- (void) setAutosaveEnabled:(BOOL)autosaveEnabled;
{
    // ensure we only add or remove observers when appropriate
    if (_autosaveEnabled != autosaveEnabled) {
        _autosaveEnabled = autosaveEnabled;
        if (autosaveEnabled) {
            [self addObservers];
        } else {
            [self removeObservers];
        }
    }
}

#pragma mark - private initialization methods

- (void) initializeWithCallback:(IVGPersistenceInitializationCallback) callback;
{
    if (self.managedObjectContext) {
        return;
    }

    [self createRootContexts];
    [self configureUndoManager];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self configurePersistenceCoordinator];
        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback();
            });
        }
    });
}

- (void) createRootContexts;
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(model, @"Could not create model for modelURL: %@", modelURL);

    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSAssert(coordinator, @"Could not create coordinator for model: %@", model);

    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.privateContext.persistentStoreCoordinator = coordinator;

    self.managedObjectContext.parentContext = self.privateContext;
}

- (void) configureUndoManager;
{
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    undoManager.levelsOfUndo = 10;
    if (!undoManager.isUndoRegistrationEnabled) {
        [undoManager enableUndoRegistration];
    }
    self.privateContext.undoManager = undoManager;
}

- (void) configurePersistenceCoordinator;
{
    NSString *sqliteFilename = [self.modelName stringByAppendingString:@".sqlite"];
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *databasePath = [libraryDirectory stringByAppendingPathComponent:sqliteFilename];

    NSURL *storeURL = [[NSURL alloc] initFileURLWithPath:databasePath isDirectory:NO];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                              NSInferMappingModelAutomaticallyOption:@(YES),
                              NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"}};
    NSError *error = nil;
    BOOL success = [self.privateContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
    NSAssert(success, @"Could not create persistent store: %@", [error localizedDescription]);
}

#pragma mark - notification handling

- (void) addObservers;
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleManagedObjectContextDidSaveNotification:)
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
}

- (void) removeObservers;
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
}

- (void) handleManagedObjectContextDidSaveNotification:(NSNotification *) notification;
{
    NSManagedObjectContext *context = [notification object];
    if (self.autosaveEnabled && [context isDescendantOf:self.managedObjectContext]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self saveContextAncestors:context];
        });
    }
}

- (void) saveContextAncestors:(NSManagedObjectContext *) context;
{
    // start saving at parent until we reach self.managedObjectContext,
    // then call special contextManager save methoed
    context = context.parentContext;
    while ((context != nil) && (context != self.managedObjectContext)) {
        [context save];
        context = context.parentContext;
    }
    // if we reached self.managedObjectContext, call special save method
    if (context == self.managedObjectContext) {
        [self save];
    }
}

@end
