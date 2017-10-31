//
//  CSWebImageOperation.h
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSImageCache.h"
#import "CSWebImageManager.h"


NS_ASSUME_NONNULL_BEGIN



/**
 CSWebImageOperation类是一个NSOperation子类,用于从URL请求中获取图像.
  
 @discussion
 这是一个异步操作.
 您通常通过将其添加到操作队列来执行,或者调用'start'手动执行它.
 当操作开始时,它将:
  
 1.从缓存中获取图像(如果存在),使用'completion'块返回.
 2.启动URL连接以从请求中获取图像,调用'progress'通知请求进度(如果由渐进式选项启用,则调用'completion'块返回逐行图像).
 3.通过调用'transform'块处理图像.
 4.将图像缓存,并用'completion'块返回.
 */
@interface CSWebImageOperation : NSOperation

@property (nonatomic, strong, readonly)           NSURLRequest      *request;  ///< 图片网址请求.
@property (nullable, nonatomic, strong, readonly) NSURLResponse     *response; ///< 请求的响应.
@property (nullable, nonatomic, strong, readonly) CSImageCache      *cache;    ///< 图像缓存.
@property (nonatomic, strong, readonly)           NSString          *cacheKey; ///< 图像缓存key.
@property (nonatomic, readonly)                   CSWebImageOptions options;   ///< 操作的选项.

/**
 URL连接是否应该咨询证书存储以验证连接. Default is YES.
 @discussion 这是在'NSURLConnectionDelegate'方法'-connectionShouldUseCredentialStorage:'中返回的值.
 */
@property (nonatomic) BOOL shouldUseCredentialStorage;

/**
 在'-connection:didReceiveAuthenticationChallenge:'中用于认证挑战的凭据
 @discussion 如果存在请求URL的用户名或密码的任何共享凭据,这将被覆盖.
 */
@property (nullable, nonatomic, strong) NSURLCredential *credential;


/**
 创建并返回新操作
 
 您应该调用'start'来执行此操作,或者可以将操作添加到操作队列

 @param request     请求图像请求,不能为 nil
 @param options     指定用于此操作的选项的掩码
 @param cache       图像缓存.传递nil, 可以避免图像缓存
 @param cacheKey    图像缓存键.传递nil, 可以避免图像缓存
 @param progress    图像提取进度中调用的回调(该块将在后台线程中被调用.传递nil,可以避免它)
 @param transform   在图像提取完成之前调用的块执行额外的图像处理
 @param completion  当图像提取完成或取消时调用的块
 @return            图像请求opeartion,如果发生错误,则为nil
 */
- (instancetype)initWithRequest:(NSURLRequest *)request
                        options:(CSWebImageOptions)options
                          cache:(nullable CSImageCache *)cache
                       cacheKey:(nullable NSString *)cacheKey
                       progress:(nullable CSWebImageProgressBlock)progress
                      transform:(nullable CSWebImageTransformBlock)transform
                     completion:(nullable CSWebImageCompletionBlock)completion NS_DESIGNATED_INITIALIZER;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end
NS_ASSUME_NONNULL_END


