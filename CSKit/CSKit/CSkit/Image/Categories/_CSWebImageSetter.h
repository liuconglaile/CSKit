//
//  _CSWebImageSetter.h
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSWebImageManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const _CSWebImageFadeAnimationKey;
extern const NSTimeInterval _CSWebImageFadeTime;
extern const NSTimeInterval _CSWebImageProgressiveFadeTime;




/**
 通过Web图像类别中使用私有类.通常,你不应该直接使用这个类
 */
@interface _CSWebImageSetter : NSObject

/// 当前图片网址.
@property (nullable, nonatomic, readonly) NSURL *imageURL;
/// 当前定点.
@property (nonatomic, readonly) int32_t sentinel;

/// 对于Web图像创建新的操作,并返回一个标记值.
- (int32_t)setOperationWithSentinel:(int32_t)sentinel
                                url:(nullable NSURL *)imageURL
                            options:(CSWebImageOptions)options
                            manager:(CSWebImageManager *)manager
                           progress:(nullable CSWebImageProgressBlock)progress
                          transform:(nullable CSWebImageTransformBlock)transform
                         completion:(nullable CSWebImageCompletionBlock)completion;

/// 取消并返回一个标记值.imageURL将设置为nil.
- (int32_t)cancel;

/// 取消并返回一个标记值.imageURL将被设置为新值.
- (int32_t)cancelWithNewURL:(nullable NSURL *)imageURL;

/// 一个队列来设置操作.
+ (dispatch_queue_t)setterQueue;

@end
NS_ASSUME_NONNULL_END


