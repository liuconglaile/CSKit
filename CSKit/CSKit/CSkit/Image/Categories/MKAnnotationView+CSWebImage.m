//
//  MKAnnotationView+CSWebImage.m
//  CSCategory
//
//  Created by mac on 2017/7/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "MKAnnotationView+CSWebImage.h"
#import <objc/runtime.h>
#import <pthread.h>

//#import "CSMacrosHeader.h"
#import "_CSWebImageSetter.h"
#import "CSWebImageOperation.h"

/**
 在每个类别实现之前添加这个宏,所以我们不必使用  -all_load 或 -force_load 仅从静态库加载对象文件包含类别,没有类.
 更多信息: http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html .
 *******************************************************************************
 
 示例:
 CSSYNTH_DUMMY_CLASS(NSString_CSAdd)
 
 @param _name_ 类别名
 @return 添加的类别
 */
#ifndef CSSYNTH_DUMMY_CLASS
#define CSSYNTH_DUMMY_CLASS(_name_) \
@interface CSSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation CSSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif



/**
 调度_时间_延迟
 
 @param second 延迟秒数
 @return <#return value description#>
 */
//static inline dispatch_time_t dispatch_time_delay(NSTimeInterval second) {
//    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
//}

///** 从现在返回dispatch_wall_time延迟. */
//static inline dispatch_time_t dispatch_walltime_delay(NSTimeInterval second) {
//    return dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
//}

///** 从NSDate返回dispatch_wall_time */
//static inline dispatch_time_t dispatch_walltime_date(NSDate *date) {
//    NSTimeInterval interval;
//    double second, subsecond;
//    struct timespec time;
//    dispatch_time_t milestone;
//
//    interval = [date timeIntervalSince1970];
//    subsecond = modf(interval, &second);
//    time.tv_sec = second;
//    time.tv_nsec = subsecond * NSEC_PER_SEC;
//    milestone = dispatch_walltime(&time, 0);
//    return milestone;
//}

///** 是否在主队列/线程中 */
//static inline bool dispatch_is_main_queue() {
//    return pthread_main_np() != 0;
//}

/** 在主队列上提交用于异步执行的块,并立即返回 */
static inline void dispatch_async_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

///** 在主队列上提交执行块,并等待直到块完成 */
//static inline void dispatch_sync_on_main_queue(void (^block)(void)) {
//    if (pthread_main_np()) {
//        block();
//    } else {
//        dispatch_sync(dispatch_get_main_queue(), block);
//    }
//}

///** 初始化一个pthread互斥体 */
//static inline void pthread_mutex_init_recursive(pthread_mutex_t *mutex, bool recursive) {
//#define CSMUTEX_ASSERT_ON_ERROR(x_) do { \
//__unused volatile int res = (x_); \
//assert(res == 0); \
//} while (0)
//    assert(mutex != NULL);
//    if (!recursive) {
//        CSMUTEX_ASSERT_ON_ERROR(pthread_mutex_init(mutex, NULL));
//    } else {
//        pthread_mutexattr_t attr;
//        CSMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_init (&attr));
//        CSMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE));
//        CSMUTEX_ASSERT_ON_ERROR(pthread_mutex_init (mutex, &attr));
//        CSMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_destroy (&attr));
//    }
//#undef CSMUTEX_ASSERT_ON_ERROR
//}



CSSYNTH_DUMMY_CLASS(MKAnnotationView_CSWebImage)

static int _CSWebImageSetterKey;

@implementation MKAnnotationView (CSWebImage)

- (NSURL *)imageURL {
    _CSWebImageSetter *setter = objc_getAssociatedObject(self, &_CSWebImageSetterKey);
    return setter.imageURL;
}

- (void)setImageURL:(NSURL *)imageURL {
    [self setImageWithURL:imageURL
              placeholder:nil
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self setImageWithURL:imageURL
              placeholder:placeholder
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)setImageWithURL:(NSURL *)imageURL options:(CSWebImageOptions)options {
    [self setImageWithURL:imageURL
              placeholder:nil
                  options:options
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)setImageWithURL:(NSURL *)imageURL
            placeholder:(UIImage *)placeholder
                options:(CSWebImageOptions)options
             completion:(CSWebImageCompletionBlock)completion {
    [self setImageWithURL:imageURL
              placeholder:placeholder
                  options:options
                  manager:nil
                 progress:nil
                transform:nil
               completion:completion];
}

- (void)setImageWithURL:(NSURL *)imageURL
            placeholder:(UIImage *)placeholder
                options:(CSWebImageOptions)options
               progress:(CSWebImageProgressBlock)progress
              transform:(CSWebImageTransformBlock)transform
             completion:(CSWebImageCompletionBlock)completion {
    [self setImageWithURL:imageURL
              placeholder:placeholder
                  options:options
                  manager:nil
                 progress:progress
                transform:transform
               completion:completion];
}

- (void)setImageWithURL:(NSURL *)imageURL
            placeholder:(UIImage *)placeholder
                options:(CSWebImageOptions)options
                manager:(CSWebImageManager *)manager
               progress:(CSWebImageProgressBlock)progress
              transform:(CSWebImageTransformBlock)transform
             completion:(CSWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [CSWebImageManager sharedManager];
    
    _CSWebImageSetter *setter = objc_getAssociatedObject(self, &_CSWebImageSetterKey);
    if (!setter) {
        setter = [_CSWebImageSetter new];
        objc_setAssociatedObject(self, &_CSWebImageSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    dispatch_async_on_main_queue(^{
        if ((options & CSWebImageOptionSetImageWithFadeAnimation) &&
            !(options & CSWebImageOptionAvoidSetImage)) {
            if (!self.highlighted) {
                [self.layer removeAnimationForKey:_CSWebImageFadeAnimationKey];
            }
        }
        if (!imageURL) {
            if (!(options & CSWebImageOptionIgnorePlaceHolder)) {
                self.image = placeholder;
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & CSWebImageOptionUseNSURLCache) &&
            !(options & CSWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:CSImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & CSWebImageOptionAvoidSetImage)) {
                self.image = imageFromMemory;
            }
            if(completion) completion(imageFromMemory, imageURL, CSWebImageFromMemoryCacheFast, CSWebImageStageFinished, nil);
            return;
        }
        
        if (!(options & CSWebImageOptionIgnorePlaceHolder)) {
            self.image = placeholder;
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([_CSWebImageSetter setterQueue], ^{
            CSWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            CSWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, CSWebImageFromType from, CSWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == CSWebImageStageFinished || stage == CSWebImageStageProgress) && image && !(options & CSWebImageOptionAvoidSetImage);
                BOOL showFade = ((options & CSWebImageOptionSetImageWithFadeAnimation) && !self.highlighted);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        if (showFade) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = stage == CSWebImageStageFinished ? _CSWebImageFadeTime : _CSWebImageProgressiveFadeTime;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [self.layer addAnimation:transition forKey:_CSWebImageFadeAnimationKey];
                        }
                        self.image = image;
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, CSWebImageFromNone, CSWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            newSentinel = [setter setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter;
        });
    });
}

- (void)cancelCurrentImageRequest {
    _CSWebImageSetter *setter = objc_getAssociatedObject(self, &_CSWebImageSetterKey);
    if (setter) [setter cancel];
}

@end
