//
//  CSImageCache.h
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class CSMemoryCache,CSDiskCache;
NS_ASSUME_NONNULL_BEGIN


/**
 图像缓存类型
 
 - CSImageCacheTypeNone: 没有缓存
 - CSImageCacheTypeMemory: 使用内存缓存获取/存储图像
 - CSImageCacheTypeDisk: 使用磁盘缓存获取/存储映像
 - CSImageCacheTypeAll: 使用内存缓存和磁盘缓存获取/存储映像.
 */
typedef NS_OPTIONS(NSUInteger, CSImageCacheType) {
    CSImageCacheTypeNone   = 0,
    CSImageCacheTypeMemory = 1 << 0,
    CSImageCacheTypeDisk   = 1 << 1,
    CSImageCacheTypeAll    = CSImageCacheTypeMemory | CSImageCacheTypeDisk,
};


/**
 CSImageCache是一种基于内存缓存和磁盘缓存存储 UIImage 和映像数据的缓存
 
 磁盘缓存将尝试保存原始图像数据
 
 * 如果原始图像仍然是图像,它将根据alpha信息保存为png/jpeg文件.
 * 如果原始图像是gif,apng或webp,那么它将被保存为原始格式.
 * 如果原始图像的比例不是1,比例值将被保存为扩展数据.
  
 虽然UIImage可以使用NSCoding协议序列化,但这不是一个好主意:
 
 苹果实际上使用UIImagePNGRepresentation()对所有类型的图像进行编码,可能丢失原始的多帧数据.
 结果被打包到plist文件,不能直接用照片查看器查看.
 如果图像没有Alpha通道,使用JPEG而不是PNG可以节省更多的磁盘大小和编码/解码时间
 */
@interface CSImageCache : NSObject

///MARK: ===================================================
///MARK: 属性相关
///MARK: ===================================================

/** 缓存名称. Default is nil. */
@property (nullable, copy) NSString *name;

/** 底层内存缓存.有关详细信息,请参阅CSMemoryCache */
@property (strong, readonly) CSMemoryCache *memoryCache;

/** 底层磁盘缓存.有关详细信息,请参阅CSDiskCache */
@property (strong, readonly) CSDiskCache *diskCache;

/**
 是否在从磁盘缓存中提取图像时解码动画图像. Default is YES.
 
 @discussion
 当从磁盘缓存中获取图像时,将使用'CSImage'来解码诸如(WebP/APNG/GIF)之类的动画图像. 设置为'NO'以忽略动画图像.
 */
@property BOOL allowAnimatedImage;

/**
 是否将图像解码到内存位图. Default is YES.
 
 @discussion
 如果值为YES,则图像将被解码为内存位图以获得更好的显示性能,但可能会花费更多的内存.
 */
@property BOOL decodeForDisplay;


///MARK: ===================================================
///MARK: 构造函数
///MARK: ===================================================
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 返回全局共享映像缓存实例
 */
+ (instancetype)sharedCache;

/**
 指定的初始化程序.具有相同路径的多个实例将使缓存不稳定.
 
 @param path 缓存将写入数据的目录的完整路径.一旦初始化,你不应该读写这个目录.
 @result 缓存对象,如果发生错误则返回 nil.
 */
- (nullable instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;


///MARK: ===================================================
///MARK: 访问方法
///MARK: ===================================================

/**
 使用缓存中的指定键(内存和磁盘)设置映像.该方法立即返回,并在后台执行存储操作.
 
 @param image 要存储在缓存中的图像.如果nil,该方法没有效果.
 @param key   用于关联图像的键.如果nil,该方法没有效果.
 */
- (void)setImage:(UIImage *)image forKey:(NSString *)key;

/**
 在缓存中使用指定的键设置图像.
 该方法立即返回,并在后台执行存储操作.
 
 @discussion
 如果'type'包含'CSImageCacheTypeMemory',那么'image'将被存储在内存缓存中;
 如果'image'为nil,则将使用'imageData'.
 如果'type'包含'CSImageCacheTypeDisk',那么'imageData'将被存储在磁盘缓存中;
 'image'将会被使用,如果'imageData'为nil.
 
 @param image     要存储在缓存中的映像.
 @param imageData 要存储在缓存中的图像数据.
 @param key       图像关联的键.如果nil,该方法没有效果.
 @param type      用于存储图像的缓存类型.
 */
- (void)setImage:(nullable UIImage *)image
       imageData:(nullable NSData *)imageData
          forKey:(NSString *)key
        withType:(CSImageCacheType)type;

/**
 删除缓存中指定键的映像 (内存和磁盘).
 该方法立即返回,并在后台执行删除操作.
 
 @param key 识别要删除的图像的键.如果nil,该方法没有效果.
 */
- (void)removeImageForKey:(NSString *)key;

/**
 删除缓存中指定键的映像.
 该方法立即返回,并在后台执行删除操作.
 
 @param key  识别要删除的图像的键.如果nil,该方法没有效果.
 @param type 要删除图像的缓存类型.
 */
- (void)removeImageForKey:(NSString *)key withType:(CSImageCacheType)type;

/**
 返回一个布尔值,指示给定键是否在缓存中.
 如果图像不在内存中,则此方法可能会阻塞线程,直到文件读取完成.
 
 @param key 标识图像的字符串. 如果nil,只返回NO.
 @return 图像是否在缓存中.
 */
- (BOOL)containsImageForKey:(NSString *)key;

/**
 返回一个布尔值,指示给定键是否在缓存中.
 如果图像不在内存中,并且'type'包含'CSImageCacheTypeDisk',此方法可能会阻塞线程,直到文件读取完成.
 
 @param key  标识图像的字符串. 如果nil,只返回NO.
 @param type The cache type.
 @return 图像是否在缓存中.
 */
- (BOOL)containsImageForKey:(NSString *)key withType:(CSImageCacheType)type;

/**
 返回与给定键相关联的图像.
 如果图像不在内存中,则此方法可能会阻塞线程,直到文件读取完成.
 
 @param key 标识图像的字符串,如果nil,则返回nil.
 @return 与键相关联的图像,如果没有图像与键相关联,则返回nil.
 */
- (nullable UIImage *)getImageForKey:(NSString *)key;

/**
 返回与给定键相关联的图像.
 如果图像不在内存中,并且'type'包含'CSImageCacheTypeDisk',此方法可能会阻塞线程,直到文件读取完成.
 
 @param key 标识图像的字符串,如果nil,则返回nil.
 @return 与键相关联的图像,如果没有图像与键相关联,则返回nil.
 */
- (nullable UIImage *)getImageForKey:(NSString *)key withType:(CSImageCacheType)type;

/**
 异步获取与给定键相关联的图像.
 
 @param key   标识图像的字符串,如果nil,则返回nil.
 @param type  The cache type.
 @param block 完成回调(主线程执行).
 */
- (void)getImageForKey:(NSString *)key
              withType:(CSImageCacheType)type
             withBlock:(void(^)(UIImage * _Nullable image, CSImageCacheType type))block;

/**
 返回与给定键相关联的图像数据.
 此方法可能会阻塞线程,直到文件读取完成.
 
 @param key 标识图像的字符串,如果nil,则返回nil.
 @return 与键相关联的图像数据,如果没有图像与键相关联,则返回 nil.
 */
- (nullable NSData *)getImageDataForKey:(NSString *)key;

/**
 异步获取与给定键相关联的图像数据.
 
 @param key   标识图像的字符串,如果nil,则返回nil.
 @param block 完成回调(主线程执行).
 */
- (void)getImageDataForKey:(NSString *)key
                 withBlock:(void(^)(NSData * _Nullable imageData))block;

@end
NS_ASSUME_NONNULL_END

