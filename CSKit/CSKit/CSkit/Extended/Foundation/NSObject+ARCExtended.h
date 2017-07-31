//
//  NSObject+ARCExtended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Debug method for NSObject when using ARC.
 */
@interface NSObject (ARCExtended)

/// Same as `retain`
- (instancetype)arcDebugRetain NS_AUTOMATED_REFCOUNT_UNAVAILABLE;

/// Same as `release`
- (oneway void)arcDebugRelease NS_AUTOMATED_REFCOUNT_UNAVAILABLE;

/// Same as `autorelease`
- (instancetype)arcDebugAutorelease NS_AUTOMATED_REFCOUNT_UNAVAILABLE;

/// Same as `retainCount`
- (NSUInteger)arcDebugRetainCount OBJC_ARC_UNAVAILABLE;

@end
