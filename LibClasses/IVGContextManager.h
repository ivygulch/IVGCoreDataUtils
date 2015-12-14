//
//  IVGContextManager.h
//  IVGCoreDataUtils
//
//  Created by Douglas Sjoquist on 12/10/15.
//  Copyright © 2015 Ivy Gulch, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef void (^IVGPersistenceInitializationCallback)(void);

@interface IVGContextManager : NSObject

@property (nonatomic,copy,readonly) NSString *modelName;
@property (nonatomic,strong,readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,assign) BOOL autosaveEnabled;

- (instancetype) initWithModelName:(NSString *) modelName
                          callback:(IVGPersistenceInitializationCallback) callback;

- (void) save;

@end
