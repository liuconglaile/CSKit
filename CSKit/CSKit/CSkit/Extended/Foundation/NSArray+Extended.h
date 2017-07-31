//
//  NSArray+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/14.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 为'NSArray'提供一些常见的方法.
 */
@interface NSArray (Extended)

/** 从指定的plist创建并返回一个数组 */
+ (nullable NSArray *)arrayWithPlistData:(NSData *)plist;

/** 从指定的plist创建并返回一个数组xml字符串 */
+ (nullable NSArray *)arrayWithPlistString:(NSString *)plist;

/** 将数组序列化为二进制属性列表数据 */
- (nullable NSData *)plistData;

/** 将数组序列化为xml属性列表字符串 */
- (nullable NSString *)plistString;

/** 返回位于随机索引处的对象 */
- (nullable id)randomObject;

/** 返回位于索引处的对象,或者超出范围时返回nil */
- (nullable id)objectOrNilAtIndex:(NSUInteger)index;

/** 将对象转换为json字符串.如果发生错误,返回nil */
- (nullable NSString *)jsonStringEncoded;

/** 将对象转换为json字符串格式化.如果发生错误,返回nil */
- (nullable NSString *)jsonPrettyStringEncoded;

- (void)each:(void (^)(id object))block;
- (void)eachWithIndex:(void (^)(id object, NSUInteger index))block;
- (NSArray *)map:(id (^)(id object))block;
- (NSArray *)filter:(BOOL (^)(id object))block;
- (NSArray *)reject:(BOOL (^)(id object))block;
- (id)detect:(BOOL (^)(id object))block;
- (id)reduce:(id (^)(id accumulator, id object))block;
- (id)reduce:(nullable id)initial withBlock:(id (^)(id accumulator, id object))block;

/**
 防止越界的取值方法
 
 @param index 取值索引
 @return 取到的值
 */
- (id)objectWithIndex:(NSUInteger)index;
- (NSString*)stringWithIndex:(NSUInteger)index;
- (NSNumber*)numberWithIndex:(NSUInteger)index;
- (NSDecimalNumber *)decimalNumberWithIndex:(NSUInteger)index;
- (NSArray*)arrayWithIndex:(NSUInteger)index;
- (NSDictionary*)dictionaryWithIndex:(NSUInteger)index;
- (NSInteger)integerWithIndex:(NSUInteger)index;

/** 带索引的无符号整数 */
- (NSUInteger)unsignedIntegerWithIndex:(NSUInteger)index;
- (BOOL)boolWithIndex:(NSUInteger)index;
- (int16_t)int16WithIndex:(NSUInteger)index;
- (int32_t)int32WithIndex:(NSUInteger)index;
- (int64_t)int64WithIndex:(NSUInteger)index;
- (char)charWithIndex:(NSUInteger)index;
- (short)shortWithIndex:(NSUInteger)index;
- (float)floatWithIndex:(NSUInteger)index;
- (double)doubleWithIndex:(NSUInteger)index;
- (NSDate *)dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat;
///CG
- (CGFloat)CGFloatWithIndex:(NSUInteger)index;
- (CGPoint)pointWithIndex:(NSUInteger)index;
- (CGSize)sizeWithIndex:(NSUInteger)index;
- (CGRect)rectWithIndex:(NSUInteger)index;


@end


/**
 为'NSMutableArray'提供一些常见的方法.
 */
@interface NSMutableArray (Extended)

/** 从指定的plist创建并返回一个数组 */
+ (nullable NSMutableArray *)arrayWithPlistData:(NSData *)plist;

/** 从指定的plist创建并返回一个数组xml字符串 */
+ (nullable NSMutableArray *)arrayWithPlistString:(NSString *)plist;

/** 删除数组中具有最低值索引的对象.如果数组为空,则此方法无效 */
- (void)removeFirstObject;

/** 删除数组中具有最高值索引的对象.如果数组为空,则此方法无效 */
- (void)removeLastObject;

/** 删除并返回数组中具有最低值索引的对象.如果数组为空,则返回nil */
- (nullable id)popFirstObject;

/** 删除并返回数组中具有最高值索引的对象.如果数组为空,则返回nil */
- (nullable id)popLastObject;

/** 在数组的末尾插入给定的对象 */
- (void)appendObject:(id)anObject;

/** 在数组的开头插入一个给定的对象 */
- (void)prependObject:(id)anObject;

/** 将包含在另一给定数组中的对象添加到接收结束阵列的内容 */
- (void)appendObjects:(NSArray *)objects;

/** 将包含在另一给定数组中的对象添加到接收数组内容的开头 */
- (void)prependObjects:(NSArray *)objects;

/** 将包含在另一给定数组中的对象添加到接收的索引处阵列的内容 */
- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index;

/** 反转此数组中的对象索引 */
- (void)reverse;

/** 随机排列此数组中的对象 */
- (void)shuffle;


- (void)addObj:(id)i;
- (void)addString:(NSString*)i;
- (void)addBool:(BOOL)i;
- (void)addInt:(int)i;
- (void)addInteger:(NSInteger)i;
- (void)addUnsignedInteger:(NSUInteger)i;
- (void)addCGFloat:(CGFloat)f;
- (void)addChar:(char)c;
- (void)addFloat:(float)i;
- (void)addPoint:(CGPoint)o;
- (void)addSize:(CGSize)o;
- (void)addRect:(CGRect)o;

@end


NS_ASSUME_NONNULL_END

