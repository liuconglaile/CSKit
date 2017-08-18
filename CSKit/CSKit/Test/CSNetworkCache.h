//
//  CSNetworkCache.h
//  NewWorkersAbout
//
//  Created by mac on 16/11/16.
//  Copyright © 2016年 CS-Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CSNetworkCacheCompletionBlock)(BOOL result);
/**
 *  一键缓存数据
 */
@interface CSNetworkCache : NSObject

/**
 写入/更新缓存(同步) [按APP版本号缓存,不同版本APP,同一接口缓存数据互不干扰]

 @param jsonResponse 要写入的数据(JSON)
 @param URL 数据请求URL
 @return 是否写入成功
 */
+(BOOL)saveJsonResponseToCacheFile:(id)jsonResponse andURL:(NSString *)URL;

/**
 写入/更新缓存(异步) [按APP版本号缓存,不同版本APP,同一接口缓存数据互不干扰]

 @param jsonResponse 要写入的数据(JSON)
 @param URL 数据请求URL
 @param completedBlock 异步完成回调(主线程回调)
 */
+(void)save_asyncJsonResponseToCacheFile:(id)jsonResponse andURL:(NSString *)URL completed:(CSNetworkCacheCompletionBlock)completedBlock;

/**
 获取缓存的对象(同步)

 @param URL 数据请求URL
 @return 缓存对象
 */
+(id)cacheJsonWithURL:(NSString *)URL;

/**
 清除所有缓存

 @return 是否成功
 */
+(BOOL)clearCache;

/**
 获取缓存总大小(单位:M)

 @return 缓存大小
 */
+ (float)cacheSize;

@end
