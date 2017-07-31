//
//  UIButton+CSWebImage.h
//  CSCategory
//
//  Created by mac on 2017/7/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_include(<CSKit/CSKit.h>)
#import <CSKit/CSWebImageManager.h>
#else
#import "CSWebImageManager.h"
#endif

NS_ASSUME_NONNULL_BEGIN


@interface UIButton (CSWebImage)



#pragma mark - image

/**
 指定状态的当前图像URL
 */
- (nullable NSURL *)imageURLForState:(UIControlState)state;

/**
 用指定的URL为指定的状态设置按钮的image
  
  @param imageURL      图像url（远程或本地文件路径）.
  @param state         使用指定图像的状态.
  @param placeholder   首先要设置的映像,直到映像请求完成.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(nullable UIImage *)placeholder;

/**
 用指定的URL为指定的状态设置按钮的image
  
  @param imageURL      图像url（远程或本地文件路径）.
  @param state         使用指定图像的状态.
  @param options       请求图像时使用的选项.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
               forState:(UIControlState)state
                options:(CSWebImageOptions)options;

/**
 用指定的URL为指定的状态设置按钮的image
  
  @param imageURL      图像url（远程或本地文件路径）.
  @param state         使用指定图像的状态.
  @param placeholder   首先要设置的映像,直到映像请求完成.
  @param options       请求图像时使用的选项.
  @param completion    图像请求完成时调用块(主线程).
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(nullable UIImage *)placeholder
                options:(CSWebImageOptions)options
             completion:(nullable CSWebImageCompletionBlock)completion;

/**
 用指定的URL为指定的状态设置按钮的image
  
  @param imageURL      图像url（远程或本地文件路径）.
  @param state         使用指定图像的状态.
  @param placeholder   首先要设置的映像,直到映像请求完成.
  @param options       请求图像时使用的选项.
  @param progress      在图像请求期间调用块(在主线程上).
  @param transform     调用块(在后台线程上)执行其他图像处理.
  @param completion    图像请求完成时调用块(主线程).
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(nullable UIImage *)placeholder
                options:(CSWebImageOptions)options
               progress:(nullable CSWebImageProgressBlock)progress
              transform:(nullable CSWebImageTransformBlock)transform
             completion:(nullable CSWebImageCompletionBlock)completion;

/**
 用指定的URL为指定的状态设置按钮的image
  
  @param imageURL      图像url（远程或本地文件路径）.
  @param state         使用指定图像的状态.
  @param placeholder   首先要设置的映像,直到映像请求完成.
  @param options       请求图像时使用的选项.
  @param manager       经理创建图像请求操作.
  @param progress      在图像请求期间调用块(在主线程上).
  @param transform     调用块(在后台线程上)执行其他图像处理.
  @param completion    图像请求完成时调用块(主线程).
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(nullable UIImage *)placeholder
                options:(CSWebImageOptions)options
                manager:(nullable CSWebImageManager *)manager
               progress:(nullable CSWebImageProgressBlock)progress
              transform:(nullable CSWebImageTransformBlock)transform
             completion:(nullable CSWebImageCompletionBlock)completion;

/**
 取消指定状态的当前图像请求。
 @param state 使用指定图像的状态。
 */
- (void)cancelImageRequestForState:(UIControlState)state;



#pragma mark - background image

/**
 当前backgroundImage指定状态的URL.
 */
- (nullable NSURL *)backgroundImageURLForState:(UIControlState)state;

/**
 用指定的URL为指定的状态设置按钮的backgroundImage
  
  @param imageURL      图像url（远程或本地文件路径）.
  @param state         使用指定图像的状态.
  @param placeholder   首先要设置的映像,直到映像请求完成.
  */
- (void)setBackgroundImageWithURL:(nullable NSURL *)imageURL
                         forState:(UIControlState)state
                      placeholder:(nullable UIImage *)placeholder;

/**
 用指定的URL为指定的状态设置按钮的backgroundImage
  
  @param imageURL      图像url（远程或本地文件路径）.
  @param state         使用指定图像的状态.
  @param options       请求图像时使用的选项.
  */
- (void)setBackgroundImageWithURL:(nullable NSURL *)imageURL
                         forState:(UIControlState)state
                          options:(CSWebImageOptions)options;

/**
 用指定的URL为指定的状态设置按钮的backgroundImage
  
  @param imageURL      图像url（远程或本地文件路径）.
  @param state         使用指定图像的状态.
  @param placeholder   首先要设置的映像,直到映像请求完成.
  @param options       请求图像时使用的选项.
  @param completion    图像请求完成时调用块(主线程).
  */
- (void)setBackgroundImageWithURL:(nullable NSURL *)imageURL
                         forState:(UIControlState)state
                      placeholder:(nullable UIImage *)placeholder
                          options:(CSWebImageOptions)options
                       completion:(nullable CSWebImageCompletionBlock)completion;

/**
 用指定的URL为指定的状态设置按钮的backgroundImage
  
 @param imageURL      图像url（远程或本地文件路径）.
 @param state         使用指定图像的状态.
 @param placeholder   首先要设置的映像,直到映像请求完成.
 @param options       请求图像时使用的选项.
 @param progress      在图像请求期间调用块(在主线程上).
 @param transform     调用块(在后台线程上)执行其他图像处理.
 @param completion    图像请求完成时调用块(主线程).
  */
- (void)setBackgroundImageWithURL:(nullable NSURL *)imageURL
                         forState:(UIControlState)state
                      placeholder:(nullable UIImage *)placeholder
                          options:(CSWebImageOptions)options
                         progress:(nullable CSWebImageProgressBlock)progress
                        transform:(nullable CSWebImageTransformBlock)transform
                       completion:(nullable CSWebImageCompletionBlock)completion;


/**
 用指定的URL为指定的状态设置按钮的backgroundImage
  
  @param imageURL      图像url（远程或本地文件路径）.
  @param state         使用指定图像的状态.
  @param placeholder   首先要设置的映像,直到映像请求完成.
  @param options       请求图像时使用的选项.
  @param manager       经理创建图像请求操作.
  @param progress      在图像请求期间调用块(在主线程上).
  @param transform     调用块(在后台线程上)执行其他图像处理.
  @param completion    图像请求完成时调用块(主线程).
 */
- (void)setBackgroundImageWithURL:(nullable NSURL *)imageURL
                         forState:(UIControlState)state
                      placeholder:(nullable UIImage *)placeholder
                          options:(CSWebImageOptions)options
                          manager:(nullable CSWebImageManager *)manager
                         progress:(nullable CSWebImageProgressBlock)progress
                        transform:(nullable CSWebImageTransformBlock)transform
                       completion:(nullable CSWebImageCompletionBlock)completion;

/**
 取消指定状态的当前backgroundImage请求.
 */
- (void)cancelBackgroundImageRequestForState:(UIControlState)state;




@end
NS_ASSUME_NONNULL_END


