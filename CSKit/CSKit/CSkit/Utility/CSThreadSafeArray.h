//
//  CSThreadSafeArray.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 线程安全可变数组的简单实现
 
 通常,访问性能低于NSMutableArray,但高于使用@synchronized,NSLock或pthread_mutex_t.
 它也与'NSArray(Extended)'和'NSMutableArray(Extended)'中的自定义方法兼容
 
 enumerate(for..in)和enumerator不是线程安全的,而是使用enumerator来代替. 
 当enumerator或使用block/callback排序时,请执行 *NOT* 向block/callback的数组发送消息.
 */
@interface CSThreadSafeArray : NSMutableArray

@end
