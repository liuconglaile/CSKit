//
//  NSObject+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Extended)


///===========================================================
///MARK: GCD
///===========================================================

/** 异步执行代码块 */
- (void)performAsynchronous:(void(^)(void))block;
/** GCD主线程执行代码块 */
- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)wait;
/** 延迟执行代码块 */
- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block;


///===========================================================
///MARK: 其它
///===========================================================

/** 用'NSKeyedArchiver'和'NSKeyedUnarchiver'返回实例的副本.如果发生错误,返回nil */
- (nullable id)deepCopy;
/** 使用archiver和unarchiver返回实例的副本.如果发生错误,返回nil */
- (nullable id)deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver;



/** 归档 */
+(BOOL)keyedArchiver:(id)obj key:(NSString *)key;
/** 归档(可指定路径) */
+(BOOL)keyedArchiver:(id)obj key:(NSString *)key path:(NSString *)path;
/** 解档 */
+ (id)keyedUnarchiver:(NSString *)key;
/** 解档(可指定路径) */
+ (id)keyedUnarchiver:(NSString *)key path:(NSString *)path;


- (BOOL)isArray;
- (BOOL)isDictionary;
- (BOOL)isString;
- (BOOL)isNumber;
- (BOOL)isNull;
- (BOOL)isImage;
- (BOOL)isData;


- (BOOL)booleanValueForKey:(NSString *)key default:(BOOL)defaultValue;
- (BOOL)booleanValueForKey:(NSString *)key;


/** 模型对象转字典 */
- (NSDictionary *)dictionaryRepresentation;



@end

NS_ASSUME_NONNULL_END






