//
//  CSWebImageManager.h
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>


#if __has_include(<CSKit/CSKit.h>)
#import <CSKit/CSImageCache.h>
#else
#import "CSImageCache.h"
#endif

@class CSWebImageOperation;

NS_ASSUME_NONNULL_BEGIN



/**
 控制图像操作的选项
 
 - CSWebImageOptionShowNetworkActivity: 在下载图片时显示状态栏上的网络活动
 - CSWebImageOptionProgressive: 在下载期间 显示渐进&隔行扫描&基线图像(与Web浏览器相同)
 - CSWebImageOptionProgressiveBlur: 在下载过程中显示模糊的逐行JPEG或隔行扫描图像.这将忽略基线图像以获得更好的用户体验
 - CSWebImageOptionUseNSURLCache: 使用NSURLCache而不是CSImageCache
 - CSWebImageOptionAllowInvalidSSLCertificates: 允许不受信任的SSL ceriticates
 - CSWebImageOptionAllowBackgroundTask: 允许后台任务在应用程序处于后台时下载图像
 - CSWebImageOptionHandleCookies: 处理存储在NSHTTPCookieStore中的cookie
 - CSWebImageOptionRefreshImageCache: 从远程加载图像并刷新图像缓存
 - CSWebImageOptionIgnoreDiskCache: 不要将图像加载磁盘缓存/也不从磁盘缓存加载图片
 - CSWebImageOptionIgnorePlaceHolder: 在设置新的URL之前,不要更改视图的图像
 - CSWebImageOptionIgnoreImageDecoding: 忽略图像解码.这可用于图像下载而不显示
 - CSWebImageOptionIgnoreAnimatedImage: 忽略多帧图像解码.这将处理GIF&APNG&WebP&ICO图像作为单帧图像
 - CSWebImageOptionSetImageWithFadeAnimation: 设置使用淡入淡出动画查看的图像.这将在图像视图的图层上添加'褪色'动画,以获得更好的用户体验
 - CSWebImageOptionAvoidSetImage: 图像提取完成后,请勿将图像设置为视图.您可以手动设置图像
 - CSWebImageOptionIgnoreFailedURL: 当URL无法下载时,此标志会将URL添加到黑名单(内存中),因此库不会继续尝试
 */
typedef NS_OPTIONS(NSUInteger, CSWebImageOptions) {
    CSWebImageOptionShowNetworkActivity         = 1 << 0,
    CSWebImageOptionProgressive                 = 1 << 1,
    CSWebImageOptionProgressiveBlur             = 1 << 2,
    CSWebImageOptionUseNSURLCache               = 1 << 3,
    CSWebImageOptionAllowInvalidSSLCertificates = 1 << 4,
    CSWebImageOptionAllowBackgroundTask         = 1 << 5,
    CSWebImageOptionHandleCookies               = 1 << 6,
    CSWebImageOptionRefreshImageCache           = 1 << 7,
    CSWebImageOptionIgnoreDiskCache             = 1 << 8,
    CSWebImageOptionIgnorePlaceHolder           = 1 << 9,
    CSWebImageOptionIgnoreImageDecoding         = 1 << 10,
    CSWebImageOptionIgnoreAnimatedImage         = 1 << 11,
    CSWebImageOptionSetImageWithFadeAnimation   = 1 << 12,
    CSWebImageOptionAvoidSetImage               = 1 << 13,
    CSWebImageOptionIgnoreFailedURL             = 1 << 14,
};



/**
 图片来源获取枚举
 
 - CSWebImageFromNone: 默认无设置
 - CSWebImageFromMemoryCacheFast: 立即从内存缓存中获取.如果您调用'setImageWithURL:...',并且图像已经在内存中,那么您将在同一个调用中获取该值
 - CSWebImageFromMemoryCache: 从内存缓存中获取
 - CSWebImageFromDiskCache: 从磁盘缓存中获取
 - CSWebImageFromRemote: 从远程(Web或文件路径)获取
 */
typedef NS_ENUM(NSUInteger, CSWebImageFromType) {
    CSWebImageFromNone = 0,
    CSWebImageFromMemoryCacheFast,
    CSWebImageFromMemoryCache,
    CSWebImageFromDiskCache,
    CSWebImageFromRemote,
};


/**
 指示图像提取完成阶段
 
 - CSWebImageStageProgress: 不完整,渐进中的图像
 - CSWebImageStageCancelled: 取消状态
 - CSWebImageStageFinished: 完成(成功或失败)
 */
typedef NS_ENUM(NSInteger, CSWebImageStage) {
    CSWebImageStageProgress  = -1,
    CSWebImageStageCancelled = 0,
    CSWebImageStageFinished  = 1,
};




/**
 在远程图像提取进度中调用该块

 @param receivedSize 当前进度大小(单位字节)
 @param expectedSize 预计总大小(单位字节)
 */
typedef void(^CSWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);


/**
 在远程图像提取完成之前调用的块进行附加的图像处理

 将在'CSWebImageCompletionBlock'之前调用此块,以便您有机会执行其他图像处理(如调整大小或裁剪).如果不需要转换图像,只需返回'image'参数即可
 
 使用示例:
 您可以剪辑图像,将其模糊并使用以下代码添加圆角:
 
 ^(UIImage *image, NSURL *url) {
     // 也许你需要创建一个@autoreleasepool来限制内存成本.
     image = [image imageByResizeToSize:CGSizeMake(100, 100) contentMode:UIViewContentModeScaleAspectFill];
     image = [image imageByBlurRadius:20 tintColor:nil tintMode:kCGBlendModeNormal saturation:1.2 maskImage:nil];
     image = [image imageByRoundCornerRadius:5];
     return image;
 }
 
 
 @param image 从URL获取的图像
 @param url 图像url(远程或本地文件路径)
 @return 转换后的图像
 */
typedef UIImage * _Nullable (^CSWebImageTransformBlock)(UIImage *image, NSURL *url);


/**
 图像提取完成或取消时调用块

 @param image 图像
 @param url 图像路径(远程&本地)
 @param from 图像来源
 @param stage 发送错误时候返回状态反馈
 @param error 如果操作被取消,则为 NO, 否则 YES
 */
typedef void (^CSWebImageCompletionBlock)(UIImage * _Nullable image,
                                          NSURL *url,
                                          CSWebImageFromType from,
                                          CSWebImageStage stage,
                                          NSError * _Nullable error);








/**
 创建和管理网络图像操作的对象(管理者)
 */
@interface CSWebImageManager : NSObject



/**
 返回全局CSWebImageManager实例
 */
+ (instancetype)sharedManager;



/**
 创建具有图像缓存和操作队列的管理器

 @param cache 管理器使用的图像缓存(通过nil 以避免图像缓存)
 @param queue 处理图像的操作队列(通过 nil 以避免队列设置)
 @return 图片管理器
 */
- (instancetype)initWithCache:(nullable CSImageCache *)cache
                        queue:(nullable NSOperationQueue *)queue NS_DESIGNATED_INITIALIZER;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;


/**
 创建并返回新的图像操作,操作将立即开始

 @param url 图片路径
 @param options 图片操作枚举选项
 @param progress 进度回调
 @param transform 图片过程中处理回调
 @param completion 完成回调
 @return 图片操作管理
 */
- (nullable CSWebImageOperation *)requestImageWithURL:(NSURL *)url
                                              options:(CSWebImageOptions)options
                                             progress:(nullable CSWebImageProgressBlock)progress
                                            transform:(nullable CSWebImageTransformBlock)transform
                                           completion:(nullable CSWebImageCompletionBlock)completion;

/**
 图像缓存使用的图像操作.您可以将其设置为nil以避免图像缓存
 */
@property (nullable, nonatomic, strong) CSImageCache *cache;

/**
 运行映像操作的操作队列.
 您可以将其设置为nil,使新操作立即开始,不需要队列.
 您可以使用此队列来控制最大并发操作数,获取当前操作的状态,或取消此管理器中的所有操作.
 */
@property (nullable, nonatomic, strong) NSOperationQueue *queue;

/**
 共享变换块来处理图像.默认值为nil
  
 当称为'requestImageWithURL:options:progress:transform:completion'和'transform'为nil时,将使用该块。
 */
@property (nullable, nonatomic, copy) CSWebImageTransformBlock sharedTransformBlock;

/**
 图像请求超时间隔(以秒为单位). Default is 15.
 */
@property (nonatomic) NSTimeInterval timeout;

/**
 NSURLCredential使用的用户名, default is nil.
 */
@property (nullable, nonatomic, copy) NSString *username;

/**
 NSURLCredential使用的密码, default is nil.
 */
@property (nullable, nonatomic, copy) NSString *password;

/**
 图像HTTP请求头. Default is "Accept:image/webp,image/\*;q=0.8".
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NSString *> *headers;

/**
 将为每个图像HTTP请求调用一个块来执行附加的HTTP头处理.Default is nil.
 使用此块可以添加或删除指定URL的HTTP头字段
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NSString *> *(^headersFilter)(NSURL *url, NSDictionary<NSString *, NSString *> * _Nullable header);

/**
 将为每个图像操作调用的块.Default is nil.
 使用此块为指定的URL提供自定义图像缓存密钥。
 */
@property (nullable, nonatomic, copy) NSString *(^cacheKeyFilter)(NSURL *url);

/**
 返回指定网址的HTTP标头.
 
 @param url 指定 URL.
 @return HTTP headers.
 */
- (nullable NSDictionary<NSString *, NSString *> *)headersForURL:(NSURL *)url;

/**
 返回指定URL的缓存键.
 
 @param url 指定的URL
 @return 在CSImageCache中使用的缓存key.
 */
- (NSString *)cacheKeyForURL:(NSURL *)url;

@end
NS_ASSUME_NONNULL_END








