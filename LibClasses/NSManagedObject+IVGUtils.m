//
//  NSManagedObject+IVGUtils.m
//  IVGCoreDataUtils
//
//  Created by Douglas Sjoquist on 3/28/14.
//  Copyright (c) 2014 Ivy Gulch, LLC. All rights reserved.
//

#import "NSManagedObject+IVGUtils.h"
#import "NSObject+IVGUtils.h"

@implementation NSManagedObject (IVGUtils)

- (NSMutableDictionary *) propertyObserverBlocks;
{
    NSMutableDictionary *result = [self associatedUserInfoObjectForKey:@"IVGUtils_propertyObserverBlocks"];
    if (result == nil) {
        result = [NSMutableDictionary dictionary];
        [self setAssociatedUserInfoObject:result forKey:@"IVGUtils_propertyObserverBlocks"];
    }
    return result;
}

- (void) addObserverBlock:(IVGMOObserverBlock) block forKeyPath:(NSString *)keyPath;
{
    [[self propertyObserverBlocks] setObject:block forKey:keyPath];
}

- (void) removeObserverBlockForKeyPath:(NSString *)keyPath;
{
    [[self propertyObserverBlocks] removeObjectForKey:keyPath];
}

@end
