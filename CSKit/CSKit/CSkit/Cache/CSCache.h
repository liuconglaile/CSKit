//
//  CSCache.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CSMemoryCache, CSDiskCache;
NS_ASSUME_NONNULL_BEGIN



/**
 CSCache 是线程安全的键值缓存
  
 它使用 'CSMemoryCache' 将对象存储在一个小而快速的内存缓存中,
 并使用 'CSDiskCache'   将对象持久化到一个大而慢的磁盘缓存.
 有关详细信息,请参阅'CSMemoryCache'和'CSDiskCache'
 */
@interface CSCache : NSObject

/** 缓存的名称,只读. */
@property (copy, readonly) NSString *name;

/** 底层内存缓存.有关详细信息,请参阅'CSMemoryCache'.*/
@property (strong, readonly) CSMemoryCache *memoryCache;

/** 底层磁盘缓存. 有关详细信息,请参阅'CSDiskCache'.*/
@property (strong, readonly) CSDiskCache *diskCache;

/**
 创建一个具有指定名称的新实例.
 具有相同名称的多个实例将使缓存不稳定.
 
 @param name  缓存的名称. 它将在应用程序的缓存字典中创建一个名称为磁盘缓存的字典. 一旦初始化,你不应该读写这个目录.
 @result 一个新的缓存对象,如果发生错误,则为nil.
 */
- (nullable instancetype)initWithName:(NSString *)name;

/**
 使用指定的路径创建一个新的实例.
 具有相同名称的多个实例将使缓存不稳定.
 
 @param path  高速缓存将写入数据的目录的完整路径.一旦初始化,你不应该读写这个目录.
 @result 一个新的缓存对象,如果发生错误,则为nil.
 */
- (nullable instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

/**
 便利构造函数
 创建一个具有指定名称的新实例.
 具有相同名称的多个实例将使缓存不稳定.
 
 @param name  缓存的名称. 它将在应用程序的缓存字典中创建一个名称为磁盘缓存的字典. 一旦初始化,你不应该读写这个目录.
 @result 一个新的缓存对象,如果发生错误,则为nil.
 */
+ (nullable instancetype)cacheWithName:(NSString *)name;

/**
 便利构造函数
 使用指定的路径创建一个新的实例.
 具有相同名称的多个实例将使缓存不稳定.
 
 @param path  高速缓存将写入数据的目录的完整路径.一旦初始化,你不应该读写这个目录.
 @result 一个新的缓存对象,如果发生错误,则为nil.
 */
+ (nullable instancetype)cacheWithPath:(NSString *)path;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

///MARK: ===================================================
///MARK: 访问方法
///MARK: ===================================================

/**
 返回一个布尔值,指示给定键是否在缓存中.此方法可能阻止调用线程,直到文件读取完成.
 
 @param key 标识值的字符串.如果为零,只返回NO.
 @return 密钥是否在缓存中.
 */
- (BOOL)containsObjectForKey:(NSString *)key;

/**
 返回一个布尔值,其中该块指示给定键是否在缓存中.该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param key   标识值的字符串.如果为零,只返回NO.
 @param block 完成后将在后台队列中调用的块.
 */
- (void)containsObjectForKey:(NSString *)key withBlock:(nullable void(^)(NSString *key, BOOL contains))block;

/**
 返回与给定键相关联的值.
 此方法可能阻止调用线程,直到文件读取完成.
 
 @param key 标识值的字符串.如果为nil,只是返回nil.
 @return 与键相关的值,如果没有值与键相关联,则为nil.
 */
- (nullable id<NSCoding>)objectForKey:(NSString *)key;

/**
 返回与给定键相关联的值.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param key 标识值的字符串.如果为nil,只是返回nil.
 @param block 完成后将在后台队列中调用的块.
 */
- (void)objectForKey:(NSString *)key withBlock:(nullable void(^)(NSString *key, id<NSCoding> object))block;

/**
 设置缓存中指定键的值.
 此方法可能会阻止调用线程,直到文件写入完成.
 
 @param object 要存储在缓存中的对象.如果为nil,它将调用 'removeObjectForKey:'.
 @param key    与价值关联的关键。 如果为nil，这个方法将没有效果.
 */
- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;

/**
 设置缓存中指定键的值.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param object 要存储在缓存中的对象.如果为nil,它将调用 'removeObjectForKey:'.
 @param block  完成后将在后台队列中调用的块.
 */
- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key withBlock:(nullable void(^)(void))block;

/**
 删除缓存中指定键的值.
 此方法可能会阻止调用线程,直到文件删除完成.
 
 @param key 识别要删除的值的键. 如果为nil,这个方法将没有效果.
 */
- (void)removeObjectForKey:(NSString *)key;

/**
 删除缓存中指定键的值.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param key 识别要删除的值的键. 如果为nil,这个方法将没有效果.
 @param block  完成后将在后台队列中调用的块.
 */
- (void)removeObjectForKey:(NSString *)key withBlock:(nullable void(^)(NSString *key))block;

/**
 清空缓存.
 此方法可能会阻止调用线程,直到文件删除完成.
 */
- (void)removeAllObjects;

/**
 清空缓存.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param block  完成后将在后台队列中调用的块.
 */
- (void)removeAllObjectsWithBlock:(void(^)(void))block;

/**
 使用回调清空缓存.
 该方法立即返回,并在后台使用块执行清除操作.
 
 @warning 您不应该在这些块中向此实例发送消息.
 @param progress 此块将在删除期间被调用,通过nil忽略.
 @param end      此块将在删除完毕后被调用,通过nil忽略.
 */
- (void)removeAllObjectsWithProgressBlock:(nullable void(^)(int removedCount, int totalCount))progress
                                 endBlock:(nullable void(^)(BOOL error))end;

@end
NS_ASSUME_NONNULL_END


