//
//  NSManagedObject+IVGUtils.h
//  IVGCoreDataUtils
//
//  Created by Douglas Sjoquist on 3/28/14.
//  Copyright (c) 2014 Ivy Gulch, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef void(^IVGMOObserverBlock)(id previousValue, id newValue);

@interface NSManagedObject (IVGUtils)

- (void) addObserverBlock:(IVGMOObserverBlock) block forKeyPath:(NSString *)keyPath;
- (void) removeObserverBlockForKeyPath:(NSString *)keyPath;

@end
