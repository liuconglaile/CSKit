//
//  UIButton+CSWebImage.m
//  CSCategory
//
//  Created by mac on 2017/7/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIButton+CSWebImage.h"
#import <objc/runtime.h>

#import "_CSWebImageSetter.h"
#import "CSWebImageOperation.h"
#import "CSKitMacro.h"


CSSYNTH_DUMMY_CLASS(UIButton_CSWebImage)

static inline NSNumber *UIControlStateSingle(UIControlState state) {
    if (state & UIControlStateHighlighted) return @(UIControlStateHighlighted);
    if (state & UIControlStateDisabled) return @(UIControlStateDisabled);
    if (state & UIControlStateSelected) return @(UIControlStateSelected);
    return @(UIControlStateNormal);
}

static inline NSArray *UIControlStateMulti(UIControlState state) {
    NSMutableArray *array = [NSMutableArray new];
    if (state & UIControlStateHighlighted) [array addObject:@(UIControlStateHighlighted)];
    if (state & UIControlStateDisabled) [array addObject:@(UIControlStateDisabled)];
    if (state & UIControlStateSelected) [array addObject:@(UIControlStateSelected)];
    if ((state & 0xFF) == 0) [array addObject:@(UIControlStateNormal)];
    return array;
}

static int _CSWebImageSetterKey;
static int _CSWebImageBackgroundSetterKey;


@interface _CSWebImageSetterDicForButton : NSObject
- (_CSWebImageSetter *)setterForState:(NSNumber *)state;
- (_CSWebImageSetter *)lazySetterForState:(NSNumber *)state;
@end

@implementation _CSWebImageSetterDicForButton {
    NSMutableDictionary *_dic;
    dispatch_semaphore_t _lock;
}
- (instancetype)init {
    self = [super init];
    _lock = dispatch_semaphore_create(1);
    _dic = [NSMutableDictionary new];
    return self;
}
- (_CSWebImageSetter *)setterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _CSWebImageSetter *setter = _dic[state];
    dispatch_semaphore_signal(_lock);
    return setter;
    
}
- (_CSWebImageSetter *)lazySetterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _CSWebImageSetter *setter = _dic[state];
    if (!setter) {
        setter = [_CSWebImageSetter new];
        _dic[state] = setter;
    }
    dispatch_semaphore_signal(_lock);
    return setter;
}
@end

@implementation UIButton (CSWebImage)

#pragma mark - image

- (void)_setImageWithURL:(NSURL *)imageURL
          forSingleState:(NSNumber *)state
             placeholder:(UIImage *)placeholder
                 options:(CSWebImageOptions)options
                 manager:(CSWebImageManager *)manager
                progress:(CSWebImageProgressBlock)progress
               transform:(CSWebImageTransformBlock)transform
              completion:(CSWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [CSWebImageManager sharedManager];
    
    _CSWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_CSWebImageSetterKey);
    if (!dic) {
        dic = [_CSWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &_CSWebImageSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    _CSWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    dispatch_async_on_main_queue(^{
        if (!imageURL) {
            if (!(options & CSWebImageOptionIgnorePlaceHolder)) {
                [self setImage:placeholder forState:state.integerValue];
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
                [self setImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, CSWebImageFromMemoryCacheFast, CSWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & CSWebImageOptionIgnorePlaceHolder)) {
            [self setImage:placeholder forState:state.integerValue];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        [self setImage:image forState:state.integerValue];
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

- (void)_cancelImageRequestForSingleState:(NSNumber *)state {
    _CSWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_CSWebImageSetterKey);
    _CSWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)imageURLForState:(UIControlState)state {
    _CSWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_CSWebImageSetterKey);
    _CSWebImageSetter *setter = [dic setterForState:UIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)setImageWithURL:(NSURL *)imageURL forState:(UIControlState)state placeholder:(UIImage *)placeholder {
    [self setImageWithURL:imageURL
                 forState:state
              placeholder:placeholder
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)setImageWithURL:(NSURL *)imageURL forState:(UIControlState)state options:(CSWebImageOptions)options {
    [self setImageWithURL:imageURL
                 forState:state
              placeholder:nil
                  options:options
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)setImageWithURL:(NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(UIImage *)placeholder
                options:(CSWebImageOptions)options
             completion:(CSWebImageCompletionBlock)completion {
    [self setImageWithURL:imageURL
                 forState:state
              placeholder:placeholder
                  options:options
                  manager:nil
                 progress:nil
                transform:nil
               completion:completion];
}

- (void)setImageWithURL:(NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(UIImage *)placeholder
                options:(CSWebImageOptions)options
               progress:(CSWebImageProgressBlock)progress
              transform:(CSWebImageTransformBlock)transform
             completion:(CSWebImageCompletionBlock)completion {
    [self setImageWithURL:imageURL
                 forState:state
              placeholder:placeholder
                  options:options
                  manager:nil
                 progress:progress
                transform:transform
               completion:completion];
}

- (void)setImageWithURL:(NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(UIImage *)placeholder
                options:(CSWebImageOptions)options
                manager:(CSWebImageManager *)manager
               progress:(CSWebImageProgressBlock)progress
              transform:(CSWebImageTransformBlock)transform
             completion:(CSWebImageCompletionBlock)completion {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _setImageWithURL:imageURL
                forSingleState:num
                   placeholder:placeholder
                       options:options
                       manager:manager
                      progress:progress
                     transform:transform
                    completion:completion];
    }
}

- (void)cancelImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _cancelImageRequestForSingleState:num];
    }
}


#pragma mark - background image

- (void)_setBackgroundImageWithURL:(NSURL *)imageURL
                    forSingleState:(NSNumber *)state
                       placeholder:(UIImage *)placeholder
                           options:(CSWebImageOptions)options
                           manager:(CSWebImageManager *)manager
                          progress:(CSWebImageProgressBlock)progress
                         transform:(CSWebImageTransformBlock)transform
                        completion:(CSWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [CSWebImageManager sharedManager];
    
    _CSWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_CSWebImageBackgroundSetterKey);
    if (!dic) {
        dic = [_CSWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &_CSWebImageBackgroundSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    _CSWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    dispatch_async_on_main_queue(^{
        if (!imageURL) {
            if (!(options & CSWebImageOptionIgnorePlaceHolder)) {
                [self setBackgroundImage:placeholder forState:state.integerValue];
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
                [self setBackgroundImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, CSWebImageFromMemoryCacheFast, CSWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & CSWebImageOptionIgnorePlaceHolder)) {
            [self setBackgroundImage:placeholder forState:state.integerValue];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        [self setBackgroundImage:image forState:state.integerValue];
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

- (void)_cancelBackgroundImageRequestForSingleState:(NSNumber *)state {
    _CSWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_CSWebImageBackgroundSetterKey);
    _CSWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)backgroundImageURLForState:(UIControlState)state {
    _CSWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_CSWebImageBackgroundSetterKey);
    _CSWebImageSetter *setter = [dic setterForState:UIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)setBackgroundImageWithURL:(NSURL *)imageURL forState:(UIControlState)state placeholder:(UIImage *)placeholder {
    [self setBackgroundImageWithURL:imageURL
                           forState:state
                        placeholder:placeholder
                            options:kNilOptions
                            manager:nil
                           progress:nil
                          transform:nil
                         completion:nil];
}

- (void)setBackgroundImageWithURL:(NSURL *)imageURL forState:(UIControlState)state options:(CSWebImageOptions)options {
    [self setBackgroundImageWithURL:imageURL
                           forState:state
                        placeholder:nil
                            options:options
                            manager:nil
                           progress:nil
                          transform:nil
                         completion:nil];
}

- (void)setBackgroundImageWithURL:(NSURL *)imageURL
                         forState:(UIControlState)state
                      placeholder:(UIImage *)placeholder
                          options:(CSWebImageOptions)options
                       completion:(CSWebImageCompletionBlock)completion {
    [self setBackgroundImageWithURL:imageURL
                           forState:state
                        placeholder:placeholder
                            options:options
                            manager:nil
                           progress:nil
                          transform:nil
                         completion:completion];
}

- (void)setBackgroundImageWithURL:(NSURL *)imageURL
                         forState:(UIControlState)state
                      placeholder:(UIImage *)placeholder
                          options:(CSWebImageOptions)options
                         progress:(CSWebImageProgressBlock)progress
                        transform:(CSWebImageTransformBlock)transform
                       completion:(CSWebImageCompletionBlock)completion {
    [self setBackgroundImageWithURL:imageURL
                           forState:state
                        placeholder:placeholder
                            options:options
                            manager:nil
                           progress:progress
                          transform:transform
                         completion:completion];
}

- (void)setBackgroundImageWithURL:(NSURL *)imageURL
                         forState:(UIControlState)state
                      placeholder:(UIImage *)placeholder
                          options:(CSWebImageOptions)options
                          manager:(CSWebImageManager *)manager
                         progress:(CSWebImageProgressBlock)progress
                        transform:(CSWebImageTransformBlock)transform
                       completion:(CSWebImageCompletionBlock)completion {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _setBackgroundImageWithURL:imageURL
                          forSingleState:num
                             placeholder:placeholder
                                 options:options
                                 manager:manager
                                progress:progress
                               transform:transform
                              completion:completion];
    }
}

- (void)cancelBackgroundImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _cancelBackgroundImageRequestForSingleState:num];
    }
}

@end



