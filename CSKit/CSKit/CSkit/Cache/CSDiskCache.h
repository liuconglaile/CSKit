//
//  CSDiskCache.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN


/**
   CSDiskCache是一个线程安全的缓存,用于存储由SQLite支持的键值对
   和文件系统(类似于NSURLCache的磁盘缓存).
  
   CSDiskCache具有以下功能：
  
   * 它使用LRU(最近最近使用的)来删除对象.
   * 可以按成本,数量和年龄进行控制.
   * 可以配置为在没有可用磁盘空间的情况下自动取出对象.
   * 可以自动决定要获取的每个对象的存储类型(sqlite/file)更好的表现.
  
   您可以编译最新版本的sqlite并忽略其中的libsqlite3.dylib
   iOS系统获得2x〜4x的速度.
 */
@interface CSDiskCache : NSObject

///MARK: ===================================================
///MARK: 属性相关
///MARK: ===================================================
/** 缓存的名称. Default is nil. */
@property (nullable, copy) NSString *name;

/** 缓存路径 (只读). */
@property (readonly) NSString *path;

/**
 如果对象的数据大小(以字节为单位)大于此值,则对象将被存储为文件,否则对象将存储在sqlite中.
 0表示所有对象将被存储为分离的文件,NSUIntegerMax表示所有对象将存储在sqlite中.
 默认值为20480(20KB).
 */
@property (readonly) NSUInteger inlineThreshold;

/**
 如果此块不为nil,则该块将用于归档对象而不是NSKeyedArchiver.
 您可以使用此块来支持不符合'NSCoding'协议的对象.
  
 默认值为nil.
 */
@property (nullable, copy) NSData *(^customArchiveBlock)(id object);

/**
 如果此块不为nil,则该块将用于取消存档对象,而不是NSKeyedUnarchiver.
 您可以使用此块来支持不符合'NSCoding'协议的对象.
 
 The default value is nil.
 */
@property (nullable, copy) id (^customUnarchiveBlock)(NSData *data);

/**
 当一个对象需要保存为一个文件时,这个块将被调用来生成一个指定的键的文件名.
 如果块为nil,缓存使用md5(key)作为默认文件名.
 
 The default value is nil.
 */
@property (nullable, copy) NSString *(^customFileNameBlock)(NSString *key);


///MARK: ===================================================
///MARK: 限制属性
///MARK: ===================================================
/**
 缓存应该保存的最大对象数.
 
 @discussion 默认值为NSUIntegerMax,这意味着没有限制.
 这不是严格的限制-如果缓存超过限制,缓存中的某些对象可能会在后台队列中被逐出.
 */
@property NSUInteger countLimit;

/**
 高速缓存开始驱逐对象之前可以容纳的最大总成本.
 
 @discussion 默认值为NSUIntegerMax,这意味着没有限制.
 这不是严格的限制-如果缓存超过限制,缓存中的某些对象可能会在后台队列中被逐出.
 */
@property NSUInteger costLimit;

/**
 缓存中对象的最长到期时间.
 
 @discussion 默认值为DBL_MAX,这意味着没有限制.
 这不是一个严格的限制-如果一个对象超过限制,对象可能会在后台队列中被逐出.
 */
@property NSTimeInterval ageLimit;

/**
 缓存应该保留的最小可用磁盘空间(以字节为单位).
 
 @discussion 默认值为0,表示无限制.
 如果可用磁盘空间低于此值,缓存将删除对象以释放一些磁盘空间.
 这不是一个严格的限制-如果可用磁盘空间超过限制,则后台队列中的对象可以被逐出.
 */
@property NSUInteger freeDiskSpaceLimit;

/**
 自动修整检查时间间隔(以秒为单位). Default is 60 (1 minute).
 
 @discussion 高速缓存保存一个内部定时器,以检查缓存是否达到限制,如果达到极限,它将开始驱逐对象.
 */
@property NSTimeInterval autoTrimInterval;

/**
 Set 'YES' to enable error logs for debug.
 */
@property BOOL errorLogsEnabled;

///MARK: ===================================================
///MARK: 构造函数
///MARK: ===================================================
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 根据指定的路径创建一个新的缓存.
 
 @param path 高速缓存将写入数据的目录的完整路径.
 一旦初始化,不应该再次读写这个目录.
 
 @return 新的缓存对象,如果发生错误,则为nil.
 
 @warning 如果指定路径的缓存实例已经存在于内存中,
 这个方法将直接返回,而不是创建一个新的实例.
 */
- (nullable instancetype)initWithPath:(NSString *)path;

/**
 指定的初始化程序.
 
 @param path   缓存将写入数据的目录的完整路径.一旦初始化,你不应该读写这个目录.
 
 @param threshold  数据存储内联阈值(以字节为单位).
 如果对象的数据大小(以字节为单位)大于此值,则对象将被存储为文件,否则对象将存储在sqlite中.
 0表示所有对象将被存储为分离的文件,NSUIntegerMax表示所有对象将存储在sqlite中.
 如果你不知道你的对象的大小,20480是一个不错的选择.
 首次初始化后,不应更改指定路径的值.
 
 @return 一个新的缓存对象,如果发生错误则为nil.
 @warning 如果指定路径的缓存实例已经存在于内存中,则此方法将直接返回,而不是创建新实例.
 */
- (nullable instancetype)initWithPath:(NSString *)path
                      inlineThreshold:(NSUInteger)threshold NS_DESIGNATED_INITIALIZER;


///MARK: ===================================================
///MARK: 访问方法
///MARK: ===================================================

/**
 返回一个布尔值,指示给定键是否在缓存中.
 此方法可能阻止调用线程,直到文件读取完成.
 
 @param key 标识值的字符串.如果为nil,只返回NO.
 @return 密钥是否在缓存中.
 */
- (BOOL)containsObjectForKey:(NSString *)key;

/**
 返回一个布尔值,其中该块指示给定键是否在缓存中.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param key   标识值的字符串.如果为nil,只返回NO.
 @param block 完成后将在后台队列中调用的块.
 */
- (void)containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block;

/**
 返回与给定键相关联的值.
 此方法可能阻止调用线程,直到文件读取完成.
 
 @param key 标识值的字符串.如果没有,只返回NO.
 @return 与键相关的值,如果没有值与键相关联,则为nil.
 */
- (nullable id<NSCoding>)objectForKey:(NSString *)key;

/**
 返回与给定键相关联的值.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param key 标识值的字符串.如果没有,只返回NO.
 @param block 完成后将在后台队列中调用的块.
 */
- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> _Nullable object))block;

/**
 设置缓存中指定键的值.
 此方法可能会阻止调用线程,直到文件写入完成.
 
 @param object 要存储在缓存中的对象.如果nil,它会通知调用 'removeObjectForKey:'.
 @param key    与值关联的key.如果nil,这方法没有效果.
 */
- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;

/**
 设置缓存中指定键的值.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param object 要存储在缓存中的对象.如果为nil,它调用 'removeObjectForKey:'.
 @param block  完成后将在后台队列中调用的块.
 */
- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key withBlock:(void(^)(void))block;

/**
 删除缓存中指定键的值.
 此方法可能会阻止调用线程,直到文件删除完成.
 
 @param key 识别要删除的值的键.如果为nil,这个方法有没有效果.
 */
- (void)removeObjectForKey:(NSString *)key;

/**
 删除缓存中指定键的值.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param key 识别要删除的值的键.如果为nil,这个方法有没有效果.
 @param block  完成后将在后台队列中调用的块.
 */
- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block;

/**
 清空缓存.
 此方法可能会阻止调用线程,直到文件删除完成.
 */
- (void)removeAllObjects;

/**
 清空缓存.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param block 完成后将在后台队列中调用的块.
 */
- (void)removeAllObjectsWithBlock:(void(^)(void))block;

/**
 用块清空缓存.
 该方法立即返回,并在后台使用块执行清除操作.
 
 @warning 您不应该在这些块中向此实例发送消息.
 @param progress 此块将在删除期间被调用,通过nil忽略.
 @param end      此块将在删除结束后被调用,通过nil忽略.
 */
- (void)removeAllObjectsWithProgressBlock:(nullable void(^)(int removedCount, int totalCount))progress
                                 endBlock:(nullable void(^)(BOOL error))end;


/**
 返回此缓存中的对象数.
 此方法可能阻止调用线程,直到文件读取完成.
 
 @return 总对象数.
 */
- (NSInteger)totalCount;

/**
 获取此缓存中的对象数.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param block  完成后将在后台队列中调用的块.
 */
- (void)totalCountWithBlock:(void(^)(NSInteger totalCount))block;

/**
 返回此缓存中对象的总成本(以字节为单位).
 此方法可能阻止调用线程,直到文件读取完成.
 
 @return 总对象的成本以字节为单位.
 */
- (NSInteger)totalCost;

/**
 获取此缓存中的对象的总成本(以字节为单位).
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param block  完成后将在后台队列中调用的块.
 */
- (void)totalCostWithBlock:(void(^)(NSInteger totalCost))block;


///MARK: ===================================================
///MARK: 修剪相关
///MARK: ===================================================


/**
 使用LRU从缓存中删除对象,直到'totalCount'低于指定值.
 此方法可能会阻止调用线程,直到操作完成.
 
 @param count  允许保留在已修剪缓存后的总数.
 */
- (void)trimToCount:(NSUInteger)count;

/**
 使用LRU从缓存中删除对象,直到'totalCount'低于指定值.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param count  允许保留在已修剪缓存后的总数.
 @param block  完成后将在后台队列中调用的块.
 */
- (void)trimToCount:(NSUInteger)count withBlock:(void(^)(void))block;

/**
 使用LRU从缓存中移除对象,直到'totalCost'低于指定值.
 此方法可能会阻止调用线程,直到操作完成
 
 @param cost 允许保留在已修剪缓存后的总成本.
 */
- (void)trimToCost:(NSUInteger)cost;

/**
 使用LRU从缓存中移除对象,直到'totalCost'低于指定值.
 该方法立即返回,并在操作完成后调用后台队列中传递的块
 
 @param cost   允许保留在已修剪缓存后的总成本
 @param block  完成后将在后台队列中调用的块.
 */
- (void)trimToCost:(NSUInteger)cost withBlock:(void(^)(void))block;

/**
 基于缓存年龄值,使用LRU从缓存中删除对象
  此方法可能会阻止调用线程,直到操作完成
 
 @param age  对象的最大年龄(存储时长).
 */
- (void)trimToAge:(NSTimeInterval)age;

/**
 基于缓存年龄值,使用LRU从缓存中删除对象.
 该方法立即返回,并在操作完成后调用后台队列中传递的块.
 
 @param age   对象的最大年龄(存储时长).
 @param block 完成后将在后台队列中调用的块.
 */
- (void)trimToAge:(NSTimeInterval)age withBlock:(void(^)(void))block;

///MARK: ===================================================
///MARK: 拓展数据
///MARK: ===================================================

/**
 从对象获取扩展数据.
 
 @discussion 有关详细信息,请参阅 'setExtendedData:toObject:'.
 */
+ (nullable NSData *)getExtendedDataFromObject:(id)object;

/**
 将扩展数据设置为对象.
 
 @discussion
 在将对象保存到磁盘缓存之前,可以将任何扩展数据设置为对象.
 扩展数据也将与此对象一起保存.
 稍后可以使用'getExtendedDataFromObject:'获取扩展数据.
 
 @param extendedData 扩展数据（通过nil删除）。
 @param object       对象.
 */
+ (void)setExtendedData:(nullable NSData *)extendedData toObject:(id)object;

@end
NS_ASSUME_NONNULL_END


