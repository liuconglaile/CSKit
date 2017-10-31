//
//  CALayer+CSWebImage.h
//  CSCategory
//
//  Created by mac on 2017/7/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CSWebImageManager.h"


NS_ASSUME_NONNULL_BEGIN




/**
 CALayer的Web图像方法.它将图像设置为layer.contents
 */
@interface CALayer (CSWebImage)


@property (nullable, nonatomic, strong) NSURL *imageURL;


/**
 使用指定的URL设置视图的'image'-->layer.contents
 
 @param imageURL 图片链接(远程&本地)
 @param placeholder 占位图
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL placeholder:(nullable UIImage *)placeholder;

/**
 使用指定的URL设置视图的'image'-->layer.contents
 
 @param imageURL 图片链接(远程&本地)
 @param options  请求时图片操作选项
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL options:(CSWebImageOptions)options;

/**
 使用指定的URL设置视图的'image'-->layer.contents
 
 @param imageURL 图片链接(远程&本地)
 @param placeholder 占位图
 @param options  请求时图片操作选项
 @param completion 请求完成回调(主线程)
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
            placeholder:(nullable UIImage *)placeholder
                options:(CSWebImageOptions)options
             completion:(nullable CSWebImageCompletionBlock)completion;

/**
 使用指定的URL设置视图的'image'-->layer.contents
 
 @param imageURL 图片链接(远程&本地)
 @param placeholder 占位图
 @param options  请求时图片操作选项
 @param progress 请求进度回调(主线程)
 @param transform 请求中图片处理回调(后台线程)
 @param completion 请求完成回调(主线程)
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
            placeholder:(nullable UIImage *)placeholder
                options:(CSWebImageOptions)options
               progress:(nullable CSWebImageProgressBlock)progress
              transform:(nullable CSWebImageTransformBlock)transform
             completion:(nullable CSWebImageCompletionBlock)completion;

/**
 使用指定的URL设置视图的'image'-->layer.contents

 @param imageURL 图片链接(远程&本地)
 @param placeholder 占位图
 @param options  请求时图片操作选项
 @param manager 图片下载管理器
 @param progress 请求进度回调(主线程)
 @param transform 请求中图片处理回调(后台线程)
 @param completion 请求完成回调(主线程)
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
            placeholder:(nullable UIImage *)placeholder
                options:(CSWebImageOptions)options
                manager:(nullable CSWebImageManager *)manager
               progress:(nullable CSWebImageProgressBlock)progress
              transform:(nullable CSWebImageTransformBlock)transform
             completion:(nullable CSWebImageCompletionBlock)completion;

/**
 取消当前图像请求.
 */
- (void)cancelCurrentImageRequest;



@end
NS_ASSUME_NONNULL_END


