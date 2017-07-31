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

#pragma mark - 使用变量参数发送消息
///=============================================================================
/// @name 使用变量参数发送消息
///=============================================================================

/** 向接收方发送指定的消息,并返回消息的结果(使用示例1-1) */
- (nullable id)performSelectorWithArgs:(SEL)sel, ...;
/** 在延迟之后使用默认模式调用当前线程上的接收方法,之前的请求不能取消(使用示例1-2) */
- (void)performSelectorWithArgs:(SEL)sel afterDelay:(NSTimeInterval)delay, ...;
/** 使用默认模式调用主线程上的接收器方法(使用示例1-3) */
- (nullable id)performSelectorWithArgsOnMainThread:(SEL)sel waitUntilDone:(BOOL)wait, ...;
/** 使用默认模式调用指定线程上的接收方法(使用示例1-4) */
- (nullable id)performSelectorWithArgs:(SEL)sel onThread:(NSThread *)thread waitUntilDone:(BOOL)wait, ...;
/** 在新的后台线程上调用接收器的方法(使用示例1-5) */
- (void)performSelectorWithArgsInBackground:(SEL)sel, ...;
/** 在延迟后调用当前线程上的接收方法.(ARC环境执行这个选择器会导致内存泄露) */
- (void)performSelector:(SEL)sel afterDelay:(NSTimeInterval)delay;


#pragma mark - 交换方法(Swizzling)
///=============================================================================
/// @name 交换方法(Swizzling)
///=============================================================================

/** 在一个类中交换两个实例方法的实现.要谨慎使用,很容易崩. */
+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;
/** 在一个类中交换两个类方法实现.要谨慎使用,很容易崩. */
+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;

/** 追加的新方法,对象 */
+ (void)appendMethod:(SEL)newMethod fromClass:(Class)aClass;
/** 检查父类是否实现了指定代理 */
- (BOOL)respondsToSelector:(SEL)selector untilClass:(Class)stopClass;
/** 检查父类是否实现了指定类方法 */
- (BOOL)superRespondsToSelector:(SEL)selector;
/** 检查父类是否实现了指定类方法 */
- (BOOL)superRespondsToSelector:(SEL)selector untilClass:(Class)stopClass;
/** 检查父类是否实现了指定实例方法 */
+ (BOOL)instancesRespondToSelector:(SEL)selector untilClass:(Class)stopClass;


#pragma mark - 关联value
///=============================================================================
/// @name 关联value
///=============================================================================

/** 将一个对象与self关联 并且强引用strong (strong, nonatomic). */
- (void)setAssociateValue:(nullable id)value withKey:(void *)key;
/** 将一个对象与self关联 并且弱引用 weak property (week, nonatomic). */
- (void)setAssociateWeakValue:(nullable id)value withKey:(void *)key;
/** 从'self'获取关联的值 */
- (nullable id)getAssociatedValueForKey:(void *)key;
/** 删除所有关联的值 */
- (void)removeAssociatedValues;

#pragma mark - GCD
///=============================================================================
/// @name GCD
///=============================================================================

/** 异步执行代码块 */
- (void)performAsynchronous:(void(^)(void))block;
/** GCD主线程执行代码块 */
- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)wait;
/** 延迟执行代码块 */
- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block;


#pragma mark - 其它
///=============================================================================
/// @name 其它
///=============================================================================

/** 返回类名 */
+ (NSString *)className;
/** 返回类名 */
- (NSString *)className;
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







///MARK:使用示例1-1
/**

 如果选择器的'return type'不是对象,则选择器的返回值将被换行为NSNumber或NSValue.
 如果选择器的'return type'为void,它总是返回nil.
 
 
 示例代码:
 
 // 无变量 args
 [view performSelectorWithArgs:@selector(removeFromSuperView)];
 
 // 变量 arg 不是 NSObject
 [view performSelectorWithArgs:@selector(setCenter:), CGPointMake(0, 0)];
 
 // 执行并返回 NSObject
 UIImage *image = [UIImage.class performSelectorWithArgs:@selector(imageWithData:scale:), data, 2.0];
 
 // 执行并返回 NSNumber
 NSNumber *lengthValue = [@"hello" performSelectorWithArgs:@selector(length)];
 NSUInteger length = lengthValue.unsignedIntegerValue;
 
 // 执行并返回 NSValue
 NSValue *frameValue = [view performSelectorWithArgs:@selector(frame)];
 CGRect frame = frameValue.CGRectValue;
 
 */

///MARK:使用示例1-2
/**
 示例代码:
 
 // 无变量 args
 [view performSelectorWithArgs:@selector(removeFromSuperView) afterDelay:2.0];
 
 // 变量 arg 不是 NSObject
 [view performSelectorWithArgs:@selector(setCenter:), afterDelay:0, CGPointMake(0, 0)];
 
 */


///MARK:使用示例1-3
/**
 如果选择器的'return type'不是对象,则选择器的返回值将被换行为NSNumber或NSValue.
 如果选择器的'return type'为void,或者@a等待为YES,它总是返回nil.
 
 示例代码:
 
 // 无变量 args
 [view performSelectorWithArgsOnMainThread:@selector(removeFromSuperView), waitUntilDone:NO];
 
 // 变量 arg 不是 NSObject
 [view performSelectorWithArgsOnMainThread:@selector(setCenter:), waitUntilDone:NO, CGPointMake(0, 0)];
 */

///MARK:使用示例1-4
/**
 如果选择器的'return type'不是对象,则选择器的返回值将被换行为NSNumber或NSValue.
 如果选择器的'return type'为void,或者@a等待为YES,它总是返回nil.
 
 示例代码:
 
 [view performSelectorWithArgs:@selector(removeFromSuperView) onThread:mainThread waitUntilDone:NO];
 
 [array  performSelectorWithArgs:@selector(sortUsingComparator:) 
                        onThread:backgroundThread
                   waitUntilDone:NO, ^NSComparisonResult(NSNumber *num1, NSNumber *num2) {
                        return [num2 compare:num2];
 }];
 */


///MARK:使用示例1-5
/**

 Sample Code:
 
 [array  performSelectorWithArgsInBackground:@selector(sortUsingComparator:), ^NSComparisonResult(NSNumber *num1, NSNumber *num2) {
    return [num2 compare:num2];
 }];
 
 */





