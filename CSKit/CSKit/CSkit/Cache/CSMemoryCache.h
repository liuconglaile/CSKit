//
//  CSMemoryCache.h
//  CSCategory
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 CSMemoryCache是一个存储键值对的快速内存缓存.
 与NSDictionary不同的是,键是保留的,而不是复制的.API和性能类似于NSCache,所有的方法都是线程安全的.
 
 与NSCache有不同的地方:
 * 它使用LRU(最少最近使用的)来删除对象;NSCache的驱逐方法是不确定的
 * 它可以通过成本、计数和年龄来控制;NSCache的限制是不精确的
 * 当接收到内存警告或应用程序进入后台时,它可以被配置为自动清除对象
 * CSMemoryCache中访问方法的时间通常是在恒定时间(O(1))
 
 */
@interface CSMemoryCache : NSObject

///MARK: ===================================================
///MARK: 属性相关
///MARK: ===================================================

/** 缓存的名称. Default is nil. */
@property (nullable, copy) NSString *name;
/** 在缓存中对象的数量 (read-only) */
@property (readonly) NSUInteger totalCount;
/** 在缓存中对象的总成本 (read-only). */
@property (readonly) NSUInteger totalCost;

///MARK: ===================================================
///MARK: 属性相关
///MARK: ===================================================



///MARK: ===================================================
///MARK: 限制属性相关
///MARK: ===================================================
/**
 缓存应该持有的对象的最大数量.
 
 @discussion 
 默认值是NSUIntegerMax,这意味着没有限制.
 这并不是一个严格的限制——如果缓存超过了极限,那么缓存中的一些对象可能会在后面的回调线程中被清除.
 */
@property NSUInteger countLimit;

/**
 在开始清除对象之前,缓存所能容纳的最大总成本.
 
 @discussion 
 默认值是NSUIntegerMax,这意味着没有限制.
 这并不是一个严格的限制——如果缓存超过了极限,那么缓存中的一些对象可能会在后面的回调线程中被清除.
 */
@property NSUInteger costLimit;

/**
 缓存中对象的最大失效时间.
 
 @discussion 
 默认值是DBL_MAX,这意味着没有限制.
 这并不是一个严格的限制——如果一个对象超过了极限,那么这个对象可能会在后面的返回的线程中被清除.
 */
@property NSTimeInterval ageLimit;

/**
 自动调整时间间隔,以秒为间隔. Default is 5.0.
 
 @discussion 
 缓存包含一个内部计时器来检查缓存是否达到它的限制,如果达到了限制,它就会开始驱逐对象.
 */
@property NSTimeInterval autoTrimInterval;

/**
 如果YES,当应用程序收到一个内存警告时,缓存将删除所有对象
 default value is 'YES'.
 */
@property BOOL shouldRemoveAllObjectsOnMemoryWarning;

/**
 如果YES,当应用进入后台时,缓存将删除所有对象.
 The default value is `YES`.
 */
@property BOOL shouldRemoveAllObjectsWhenEnteringBackground;

/**
 应用程序收到内存警告时要执行的块.
 The default value is nil.
 */
@property (nullable, copy) void(^didReceiveMemoryWarningBlock)(CSMemoryCache *cache);

/**
 应用程序进入后台时要执行的块.
 The default value is nil.
 */
@property (nullable, copy) void(^didEnterBackgroundBlock)(CSMemoryCache *cache);

/**
 如果YES,键值对将在主线程上释放,否则在后台线程上. Default is NO.
 
 @discussion 
 如果键值对象包含应该在主线程中释放的实例(如UIView/CALayer),那么您可以将该值设置为YES.
 */
@property BOOL releaseOnMainThread;

/**
 if YES,键值对将被异步释放,以避免阻塞访问方法,否则将在访问方法中释放
 (例如 removeObjectForKey:). Default is YES.
 */
@property BOOL releaseAsynchronously;

///MARK: ===================================================
///MARK: 限制属性相关
///MARK: ===================================================



///MARK: ===================================================
///MARK: 方法相关
///MARK: ===================================================

/**
  返回一个布尔值,表示给定键是否在缓存中.
 
 @param key 标识值的对象,如果nilm就返回NO.
 @return 键是否在缓存中.
 */
- (BOOL)containsObjectForKey:(id)key;

/**
 返回与给定键相关联的值.
 
 @param key 标识值的对象,如果nilm就返回NO.
 @return 与键关联的值,如果没有与键关联的值,则为nil.
 */
- (nullable id)objectForKey:(id)key;

/**
 在缓存中设置指定键的值 (0 cost).
 
 @param object 要存储在缓存中的对象.如果nil,它会调用'removeObjectForKey:'.
 @param key    将值关联起来的键.如果是nil,这个方法没有效果.
 @discussion   与NSMutableDictionary对象不同的是,缓存不复制放入其中的键对象.
 */
- (void)setObject:(nullable id)object forKey:(id)key;

/**
 在缓存中设置指定键的值,并将键值对与指定的成本关联起来.
 
 @param object 存储在缓存中的对象.如果nil,它会调用'removeObjectForKey'.
 @param key    将值关联起来的键.如果是nil,这个方法没有效果.
 @param cost   将键值对关联起来的成本.
 @discussion   与NSMutableDictionary对象不同的是,缓存不复制放入其中的键对象.
 */
- (void)setObject:(nullable id)object forKey:(id)key withCost:(NSUInteger)cost;

/**
 在缓存中删除指定键的值.
 
 @param key 标识要删除的值的关键字.如果nil,这个方法没有效果.
 */
- (void)removeObjectForKey:(id)key;

/**
 立即清空缓存.
 */
- (void)removeAllObjects;

///MARK: ===================================================
///MARK: 方法相关
///MARK: ===================================================



///MARK: ===================================================
///MARK: 修剪
///MARK: ===================================================

/**
 使用LRU从缓存中删除对象,直到totalCount低于或等于指定的值.
 @param count  在缓存被修剪之后,允许保留的总数.
 */
- (void)trimToCount:(NSUInteger)count;

/**
 使用LRU从缓存中删除对象,直到总成本等于或等于指定的值.
 @param cost 在缓存被削减后,允许保留的总成本.
 */
- (void)trimToCost:(NSUInteger)cost;

/**
 使用LRU从缓存中删除对象,直到所有过期对象被指定的值删除.
 @param age  对象的最大年龄(以秒为单位).
 */
- (void)trimToAge:(NSTimeInterval)age;

///MARK: ===================================================
///MARK: 修剪
///MARK: ===================================================

@end

NS_ASSUME_NONNULL_END




