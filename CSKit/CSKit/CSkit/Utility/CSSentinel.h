//
//  CSSentinel.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 CSSentinel是一个线程安全递增计数器.它可能在某些多线程情况下使用
 */
@interface CSSentinel : NSObject

/// 返回计数器的当前值.
@property (readonly) int32_t value;

/// 以原子方式增加值.
/// @return 新值.
- (int32_t)increase;

@end
