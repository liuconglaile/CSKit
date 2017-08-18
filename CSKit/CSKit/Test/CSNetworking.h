//
//  CSNetworking.h
//  NewWorkersAbout
//
//  Created by mac on 16/11/17.
//  Copyright © 2016年 CS-Moming. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class NSURLSessionTask;



/**
 上传进度
 
 @param bytesWritten 已上传的大小
 @param totalBytesWritten 总上传大小
 */
typedef void (^CSUploadProgress)  (int64_t bytesWritten, int64_t totalBytesWritten);

/**
 下载进度
 
 @param bytesRead 已下载的大小
 @param totalBytesRead 文件总大小
 */
typedef void (^CSDownloadProgress)(int64_t bytesRead, int64_t totalBytesRead);
typedef CSDownloadProgress CSGetProgress;
typedef CSDownloadProgress CSPostProgress;


/**
 响应格式
 
 - kCSResponseTypeJSON: 默认json
 - kCSResponseTypeXML: XML
 - kCSResponseTypeData: 特殊情况下,一转换服务器就无法识别的,默认会尝试转换成JSON,若失败则需要自己去转换
 */
typedef NS_ENUM(NSUInteger, CSResponseType) {
    kCSResponseTypeJSON = 1,
    kCSResponseTypeXML  = 2,
    kCSResponseTypeData = 3
};


/**
 请求类型
 
 - kCSRequestTypeJSON: 默认 json
 - kCSRequestTypePlainText: 普通text/html
 */
typedef NS_ENUM(NSUInteger, CSRequestType) {
    kCSRequestTypeJSON       = 1,
    kCSRequestTypePlainText  = 2
};

/**
 请勿直接使用NSURLSessionDataTask,以减少对第三方的依赖
 所有接口返回的类型都是基类NSURLSessionTask，若要接收返回值且处理，请转换成对应的子类类型
 */
typedef NSURLSessionTask CSURLSessionTask;
typedef void(^CSResponseSuccess)(id response);
typedef void(^CSResponseFail)(NSError *error);


/*! 基于AFNetworking的网络层封装类. */
@interface CSNetworking : NSObject


/**
 用于指定网络请求接口的基础url，如：http://henishuo.com或者http://101.200.209.244
 通常在AppDelegate中启动时就设置一次就可以了。如果接口有来源于多个服务器，可以调用更新
 
 @param baseUrl 网络接口的基础url
 */
+ (void)updateBaseUrl:(NSString *)baseUrl;
+ (NSString *)baseUrl;


/**
 默认只缓存GET请求的数据,对于POST请求是不缓存的.
 如果要缓存POST获取的数据,需要手动调用设置
 对JSON类型数据有效,对于PLIST、XML不确定！
 
 @param isCacheGet 默认为YES
 @param shouldCachePost 默认为NO
 */
+ (void)cacheGetRequest:(BOOL)isCacheGet shoulCachePost:(BOOL)shouldCachePost;

/**
 获取缓存总大小/bytes
 
 @return 缓存大小
 */
+ (unsigned long long)totalCacheSize;

/** 清除缓存 */
+ (void)clearCaches;

/**
 开启或关闭接口打印信息
 
 @param isDebug 开发期最好打开,默认是NO
 */
+ (void)enableInterfaceDebug:(BOOL)isDebug;


/**
 配置请求格式,默认为JSON.
 如果要求传XML或者PLIST,请在全局配置一下
 
 @param requestType 请求格式,默认为JSON
 @param responseType 响应格式,默认为JSON
 @param shouldAutoEncode YES or NO,默认为NO.是否自动编码 url
 @param shouldCallbackOnCancelRequest 当取消请求时,是否要回调.默认为YES
 */
+ (void)configRequestType:(CSRequestType)requestType
             responseType:(CSResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
  callbackOnCancelRequest:(BOOL)shouldCallbackOnCancelRequest;


/**
 配置公共的请求头,只调用一次即可,通常放在应用启动的时候配置就可以了
 
 @param httpHeaders 只需要将与服务器商定的固定参数设置即可
 */
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders;


+ (void)cancelAllRequest;

+ (void)cancelRequestWithURL:(NSString *)url;


+ (CSURLSessionTask *)getWithUrl:(NSString *)url
                    refreshCache:(BOOL)refreshCache
                         success:(CSResponseSuccess)success
                            fail:(CSResponseFail)fail;

+ (CSURLSessionTask *)getWithUrl:(NSString *)url
                    refreshCache:(BOOL)refreshCache
                          params:(NSDictionary *)params
                         success:(CSResponseSuccess)success
                            fail:(CSResponseFail)fail;

+ (CSURLSessionTask *)getWithUrl:(NSString *)url
                    refreshCache:(BOOL)refreshCache
                          params:(NSDictionary *)params
                        progress:(CSGetProgress)progress
                         success:(CSResponseSuccess)success
                            fail:(CSResponseFail)fail;

+ (CSURLSessionTask *)postWithUrl:(NSString *)url
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary *)params
                          success:(CSResponseSuccess)success
                             fail:(CSResponseFail)fail;

+ (CSURLSessionTask *)postWithUrl:(NSString *)url
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary *)params
                         progress:(CSPostProgress)progress
                          success:(CSResponseSuccess)success
                             fail:(CSResponseFail)fail;

+ (CSURLSessionTask *)uploadWithImages:(NSArray *)images
                                   url:(NSString *)url
                              filename:(NSString *)filename
                                  name:(NSString *)name
                              mimeType:(NSString *)mimeType
                            parameters:(NSDictionary *)parameters
                              progress:(CSUploadProgress)progress
                               success:(CSResponseSuccess)success
                                  fail:(CSResponseFail)fail;

+ (CSURLSessionTask *)uploadWithImage:(UIImage *)image
                                  url:(NSString *)url
                             filename:(NSString *)filename
                                 name:(NSString *)name
                             mimeType:(NSString *)mimeType
                           parameters:(NSDictionary *)parameters
                             progress:(CSUploadProgress)progress
                              success:(CSResponseSuccess)success
                                 fail:(CSResponseFail)fail;

+ (CSURLSessionTask *)uploadFileWithUrl:(NSString *)url
                          uploadingFile:(NSString *)uploadingFile
                               progress:(CSUploadProgress)progress
                                success:(CSResponseSuccess)success
                                   fail:(CSResponseFail)fail;

+ (CSURLSessionTask *)downloadWithUrl:(NSString *)url
                           saveToPath:(NSString *)saveToPath
                             progress:(CSDownloadProgress)progressBlock
                              success:(CSResponseSuccess)success
                              failure:(CSResponseFail)failure;


@end



