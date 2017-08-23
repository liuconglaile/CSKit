//
//  NSObject+ARCExtended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 使用ARC时NSObject的调试方法.
 */
@interface NSObject (ARCExtended)

/// 和'retain'一样
- (instancetype)arcDebugRetain NS_AUTOMATED_REFCOUNT_UNAVAILABLE;

/// 和'release'一样
- (oneway void)arcDebugRelease NS_AUTOMATED_REFCOUNT_UNAVAILABLE;

/// 和'autorelease'一样
- (instancetype)arcDebugAutorelease NS_AUTOMATED_REFCOUNT_UNAVAILABLE;

/// 和'retainCount'一样
- (NSUInteger)arcDebugRetainCount OBJC_ARC_UNAVAILABLE;

@end
