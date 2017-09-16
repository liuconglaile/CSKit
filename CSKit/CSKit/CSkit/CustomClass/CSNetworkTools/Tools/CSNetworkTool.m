//
//  CSNetworkTool.m
//  CSKit
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSNetworkTool.h"
#import <objc/runtime.h>
#import "AFNetworking.h"
#import "CSKitHeader.h"

static NSMutableArray *globalReqManagerArr_;
static char const * const kRequestUrlKey    = "kRequestUrlKey";


// 项目打包上线都不会打印日志，因此可放心。
#ifdef DEBUG
#define CSAppLog(FORMAT, ...) fprintf(stderr,"\n\n\n🍎🍎🍎方法:%s \n🍊🍊🍊行号:%d \n🍌🍌🍌内容:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else // 开发模式
#define CSAppLog(FORMAT, ...) nil
#endif



@interface CSHTTPSessionManagerX : NSObject

+ (AFHTTPSessionManager *)sharedManager;

@end


@implementation CSHTTPSessionManagerX

static AFHTTPSessionManager *manager;

+ (AFHTTPSessionManager *)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 初始化请求管理类
        manager = [AFHTTPSessionManager manager];
        //请求串行器
        //manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        //响应串行器
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        // 设置15秒超时 - 取消请求
        manager.requestSerializer.timeoutInterval = 60;
        // 编码
        //manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        // 缓存策略(这里先不设置)
        //manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        
        // 支持内容格式
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                             @"text/json",
                                                             @"application/json",
                                                             @"text/plain",
                                                             @"text/JavaScript",
                                                             @"text/html",
                                                             @"image/*",
                                                             nil];
        
        [manager.requestSerializer setValue:@"PHPSESSID=ug67r41ocpb26lpb8fvhdd3vv6" forHTTPHeaderField:@"Cookie"];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
    });
    return manager;
    
}

@end



@implementation CSNetworkTool

+ (void)load{
    //开始监听网络
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

/**
 创建请全局求管理者
 */
+ (void)initialize{
    //维护一个全局请求管理数组,可方便在推出登录,内存警告时清除所有请求
    globalReqManagerArr_ = [NSMutableArray array];
}

#pragma mark -取消全局所有请求

/**
 取消全局请求管理数组中所有请求操作
 */
+ (void)cancelGlobalAllReqMangerTask{
    if (globalReqManagerArr_.count==0) return;
    
    for (NSURLSessionDataTask *sessionTask in globalReqManagerArr_) {
        CSAppLog(@"取消全局请求管理数组中所有请求操作===%@",sessionTask);
        if ([sessionTask isKindOfClass:[NSURLSessionDataTask class]]) {
            [sessionTask cancel];
        }
    }
    //清除所有请求对象
    [globalReqManagerArr_ removeAllObjects];
}


/**
 创建请求管理者
 */
+ (AFHTTPSessionManager *)afManager{
    
    return [CSHTTPSessionManagerX sharedManager];
}

#pragma mark -======== 底层公共请求入口 ========

+ (NSURLSessionDataTask *)sendRequest:(CSNetworkModel *)requestModel
                             Progress:(CSProgress)aProgress
                              Success:(CSSuccess)aSuccess
                              Failure:(CSFailure)aFailure{
    
    
    
    
    
    ///获取请求管理器.一并处理断网&重复&地址空等情况
    AFHTTPSessionManager *manager = [self getManagerWithWithModel:requestModel progress:^(NSProgress *downloadProgress) {
        if (aProgress) {
            aProgress(downloadProgress);
        }
    } success:^(id responseObject) {
        if (aSuccess) {
            aSuccess(responseObject);
        }
    } failure:^(NSError *error) {
        if (aFailure) {
            aFailure(error);
        }
    }];
    
    
    manager.requestSerializer.timeoutInterval = requestModel.timeOut ? : 60;
    NSURLSessionDataTask *sessionDataTask = nil;
    CSNetworkMethod method = requestModel.requestType;
    
    
    
    
    //失败回调
    CSFailure failResultBlock = ^(NSError *error){
        
        [self logWithString1:requestModel.requestUrl String2:requestModel.parameters String3:error];
        if (aFailure) {
            aFailure(error);
        }
        
        //每个请求完成后,从队列中移除当前请求任务
        [self removeCompletedTaskSession:requestModel];
    };
    
    //成功回调
    CSSuccess successResultBlock = ^(id responseObject){
        
        NSInteger code = [responseObject[kNetworkCodeKey] integerValue];
        if (code == [kNetworkSuccessStatus integerValue] ||
            code == 200) {
            [self logWithString1:requestModel.requestUrl String2:requestModel.parameters String3:responseObject];
            /** <1>.回调页面请求 */
            if (aSuccess) {
                aSuccess(responseObject);
            }
            
        } else { //请求code不正确,走失败
            NSString* msg = responseObject[kNetworkMessageKey];
            [self logWithString1:@"请求CODE不正确:" String2:responseObject String3:@""];
            failResultBlock([NSError errorWithDomain:msg? msg : @"msg值为nil" code:code userInfo:nil]);
        }
        
        //每个请求完成后,从队列中移除当前请求任务
        [self removeCompletedTaskSession:requestModel];
    };
    
    
    
    
    
    
    /// 根据网络请求方式发请求
    switch (method) {
        case CSNetworkMethodGET:{///GET请求
            sessionDataTask = [manager GET:requestModel.requestUrl parameters:requestModel.parameters
                                  progress:^(NSProgress * _Nonnull downloadProgress) {
                                      
                                  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      [self logWithString1:@"POST请求请求绝对地址:" String2:task.response.URL.absoluteString String3:@""];
                                      successResultBlock(responseObject);
                                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                      failResultBlock(error);
                                  }];
        }break;
        case CSNetworkMethodPOST:{///POST请求
            sessionDataTask = [manager POST:requestModel.requestUrl
                                 parameters:requestModel.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                     
                                 } progress:^(NSProgress * _Nonnull uploadProgress) {
                                     
                                 } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                     [self logWithString1:@"POST请求绝对地址:" String2:task.response.URL.absoluteString String3:@""];
                                     successResultBlock(responseObject);
                                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                     failResultBlock(error);
                                 }];
        }break;
        case CSNetworkMethodHEAD:{ //HEAD请求
            sessionDataTask = [manager HEAD:requestModel.requestUrl parameters:requestModel.parameters
                                    success:^(NSURLSessionDataTask * _Nonnull task) {
                                        [self logWithString1:@"HEAD请求绝对地址:" String2:task.response.URL.absoluteString String3:@""];
                                        successResultBlock(task);
                                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                        failResultBlock(error);
                                    }];
        }break;
        case CSNetworkMethodPUT:{ //PUT请求
            sessionDataTask = [manager PUT:requestModel.requestUrl parameters:requestModel.parameters
                                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                       [self logWithString1:@"PUT请求绝对地址:" String2:task.response.URL.absoluteString String3:@""];
                                       successResultBlock(responseObject);
                                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                       failResultBlock(error);
                                   }];
        }break;
    }
    
    
    ///添加请求操作对象
    if (sessionDataTask) {
        ///给sessionDataTask关联一个请求key
        objc_setAssociatedObject(sessionDataTask, kRequestUrlKey, requestModel.requestUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        if (requestModel.sessionDataTaskArr) {
            [requestModel.sessionDataTaskArr addObject:sessionDataTask];
        } else {
            [globalReqManagerArr_ addObject:sessionDataTask];
        }
    }
    
    return sessionDataTask;
    
    
}

///MARK: 统一打印调试数据
+ (void)logWithString1:(id)aString1 String2:(id)aString2 String3:(id)aString3 {
    CSAppLog(@"\n%@\n%@\n%@\n",aString1,aString2,aString3);
}


























///MARK: ===================================================
///MARK: 请求操作处理
///MARK: ===================================================
+ (AFHTTPSessionManager *)getManagerWithWithModel:(CSNetworkModel *)requestModel
                                         progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          success:(void (^)(id responseObject))successBlock
                                          failure:(void (^)(NSError   *error))failureBlock {
    
    /// 1.当前的请求是否正在进行
    for (NSURLSessionDataTask *sessionDataTask in requestModel.sessionDataTaskArr) {
        
        NSString *oldReqUrl = objc_getAssociatedObject(sessionDataTask, kRequestUrlKey);
        if ([oldReqUrl isEqualToString:requestModel.requestUrl]) {
            
            if (sessionDataTask.state != NSURLSessionTaskStateCompleted) {
                NSString* logString = [NSString stringWithFormat:@"请求正在进行! 当前请求链接:%@",requestModel.requestUrl];
                if (failureBlock) {
                    NSError *cancelError = [NSError errorWithDomain:logString code:(-12001) userInfo:nil];
                    failureBlock(cancelError);
                }
                return nil;
            }
        }
    }
    
    /// 2.检测是否有网络
    AFNetworkReachabilityStatus net = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if ( net == AFNetworkReachabilityStatusNotReachable) {
        NSError *cancelError = [NSError errorWithDomain:@"没有网络,请检测网络!" code:(-12002) userInfo:nil];
        if (failureBlock) {
            failureBlock(cancelError);
        }
        return nil;
    }
    
    
    
    /// 3.请求地址为空则不请求
    if (!requestModel.requestUrl) {
        if (failureBlock) {
            failureBlock([NSError errorWithDomain:kNetworkFailCommomTip code:[kNetworkErrorStatues integerValue] userInfo:nil]);
        }
        return nil;
    };
    
    return  [self afManager];
}



#pragma mark - 处理操作请求数组
/** 移除当前完成了的请求NSURLSessionDataTask */
+ (void)removeCompletedTaskSession:(CSNetworkModel *)requestModel {
    NSString *requestUrl = requestModel.requestUrl;
    if (requestModel.sessionDataTaskArr) {
        //移除页面上传进来的管理数组
        [self removeTaskFromArr:requestModel.sessionDataTaskArr requestUrl:requestUrl];
        
    } else {
        //移除全局请求数组
        [self removeTaskFromArr:globalReqManagerArr_ requestUrl:requestUrl];
    }
}
/** 根据数组移除已完成的请求 */
+ (void)removeTaskFromArr:(NSMutableArray *)reqArr requestUrl:(NSString *)requestUrl {
    NSArray *allTaskArr = reqArr.copy;
    
    for (NSURLSessionDataTask *sessionDataTask in allTaskArr) {
        
        NSString *oldReqUrl = objc_getAssociatedObject(sessionDataTask, kRequestUrlKey);
        if ([oldReqUrl isEqualToString:requestUrl]) {
            
            if (sessionDataTask.state == NSURLSessionTaskStateCompleted) {
                [reqArr removeObject:sessionDataTask];
                CSAppLog(@"移除管理数组中完成了的请求===%@",reqArr);
            }else{
                CSAppLog(@"请求状态:%@",@(sessionDataTask.state));
            }
        }
    }
}






///MARK: GET请求url 拼接参数方法(仅供调试打印用,实际开发不需要使用)
+ (NSString *)generateGETAbsoluteURL:(NSString *)url params:(id)params {
    /**
     GET请求url 拼接参数
     仅对一级字典结构起作用
     
     @param url 请求链接
     @param params 参数
     @return 拼接后的请求地址
     */
    
    if (params == nil || ![params isKindOfClass:[NSDictionary class]] || [params count] == 0) {
        return url;
    }
    
    NSString *queries = @"";
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            continue;
        } else if ([value isKindOfClass:[NSArray class]]) {
            continue;
        } else if ([value isKindOfClass:[NSSet class]]) {
            continue;
        } else {
            queries = [NSString stringWithFormat:@"%@%@=%@&",
                       (queries.length == 0 ? @"&" : queries),
                       key,
                       value];
        }
    }
    
    if (queries.length > 1) {
        queries = [queries substringToIndex:queries.length - 1];
    }
    
    if (([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) && queries.length > 1) {
        if ([url rangeOfString:@"?"].location != NSNotFound
            || [url rangeOfString:@"#"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@%@", url, queries];
        } else {
            queries = [queries substringFromIndex:1];
            url = [NSString stringWithFormat:@"%@?%@", url, queries];
        }
    }
    
    return url.length == 0 ? queries : url;
}



@end










