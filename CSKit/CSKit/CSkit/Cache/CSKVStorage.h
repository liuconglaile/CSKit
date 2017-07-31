//
//  CSKVStorage.h
//  CSCategory
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 CSKVStorageItem是CSKVStorage用来存储键值对和元数据的.
 通常,您不应该直接使用这个类.
 */
@interface CSKVStorageItem : NSObject
@property (nonatomic, strong) NSString *key;                ///< key
@property (nonatomic, strong) NSData *value;                ///< value
@property (nullable, nonatomic, strong) NSString *filename; ///< 文件名 (nil if inline)
@property (nonatomic) int size;                             ///< 值的大小(以字节为单位)
@property (nonatomic) int modTime;                          ///< 修改unix时间戳
@property (nonatomic) int accessTime;                       ///< 最后访问unix时间戳
@property (nullable, nonatomic, strong) NSData *extendedData; ///< 扩展数据(如果没有扩展数据,则为nil)
@end




/**
 存储方案枚举,表示保存 CSKVStorageItem.value的地方.
  
 @discussion
 通常,将数据写入sqlite比extern文件更快,但是读取性能取决于数据大小.
 在我的测试(在iPhone 6 64G),当数据较大时,从extern文件读取超过20KB数据比sqlite更快.
 
 * 如果要存储大量的小数据(如联系人缓存),使用CSKVStorageTypeSQLite来获得更好的性能.
 * 如果要存储大文件(如图像缓存),使用CSKVStorageTypeFile获得更好的性能.
 * 您可以使用CSKVStorageTypeMixed,并为每个项目选择您的存储类型.
 
  有关详细信息,请参阅<http://www.sqlite.org/intern-v-extern-blob.html>.

 - CSKVStorageTypeFile:   value 作为文件存储在文件系统中
 - CSKVStorageTypeSQLite: value 存储在带有blob类型的sqlite中
 - CSKVStorageTypeMixed:  value 根据您的选择存储在文件系统或sqlite中
 */
typedef NS_ENUM(NSUInteger, CSKVStorageType) {
    CSKVStorageTypeFile   = 0,
    CSKVStorageTypeSQLite = 1,
    CSKVStorageTypeMixed  = 2,
};




/**
 CSKVStorage是基于sqlite和文件系统的键值存储.
 通常,你不应该直接使用这个类.
  
 @discussion
 CSKVStorage的指定初始化程序是'initWithPath:type:'. 初始化后,将创建一个基于'path'来保存键值数据的目录.
 一旦初始化,您不应该在没有实例的情况下读取或写入该目录.
  
 您可以编译最新版本的sqlite并忽略其中的libsqlite3.dylib iOS系统获得2x〜4x的速度.
  
 @warning
 该类的实例是 *NOT* 线程安全,您需要确保只有一个线程可以同时访问该实例.
 如果您真的需要在多线程中处理大量数据,则应将数据拆分为多个KVStorage实例(sharding).
 */
@interface CSKVStorage : NSObject


///MARK:==========================================
///MARK:属性相关
///MARK:==========================================

@property (nonatomic, readonly) NSString *path;        ///< The path of this storage.
@property (nonatomic, readonly) CSKVStorageType type;  ///< The type of this storage.
@property (nonatomic) BOOL errorLogsEnabled;           ///< Set 'YES' to enable error logs for debug.

///MARK:==========================================
///MARK:属性相关
///MARK:==========================================


///MARK:==========================================
///MARK:构造函数
///MARK:==========================================

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
  指定的初始化函数.
 
 @param path  存储将写入数据的目录的完整路径.如果该目录不存在,它将尝试创建一个,否则将会读取此目录中的数据.
 @param type  存储类型.首次初始化后,您不应该更改指定路径的类型.
 @return  新的存储对象,如果发生错误.则为nil.
 @warning 具有相同路径的多个实例将使存储不稳定.
 */
- (nullable instancetype)initWithPath:(NSString *)path type:(CSKVStorageType)type NS_DESIGNATED_INITIALIZER;

///MARK:==========================================
///MARK:构造函数
///MARK:==========================================




///MARK:==========================================
///MARK:保存
///MARK:==========================================

/**
 保存item或使用'key'更新item,如果它已经存在.
 
 @discussion  此方法将保存:
 item.key
 item.value
 item.filename
 item.extendedData
 到disk或sqlite,其他属性将被忽略.
 item.key和item.value不应为空 (nil 或者 zero length).
 
 提示 1-1:
 如果'type'是CSKVStorageTypeFile,  那么item.filename不应该是空的.
 如果'type'是CSKVStorageTypeSQLite,那么item.filename将被忽略.
 如果'type'是CSKVStorageTypeMixed, 那么如果item.filename不为空,
 那么item.value将被保存到文件系统,否则将被保存到sqlite.
 
 @param item  An item.
 @return 是否成功.
 */
- (BOOL)saveItem:(CSKVStorageItem *)item;

/**
 保存 NSData类型value 或使用'key'更新item,如果它已经存在.
 
 @discussion 此方法将'键值对'保存到sqlite. 
 如果 'type'是 CSKVStorageTypeFile, 那么这个方法就会失败.
 
 @param key   该键不应为空(nil或零长度).
 @param value 值键不应为空 (nil or zero length).
 @return 是否成功.
 */
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value;

/**
 保存item或使用'key'更新item,如果它已经存在.
 
 @discussion 提示请看 1-1
 
 @param key   该键不应为空(nil或零长度).
 @param value 值键不应为空 (nil or zero length).
 @param filename      文件名.
 @param extendedData  该item的扩展数据 (忽略请填写 nil).
 
 @return 是否成功.
 */
- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
               filename:(nullable NSString *)filename
           extendedData:(nullable NSData *)extendedData;

///MARK:==========================================
///MARK:保存
///MARK:==========================================




///MARK:==========================================
///MARK:删除
///MARK:==========================================

/**
 基于'key'删除 item.
 
 @param key item 的'key'.
 @return  是否成功.
 */
- (BOOL)removeItemForKey:(NSString *)key;

/**
 基于'keys'删除 items.
 
 @param keys items 的'keys'.
 @return  是否成功.
 */
- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys;

/**
 删除指定 size  以上的所有 value.
 
 @param size  最大 size (bytes为单位).
 @return 是否成功.
 */
- (BOOL)removeItemsLargerThanSize:(int)size;

/**
 删除上次访问时间早于指定时间戳的所有项目.
 
 @param time  指定的unix时间戳.
 @return 是否成功.
 */
- (BOOL)removeItemsEarlierThanTime:(int)time;

/**
 基于最大 size 删除item.最近最少使用的（LRU）项目将首先被删除.
 
 @param maxSize 指定大小(以字节为单位).
 @return 是否成功.
 */
- (BOOL)removeItemsToFitSize:(int)maxSize;

/**
 基于最大指定使用次数删除item,最近最少使用的（LRU）项目将首先被删除.
 
 @param maxCount 指定item计数.
 @return 是否成功.
 */
- (BOOL)removeItemsToFitCount:(int)maxCount;

/**
 删除后台队列中的所有items.
 
 @discussion 
 此方法将文件和sqlite数据库删除到垃圾桶文件夹，然后清除后台队列中的文件夹.
 所以这个方法比'removeAllItemsWithProgressBlock:endBlock:'快得多.
 
 @return 是否成功.
 */
- (BOOL)removeAllItems;

/**
 删除所有items.
 
 @warning 您不应该在这些块中向此实例发送消息.
 @param progress 此块将在删除期间被调用,通过nil忽略.
 @param end      此块将在删除完成后被调用,通过nil忽略.
 */
- (void)removeAllItemsWithProgressBlock:(nullable void(^)(int removedCount, int totalCount))progress
                               endBlock:(nullable void(^)(BOOL error))end;

///MARK:==========================================
///MARK:删除
///MARK:==========================================



///MARK:==========================================
///MARK:获取
///MARK:==========================================

/**
 获取具有指定键的item.
 
 @param key 指定的键.
 @return 指定键的 item 如果发生错误则返回 nil.
 */
- (nullable CSKVStorageItem *)getItemForKey:(NSString *)key;

/**
 获取具有指定键的item信息. 此item中的'value'将被忽略
 
 @param key 指定的键.
 @return 指定键的 item 如果发生错误则返回 nil.
 */
- (nullable CSKVStorageItem *)getItemInfoForKey:(NSString *)key;

/**
 使用指定的键获取item 的值.
 
 @param key  指定 key.
 @return 指定键的 item 的Value 如果发生错误则返回 nil.
 */
- (nullable NSData *)getItemValueForKey:(NSString *)key;

/**
 获取带有keys的items.
 
 @param keys  指定的keys.
 @return NSArray<CSKVStorageItem*>, 如果不存在/发生错误 则为nil.
 */
- (nullable NSArray<CSKVStorageItem *> *)getItemForKeys:(NSArray<NSString *> *)keys;
- (nullable NSArray<CSKVStorageItem *> *)getItemInfoForKeys:(NSArray<NSString *> *)keys;
- (nullable NSDictionary<NSString *, NSData *> *)getItemValueForKeys:(NSArray<NSString *> *)keys;


///MARK:==========================================
///MARK:获取
///MARK:==========================================



///MARK:==========================================
///MARK:获取存储状态
///MARK:==========================================

/**
 是否存在指定key的item.
 
 @param key   指定key.
 
 @return 如果存在一个项目,则返回'YES',如果不存在或者发生错误,则为'否'.
 */
- (BOOL)itemExistsForKey:(NSString *)key;

/**
 获取总计数.
 @return 总计数,发生错误时返回-1.
 */
- (int)getItemsCount;

/**
 获取项目值的总大小(以字节为单位)
 @return 发生错误时为-1.
 */
- (int)getItemsSize;

///MARK:==========================================
///MARK:获取存储状态
///MARK:==========================================




@end

NS_ASSUME_NONNULL_END




