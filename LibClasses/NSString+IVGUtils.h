//
//  NSString+IVGUtils.h
//  IVGUtils
//
//  Created by Douglas Sjoquist on 3/18/11.
//  Copyright 2011 Ivy Gulch, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (IVGUtils)

+ (NSString *) GUID;

- (BOOL) haveValue;

@end