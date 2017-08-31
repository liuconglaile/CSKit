//
//  _CSWebImageSetter.m
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "_CSWebImageSetter.h"
#import <libkern/OSAtomic.h>

#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSMacrosHeader.h>
#import <CSkit/CSWebImageOperation.h>
#else
#import "CSMacrosHeader.h"
#import "CSWebImageOperation.h"
#endif




NSString *const _CSWebImageFadeAnimationKey = @"CSWebImageFade";
const NSTimeInterval _CSWebImageFadeTime = 0.2;
const NSTimeInterval _CSWebImageProgressiveFadeTime = 0.4;

@implementation _CSWebImageSetter
{
    dispatch_semaphore_t _lock;
    NSURL *_imageURL;
    NSOperation *_operation;
    int32_t _sentinel;
}

- (instancetype)init {
    self = [super init];
    _lock = dispatch_semaphore_create(1);
    return self;
}

- (NSURL *)imageURL {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSURL *imageURL = _imageURL;
    dispatch_semaphore_signal(_lock);
    return imageURL;
}

- (void)dealloc {
    OSAtomicIncrement32(&_sentinel);
    [_operation cancel];
}

- (int32_t)setOperationWithSentinel:(int32_t)sentinel
                                url:(NSURL *)imageURL
                            options:(CSWebImageOptions)options
                            manager:(CSWebImageManager *)manager
                           progress:(CSWebImageProgressBlock)progress
                          transform:(CSWebImageTransformBlock)transform
                         completion:(CSWebImageCompletionBlock)completion {
    if (sentinel != _sentinel) {
        if (completion) completion(nil, imageURL, CSWebImageFromNone, CSWebImageStageCancelled, nil);
        return _sentinel;
    }
    
    NSOperation *operation = [manager requestImageWithURL:imageURL options:options progress:progress transform:transform completion:completion];
    if (!operation && completion) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"CSWebImageOperation create failed." };
        
        
        completion(nil, imageURL, CSWebImageFromNone, CSWebImageStageFinished, [NSError errorWithDomain:CSIdentitfier@"com.ibireme.CSKit.webimage" code:-1 userInfo:userInfo]);
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (sentinel == _sentinel) {
        if (_operation) [_operation cancel];
        _operation = operation;
        sentinel = OSAtomicIncrement32(&_sentinel);
    } else {
        [operation cancel];
    }
    dispatch_semaphore_signal(_lock);
    return sentinel;
}

- (int32_t)cancel {
    return [self cancelWithNewURL:nil];
}

- (int32_t)cancelWithNewURL:(NSURL *)imageURL {
    int32_t sentinel;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (_operation) {
        [_operation cancel];
        _operation = nil;
    }
    _imageURL = imageURL;
    sentinel = OSAtomicIncrement32(&_sentinel);
    dispatch_semaphore_signal(_lock);
    return sentinel;
}

+ (dispatch_queue_t)setterQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.ibireme.CSKit.webimage.setter", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    });
    return queue;
}


@end






