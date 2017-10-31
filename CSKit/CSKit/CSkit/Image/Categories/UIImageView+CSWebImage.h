//
//  UIImageView+CSWebImage.h
//  CSCategory
//
//  Created by mac on 2017/7/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSWebImageManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (CSWebImage)


#pragma mark - image

/**
 当前 image URL.
 
 @discussion 设置一个新值,该属性将取消先前的请求操作,并创建一个新的请求操作来获取图像.设置为nil以清除突出显示的图像和图像URL.
 */
@property (nullable, nonatomic, strong) NSURL *imageURL;

/**
 将视图的'Image'设置为指定的URL
 
 @param imageURL    图片链接(远程&本地)
 @param placeholder 占位图
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL placeholder:(nullable UIImage *)placeholder;

/**
 将视图的'Image'设置为指定的URL
 
 @param imageURL    图片链接(远程&本地)
 @param options     请求图像时使用的选项
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL options:(CSWebImageOptions)options;

/**
 将视图的'Image'设置为指定的URL
 
 @param imageURL    图片链接(远程&本地)
 @param placeholder 占位图
 @param options     请求图像时使用的选项
 @param completion  请求完成回调(主线程)
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
            placeholder:(nullable UIImage *)placeholder
                options:(CSWebImageOptions)options
             completion:(nullable CSWebImageCompletionBlock)completion;

/**
 将视图的'Image'设置为指定的URL
 
 @param imageURL    图片链接(远程&本地)
 @param placeholder 占位图
 @param options     请求图像时使用的选项
 @param progress    请求进度回调(主线程)
 @param transform   请求中图片处理回调(后台线程)
 @param completion  请求完成回调(主线程)
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
            placeholder:(nullable UIImage *)placeholder
                options:(CSWebImageOptions)options
               progress:(nullable CSWebImageProgressBlock)progress
              transform:(nullable CSWebImageTransformBlock)transform
             completion:(nullable CSWebImageCompletionBlock)completion;


/**
 将视图的'Image'设置为指定的URL
 
 @param imageURL    图片链接(远程&本地)
 @param placeholder 占位图
 @param options     请求图像时使用的选项
 @param manager     图像请求操作管理器
 @param progress    请求进度回调(主线程)
 @param transform   请求中图片处理回调(后台线程)
 @param completion  请求完成回调(主线程)
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



#pragma mark - highlight image

/**
 当前高亮显示的图像URL.
 
 @discussion 设置一个新值,该属性将取消先前的请求操作,并创建一个新的请求操作来获取图像.设置为nil以清除突出显示的图像和图像URL.
 */
@property (nullable, nonatomic, strong) NSURL *highlightedImageURL;

/**
 将视图的'highlightImage'设置为指定的URL
 
 @param imageURL    图片链接(远程&本地)
 @param placeholder 占位图
 */
- (void)setHighlightedImageWithURL:(nullable NSURL *)imageURL placeholder:(nullable UIImage *)placeholder;

/**
 将视图的'highlightImage'设置为指定的URL
 
 @param imageURL    图片链接(远程&本地)
 @param options     请求图像时使用的选项
 */
- (void)setHighlightedImageWithURL:(nullable NSURL *)imageURL options:(CSWebImageOptions)options;

/**
 将视图的'highlightImage'设置为指定的URL
 
 @param imageURL    图片链接(远程&本地)
 @param placeholder 占位图
 @param options     请求图像时使用的选项
 @param completion  请求完成回调(主线程)
 */
- (void)setHighlightedImageWithURL:(nullable NSURL *)imageURL
                       placeholder:(nullable UIImage *)placeholder
                           options:(CSWebImageOptions)options
                        completion:(nullable CSWebImageCompletionBlock)completion;

/**
 将视图的'highlightImage'设置为指定的URL
 
 @param imageURL    图片链接(远程&本地)
 @param placeholder 占位图
 @param options     请求图像时使用的选项
 @param progress    请求进度回调(主线程)
 @param transform   请求中图片处理回调(后台线程)
 @param completion  请求完成回调(主线程)
 */
- (void)setHighlightedImageWithURL:(nullable NSURL *)imageURL
                       placeholder:(nullable UIImage *)placeholder
                           options:(CSWebImageOptions)options
                          progress:(nullable CSWebImageProgressBlock)progress
                         transform:(nullable CSWebImageTransformBlock)transform
                        completion:(nullable CSWebImageCompletionBlock)completion;


/**
 将视图的'highlightImage'设置为指定的URL
 
 @param imageURL    图片链接(远程&本地)
 @param placeholder 占位图
 @param options     请求图像时使用的选项
 @param manager     图像请求操作管理器
 @param progress    请求进度回调(主线程)
 @param transform   请求中图片处理回调(后台线程)
 @param completion  请求完成回调(主线程)
 */
- (void)setHighlightedImageWithURL:(nullable NSURL *)imageURL
                       placeholder:(nullable UIImage *)placeholder
                           options:(CSWebImageOptions)options
                           manager:(nullable CSWebImageManager *)manager
                          progress:(nullable CSWebImageProgressBlock)progress
                         transform:(nullable CSWebImageTransformBlock)transform
                        completion:(nullable CSWebImageCompletionBlock)completion;

/**
 取消当前高亮显示的图像请求.
 */
- (void)cancelCurrentHighlightedImageRequest;


@end
NS_ASSUME_NONNULL_END




