//
//  CSWebImageManager.m
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSWebImageManager.h"
#import "CSImageCache.h"
#import "CSImageDecoder.h"
#import "CSWebImageOperation.h"

@implementation CSWebImageManager

+ (instancetype)sharedManager {
    static CSWebImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CSImageCache *cache = [CSImageCache sharedCache];
        NSOperationQueue *queue = [NSOperationQueue new];
        if ([queue respondsToSelector:@selector(setQualityOfService:)]) {
            queue.qualityOfService = NSQualityOfServiceBackground;
        }
        manager = [[self alloc] initWithCache:cache queue:queue];
    });
    return manager;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"CSWebImageManager init error" reason:@"Use the designated initializer to init." userInfo:nil];
    return [self initWithCache:nil queue:nil];
}

- (instancetype)initWithCache:(CSImageCache *)cache queue:(NSOperationQueue *)queue{
    self = [super init];
    if (!self) return nil;
    _cache = cache;
    _queue = queue;
    _timeout = 15.0;
    if (CSImageWebPAvailable()) {
        _headers = @{ @"Accept" : @"image/webp,image/*;q=0.8" };
    } else {
        _headers = @{ @"Accept" : @"image/*;q=0.8" };
    }
    return self;
}

- (CSWebImageOperation *)requestImageWithURL:(NSURL *)url
                                     options:(CSWebImageOptions)options
                                    progress:(CSWebImageProgressBlock)progress
                                   transform:(CSWebImageTransformBlock)transform
                                  completion:(CSWebImageCompletionBlock)completion {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = _timeout;
    request.HTTPShouldHandleCookies = (options & CSWebImageOptionHandleCookies) != 0;
    request.allHTTPHeaderFields = [self headersForURL:url];
    request.HTTPShouldUsePipelining = YES;
    request.cachePolicy = (options & CSWebImageOptionUseNSURLCache) ?
    NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData;
    
    CSWebImageOperation *operation = [[CSWebImageOperation alloc] initWithRequest:request
                                                                          options:options
                                                                            cache:_cache
                                                                         cacheKey:[self cacheKeyForURL:url]
                                                                         progress:progress
                                                                        transform:transform ? transform : _sharedTransformBlock
                                                                       completion:completion];
    
    if (_username && _password) {
        operation.credential = [NSURLCredential credentialWithUser:_username password:_password persistence:NSURLCredentialPersistenceForSession];
    }
    if (operation) {
        NSOperationQueue *queue = _queue;
        if (queue) {
            [queue addOperation:operation];
        } else {
            [operation start];
        }
    }
    return operation;
}

- (NSDictionary *)headersForURL:(NSURL *)url {
    if (!url) return nil;
    return _headersFilter ? _headersFilter(url, _headers) : _headers;
}

- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!url) return nil;
    return _cacheKeyFilter ? _cacheKeyFilter(url) : url.absoluteString;
}

@end
