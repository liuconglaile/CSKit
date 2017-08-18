//
//  CSHTTPSessionManager.h
//  NewWorkersAbout
//
//  Created by mac on 16/11/16.
//  Copyright © 2016年 CS-Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBASE_URL            @""
#define kTimeoutInterval     10.0f

/**
 网络管理者
 */
@interface CSHTTPSessionManager : NSObject

typedef void(^CSDownloadProgressBlock)(NSProgress *downloadProgress);
typedef void(^CSSuccessBlock)         (id responseObject);
typedef void(^CSFailureBlock)         (NSError   *error);


#pragma mark - sharedHTTPSessionManager
/**
 获取网络管理者单例

 @return 网络管理者对象
 */
+ (instancetype)sharedHTTPSessionManager;

#pragma mark - get
/**
 没有进度条的get请求

 @param urlString url
 @param parameters 参数
 @param netIdentifier 请求标志
 @param successBlock 成功
 @param failureBlock 失败
 */
- (void)get:(NSString *)urlString parameters:(id)parameters netIdentifier:(NSString *)netIdentifier success:(CSSuccessBlock)successBlock failure:(CSFailureBlock)failureBlock;

/**
 有进度条的get请求

 @param urlString url
 @param parameter 参数
 @param netIdentifier 请求标志
 @param downloadProgress 进度
 @param successBlock 成功
 @param failureBlock 失败
 */
- (void)get:(NSString *)urlString parameters:(id)parameter netIdentifier:(NSString *)netIdentifier progress:(CSDownloadProgressBlock)downloadProgress success:(CSSuccessBlock)successBlock failure:(CSFailureBlock)failureBlock;


#pragma mark - post
/**
 没有进度条的post请求

 @param urlString url
 @param parameters 参数
 @param netIdentifier 请求标志
 @param successBlock 成功
 @param failureBlock 失败
 */
- (void)post:(NSString *)urlString parameters:(id)parameters netIdentifier:(NSString *)netIdentifier success:(CSSuccessBlock)successBlock failure:(CSFailureBlock)failureBlock;
/**
 有进度条的post请求

 @param urlString url
 @param parameters 参数
 @param netIdentifier 请求标志
 @param downloadProgress 进度
 @param successBlock 成功
 @param failureBlock 失败
 */
- (void)post:(NSString *)urlString parameters:(id)parameters netIdentifier:(NSString *)netIdentifier progress:(CSDownloadProgressBlock)downloadProgress success:(CSSuccessBlock)successBlock failure:(CSFailureBlock)failureBlock;

#pragma mark - other

#pragma mark - 取消相关
/**
 取消所有网络请求
 */
- (void)cancelAllNetworking;

/**
 取消一组网络请求

 @param netIdentifier 网络请求标志
 */
- (void)cancelNetworkingWithNetIdentifierArray:(NSArray <NSString *> *)netIdentifier;

/**
 取消对应的网络请求

 @param netIdentifier 网络请求标志
 */
- (void)cancelNetworkingWithNetIdentifier:(NSString *)netIdentifier;

/**
 获取正在进行的网络请求

 @return 正在进行的网络请求标志数组
 */
- (NSArray <NSString *>*)getUnderwayNetIdentifierArray;

#pragma mark - 暂停相关
/**
 暂停所有网络请求
 */
- (void)suspendAllNetworking;

/**
 暂停一组网络请求

 @param netIdentifierArray 网络标志数组
 */
- (void)suspendNetworkingWithNetIdentifierArray:(NSArray <NSString *> *)netIdentifierArray;

/**
 暂停对应的网络请求

 @param netIdentifier 网络标志
 */
- (void)suspendNetworkingWithNetIdentifier:(NSString *)netIdentifier;

/**
 获取正暂停的网络请求

 @return 返回网络标志数组
 */
- (NSArray <NSString *>*)getSuspendNetIdentifierArray;

#pragma mark - 恢复相关

/**
 恢复所有暂停的网络请求
 */
- (void)resumeAllNetworking;

/**
 恢复一组暂停的网络请求

 @param netIdentifierArray 网络请求标志数组
 */
- (void)resumeNetworkingWithNetIdentifierArray:(NSArray <NSString *> *)netIdentifierArray;

/**
 恢复暂停的的网络请求

 @param netIdentifier 网络请求标志
 */
- (void)resumeNetworkingWithNetIdentifier:(NSString *)netIdentifier;


@end
