//
//  CCHttpRequestTools.m
//  okdeer-commonLibrary
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKHttpRequestTools.h"
#import <objc/runtime.h>
#import "AFNetworking.h"

static NSMutableArray *globalReqManagerArr_;

static char const * const kRequestUrlKey    = "kRequestUrlKey";

@implementation OKHttpRequestTools

+ (void)load
{
    //开始监听网络
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

/**
 *  创建请全局求管理者
 */
+ (void)initialize
{
    //维护一个全局请求管理数组,可方便在推出登录,内存警告时清除所有请求
    globalReqManagerArr_ = [NSMutableArray array];
}

#pragma mark -取消全局所有请求

/**
 * 取消全局请求管理数组中所有请求操作
 */
+ (void)cancelGlobalAllReqMangerTask
{
    if (globalReqManagerArr_.count==0) return;
    
    for (NSURLSessionDataTask *sessionTask in globalReqManagerArr_) {
        //LCNSLog(@"取消全局请求管理数组中所有请求操作===%@",sessionTask);
        if ([sessionTask isKindOfClass:[NSURLSessionDataTask class]]) {
            [sessionTask cancel];
        }
    }
    //清除所有请求对象
    [globalReqManagerArr_ removeAllObjects];
}


/**
 *  创建请求管理者
 */
+ (AFHTTPSessionManager *)afManager
{
    AFHTTPSessionManager *mgr_ = [AFHTTPSessionManager manager];
    //    mgr_.responseSerializer = [AFJSONResponseSerializer serializer];
    //    mgr_.requestSerializer = [AFJSONRequestSerializer serializer];
    
    mgr_.responseSerializer = [AFJSONResponseSerializer serializer];
    mgr_.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    mgr_.requestSerializer.timeoutInterval = 60;//默认超时时间
    
    [mgr_.requestSerializer setValue:@"PHPSESSID=ug67r41ocpb26lpb8fvhdd3vv6" forHTTPHeaderField:@"Cookie"];
    [mgr_.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    //mgr_.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    mgr_.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                           @"text/html",
                                                                           @"text/json",
                                                                           @"text/plain",
                                                                           @"text/javascript",
                                                                           @"text/xml",
                                                                           @"image/*"]];
    return mgr_;
}

#pragma mark -======== 底层公共请求入口 ========

/**
 http 发送请求入口
 
 @param requestModel 请求参数等信息
 @param successBlock 请求成功执行的block
 @param failureBlock 请求失败执行的block
 @return 返回当前请求的对象
 */
+ (NSURLSessionDataTask *)sendOKRequest:(OKHttpRequestModel *)requestModel
                                success:(OKHttpSuccessBlock)successBlock
                                failure:(OKHttpFailureBlock)failureBlock
{
    //失败回调
    void (^failResultBlock)(NSError *) = ^(NSError *error){
        //LCNSLog(@"请求接口基地址= %@\n\n请求参数= %@\n\n网络数据失败返回= %@\n\n",requestModel.requestUrl,requestModel.parameters,error);
        
        if (error.code != NSURLErrorCancelled) {
            if (failureBlock) {
                failureBlock(error);
            }
        } else {
            //LCNSLog(@"页面已主动触发取消请求,此次请求不回调到页面");
        }
        
        //每个请求完成后,从队列中移除当前请求任务
        [self removeCompletedTaskSession:requestModel];
    };
    
    
    //请求地址为空则不请求
    if (!requestModel.requestUrl) {
        if (failResultBlock) {
            failResultBlock([NSError errorWithDomain:RequestFailCommomTip code:[kServiceErrorStatues integerValue] userInfo:nil]);
        }
        return nil;
    };
    
    //如果有相同url正在请求, 则取消此次请求
    if ([self isCurrentSessionDataTaskRunning:requestModel]) {
        if (failResultBlock) {
            //LCNSLog(@"消除相同请求~~~~~~~");
            //failResultBlock([NSError errorWithDomain:RequestFailCommomTip code:[kServiceErrorStatues integerValue] userInfo:nil]);
        }
        return nil;
    };
    
    //网络不正常,直接走返回失败
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        if (failureBlock) {
            failResultBlock([NSError errorWithDomain:NetworkConnectFailTip code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
        }
        return nil;
    }
    
    //成功回调
    void(^succResultBlock)(id responseObject) = ^(id responseObject){
        
        NSInteger code = [responseObject[kRequestCodeKey] integerValue];
        if (code == [kRequestSuccessStatues integerValue] ||
            code == 200){
            //LCNSLog(@"请求接口基地址= %@\n\n请求参数= %@\n\n网络数据成功返回= %@\n\n",requestModel.requestUrl,requestModel.parameters,responseObject);
            
            /** <1>.回调页面请求 */
            if (successBlock) {
                successBlock(responseObject);
            }
            
        } else { //请求code不正确,走失败
            failResultBlock([NSError errorWithDomain:responseObject[kRequestMessageKey] code:code userInfo:nil]);
        }
        
        //每个请求完成后,从队列中移除当前请求任务
        [self removeCompletedTaskSession:requestModel];
    };
    
    
    //设置请求超时时间
    AFHTTPSessionManager *mgr_ = [self afManager];
    mgr_.requestSerializer.timeoutInterval = requestModel.timeOut ? : 60;
    
    NSURLSessionDataTask *sessionDataTask = nil;
    
    //根据网络请求方式发请求
    if (requestModel.requestType == HttpRequestTypeGET) {
        
        //get请求
        sessionDataTask = [mgr_ GET:requestModel.requestUrl
                         parameters:requestModel.parameters
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                //LCNSLog(@"get请求请求绝对地址: %@\n\n",task.response.URL.absoluteString);
                                succResultBlock(responseObject);
                                
                            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                failResultBlock(error);
                            }];
        
    }
    else if(requestModel.requestType == HttpRequestTypePOST){
        
        //post请求
        sessionDataTask = [mgr_ POST:requestModel.requestUrl
                          parameters:requestModel.parameters
                            progress:nil
                             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                 //LCNSLog(@"post请求请求绝对地址: %@\n\n",task.response.URL.absoluteString);
                                 succResultBlock(responseObject);
                                 
                             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                 failResultBlock(error);
                             }];
        
    }
    else if(requestModel.requestType == HttpRequestTypeHEAD){
        
        //head请求
        sessionDataTask = [mgr_ HEAD:requestModel.requestUrl
                          parameters:requestModel.parameters
                             success:^(NSURLSessionDataTask * _Nonnull task) {
                                 //LCNSLog(@"head请求请求绝对地址: %@\n\n",task.response.URL.absoluteString);
                                 succResultBlock(task);
                                 
                             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                 failResultBlock(error);
                             }];
        
    }
    else if(requestModel.requestType == HttpRequestTypePUT){
        
        //put请求
        sessionDataTask = [mgr_ PUT:requestModel.requestUrl
                         parameters:requestModel.parameters
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                //LCNSLog(@"put请求请求绝对地址: %@\n\n",task.response.URL.absoluteString);
                                succResultBlock(responseObject);
                                
                            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                failResultBlock(error);
                            }];
    }
    
    //添加请求操作对象
    if (sessionDataTask) {
        //给sessionDataTask关联一个请求key
        objc_setAssociatedObject(sessionDataTask, kRequestUrlKey, requestModel.requestUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        if (requestModel.sessionDataTaskArr) {
            [requestModel.sessionDataTaskArr addObject:sessionDataTask];
        } else {
            [globalReqManagerArr_ addObject:sessionDataTask];
        }
    }
    
    return sessionDataTask;
}

#pragma mark - 相同请求逻辑判断

/**
 * 判断当前是否有相同的url正在请求
 */
+ (BOOL)isCurrentSessionDataTaskRunning:(OKHttpRequestModel *)requestModel
{
    NSString *requestUrl = requestModel.requestUrl;
    if (requestModel.sessionDataTaskArr) {
        //页面上传进来的请求数组
        return [self judgeCurrentRequesting:requestUrl judgeArr:requestModel.sessionDataTaskArr];
        
    } else {
        //全局请求数组
        return [self judgeCurrentRequesting:requestUrl judgeArr:globalReqManagerArr_];
    }
}

/**
 * 移除当前完成了的请求NSURLSessionDataTask
 */
+ (void)removeCompletedTaskSession:(OKHttpRequestModel *)requestModel
{
    NSString *requestUrl = requestModel.requestUrl;
    if (requestModel.sessionDataTaskArr) {
        //移除页面上传进来的管理数组
        [self removeTaskFromArr:requestModel.sessionDataTaskArr requestUrl:requestUrl];
        
    } else {
        //移除全局请求数组
        [self removeTaskFromArr:globalReqManagerArr_ requestUrl:requestUrl];
    }
}

#pragma mark - 处理操作请求数组

/**
 * 根据数组移除已完成的请求
 */
+ (void)removeTaskFromArr:(NSMutableArray *)reqArr requestUrl:(NSString *)requestUrl
{
    NSArray *allTaskArr = reqArr.copy;
    
    for (NSURLSessionDataTask *sessionDataTask in allTaskArr) {
        
        NSString *oldReqUrl = objc_getAssociatedObject(sessionDataTask, kRequestUrlKey);
        if ([oldReqUrl isEqualToString:requestUrl]) {
            
            if (sessionDataTask.state == NSURLSessionTaskStateCompleted) {
                [reqArr removeObject:sessionDataTask];
                //LCNSLog(@"移除管理数组中完成了的请求===%@",reqArr);
            }
        }
    }
}

/**
 * 根据数组判断是否有相同请求
 */
+ (BOOL)judgeCurrentRequesting:(NSString *)requestUrl judgeArr:(NSMutableArray *)reqArr
{
    for (NSURLSessionDataTask *sessionDataTask in reqArr) {
        
        NSString *oldReqUrl = objc_getAssociatedObject(sessionDataTask, kRequestUrlKey);
        if ([oldReqUrl isEqualToString:requestUrl]) {
            
            if (sessionDataTask.state != NSURLSessionTaskStateCompleted) {
                //LCNSLog(@"有相同url正在请求, 取消此次请求===%@",reqArr);
                return YES;
            }
        }
    }
    return NO;
}

@end

