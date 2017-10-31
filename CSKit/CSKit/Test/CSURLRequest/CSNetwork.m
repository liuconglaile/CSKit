//
//  CSNetwork.m
//  CSKit
//
//  Created by mac on 2017/10/19.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSNetwork.h"
#import "NSURLSession+Extended.h"
#import <UIKit/UIKit.h>


@interface CSNetwork()<NSURLSessionDelegate>

@property (nonatomic, strong) NSProgress *uploadProgress;
@property (nonatomic, strong) NSProgress *downloadProgress;

@end

@implementation CSNetwork


static dispatch_queue_t cs_request_manager_queue() {
    static dispatch_queue_t cs_session_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cs_session_queue = dispatch_queue_create("com.volientduan.csrequest.manager.queue", DISPATCH_QUEUE_SERIAL);
    });
    return cs_session_queue;
}

static void cs_request_manager_queue_block(dispatch_block_t block){
    dispatch_sync(cs_request_manager_queue(), block);
}




+ (CSNetwork *)defaultManager{
    
    static CSNetwork *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CSNetwork alloc]init];
    });
    return manager;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.uploadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self.uploadProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
        
        self.downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self.downloadProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
        
    }
    return self;
}

- (CSURLRequest *)request{
    if (!_request) {
        _request = [[CSURLRequest alloc]init];
    }
    return _request;
}

- (CSResponse *)response{
    
    if (!_response) {
        _response = [[CSResponse alloc]init];
    }
    return _response;
}


- (void)addProgressForTask:(NSURLSessionTask *)task{
    __weak __typeof__(task) weakTask = task;
    
    self.uploadProgress.totalUnitCount = task.countOfBytesExpectedToSend;
    self.downloadProgress.totalUnitCount = task.countOfBytesExpectedToReceive;
    [self.uploadProgress setCancellable:YES];
    
    [self.uploadProgress setCancellationHandler:^{
        __typeof__(weakTask) strongTask = weakTask;
        [strongTask cancel];
    }];
    
    
    
    [self.uploadProgress setPausable:YES];
    [self.uploadProgress setPausingHandler:^{
        __typeof__(weakTask) strongTask = weakTask;
        [strongTask suspend];
    }];
    
    
    if ([self.uploadProgress respondsToSelector:@selector(setResumingHandler:)]) {
        [self.uploadProgress setResumingHandler:^{
            __typeof__(weakTask) strongTask = weakTask;
            [strongTask resume];
        }];
    }
    
    [self.downloadProgress setCancellable:YES];
    [self.downloadProgress setCancellationHandler:^{
        __typeof__(weakTask) strongTask = weakTask;
        [strongTask cancel];
    }];
    
    
    [self.downloadProgress setPausable:YES];
    [self.downloadProgress setPausingHandler:^{
        __typeof__(weakTask) strongTask = weakTask;
        [strongTask suspend];
    }];
    
    
    if ([self.downloadProgress respondsToSelector:@selector(setResumingHandler:)]) {
        [self.downloadProgress setResumingHandler:^{
            __typeof__(weakTask) strongTask = weakTask;
            [strongTask resume];
        }];
    }
    
    
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))
              options:NSKeyValueObservingOptionNew
              context:NULL];
    
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToSend))
              options:NSKeyValueObservingOptionNew
              context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
}



///===========================================================
///MARK: 请求方法
///===========================================================

- (void)sendRequest:(CSURLRequest *)request block:(CSResponseBlock)block{
    if (!request.URL) {
        return;
    }
    __block NSURLSessionTask *dataTask = nil;
    cs_request_manager_queue_block(^{
        dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            BOOL isSuccess = NO;
            if (((NSHTTPURLResponse *)response).statusCode == 200) {
                isSuccess = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                block(self.response.responseHandle(data),isSuccess,error.code);
            });
            
        }];
    });
    [dataTask resume];
}
- (void)sendRequestWithApi:(NSString *)api method:(NSString *)method type:(CSRequestType)type Parameter:(id)aParameter responseBlock:(CSResponseBlock)responseBlock{
    [self sendRequest:self.request.set(method,type,api,aParameter) block:^(id response, BOOL isSuccess, NSInteger errorCode) {
        if (responseBlock) {
            responseBlock(response,isSuccess,errorCode);
        }
    }];
}

- (void)POST:(NSString *)api Parameter:(id)aParameter responseBlock:(CSResponseBlock)responseBlock{
    [self sendRequestWithApi:api method:@"POST" type:self.request.requestType Parameter:aParameter responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
        if (responseBlock) {
            responseBlock(response,isSuccess,errorCode);
        }
    }];
}
- (void)GET:(NSString *)api Parameter:(id)aParameter responseBlock:(CSResponseBlock)responseBlock{
    [self sendRequestWithApi:api method:@"GET" type:self.request.requestType Parameter:aParameter responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
        if (responseBlock) {
            responseBlock(response,isSuccess,errorCode);
        }
    }];
}

- (void)formDataUploadWithApi:(NSString *)api Parameter:(id)aParameter files:(NSDictionary *)files responseBlock:(CSResponseBlock)responseBlock{
    
    [self sendRequestWithApi:api method:@"POST" type:CSRequestTypeData Parameter:[self combineParams:aParameter files:files] responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
        responseBlock(response, isSuccess, errorCode);
    }];
}



///===========================================================
///MARK: 链式语法
///===========================================================

- (void(^)(NSString *, id, CSResponseBlock))POST{
    return ^(NSString *api, id aParameter ,CSResponseBlock block){
        [self POST:api Parameter:aParameter responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
            block(response,isSuccess,errorCode);
        }];
    };
}
- (void(^)(NSString *, id, CSResponseBlock))GET{
    return ^(NSString *api, id aParameter ,CSResponseBlock block){
        [self GET:api Parameter:aParameter responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
            block(response,isSuccess,errorCode);
        }];
    };
}
- (void (^)(NSString *, NSString *, CSRequestType, id, CSResponseBlock))sendRequest{
    return ^(NSString *api ,NSString *method , CSRequestType type,id aParameter ,CSResponseBlock block){
        [self sendRequestWithApi:api method:method type:type Parameter:aParameter responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
            block(response,isSuccess,errorCode);
        }];
    };
}
- (void (^)(NSString *, id, NSDictionary *, CSResponseBlock))uploadFiles{
    return ^(NSString *api ,id aParameter , NSDictionary *files,CSResponseBlock block){
        [self formDataUploadWithApi:api Parameter:aParameter files:files responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
            block(response,isSuccess,errorCode);
        }];
    };
}



///===========================================================
///MARK: 处理器
///===========================================================

- (NSDictionary *)combineParams:(NSDictionary *)params files:(NSDictionary *)files{
    NSMutableDictionary *result = [[NSMutableDictionary alloc]initWithDictionary:params];
    if (files) {
        NSArray *keys = files.allKeys;
        for (NSString *key in keys) {
            id file = files[key];
            if (files&&[file isKindOfClass:[NSData class]]&&[file isKindOfClass:[UIImage class]]) {
                [result setObject:file forKey:key];
            }
        }
    }
    return result;
}


///===========================================================
///MARK: 代理
///===========================================================
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    
}
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    
}


@end

