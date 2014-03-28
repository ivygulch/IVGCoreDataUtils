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

- (NSMutableDictionary *) keyPathObserverBlocks;
{
    NSMutableDictionary *result = [self associatedUserInfoObjectForKey:@"IVGUtils_keyPathObserverBlocks"];
    if (result == nil) {
        result = [NSMutableDictionary dictionary];
        [self setAssociatedUserInfoObject:result forKey:@"IVGUtils_keyPathObserverBlocks"];
    }
    return result;
}

- (void) addObserverBlock:(IVGMOObserverBlock) block forKeyPath:(NSString *)keyPath;
{
    [[self keyPathObserverBlocks] setObject:block forKey:keyPath];
    [self addObserver:self forKeyPath:keyPath
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
              context:NULL];
}

- (void) removeObserverBlockForKeyPath:(NSString *)keyPath;
{
    [self removeObserver:self forKeyPath:keyPath];
    [[self keyPathObserverBlocks] removeObjectForKey:keyPath];
}

- (void) removeObserverBlocksForAllKeyPaths;
{
    NSArray *keyPaths = [[[self keyPathObserverBlocks] allKeys] copy];
    for (NSString *keyPath in keyPaths) {
        [self removeObserverBlockForKeyPath:keyPath];
    }
}

#define IFNSNULL(v) ([v isEqual:[NSNull null]] ? nil : v)

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context;
{
    IVGMOObserverBlock block = [[self keyPathObserverBlocks] objectForKey:keyPath];
    if (block) {
        block(self,
              keyPath,
              IFNSNULL([change objectForKey:NSKeyValueChangeOldKey]),
              IFNSNULL([change objectForKey:NSKeyValueChangeNewKey])
              );
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
