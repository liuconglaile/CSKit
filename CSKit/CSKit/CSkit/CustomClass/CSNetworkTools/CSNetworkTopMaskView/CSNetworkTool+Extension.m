//
//  CSNetworkTool+Extension.m
//  CSKit
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSNetworkTool+Extension.h"
#import "AFNetworkReachabilityManager.h"
#import "CSNetworkTopMaskView.h"
#import "NSObject+CSModel.h"
#import "CSCache.h"
#import "NSString+Extended.h"

#import "CSKit.h"

//重复请求次数key
static char const * const kRequestTimeCountKey    = "kRequestTimeCountKey";

@implementation CSNetworkTool (Extension)


///MARK: ===================================================
///MARK: 包装每个接口缓存数据的key
///MARK: ===================================================
/**
 根据接口参数包装缓存数据key
 */
+(NSString *)getCacheKeyByRequestUrl:(NSString *)urlString parameter:(NSDictionary *)parameter
{
    NSString * key = @"";
    if (urlString && [urlString isKindOfClass:[NSString class]]) {
        key = urlString;
    }
    if (parameter && [parameter isKindOfClass:[NSDictionary class]]) {
        NSArray * dickeys = [parameter allKeys];
        for (NSString * dickey in dickeys) {
            NSString * valus = [parameter objectForKey:dickey];
            key = [NSString stringWithFormat:@"%@%@%@",key,dickey,valus];
        }
    }
    return key;//[CNUtils md5:key];
}





+ (NSURLSessionDataTask *)sendExtensionRequest:(CSNetworkModel *)requestModel
                                     jsonClass:(Class)aJsonClass
                                       success:(CSLoadSuccessBlock)successBlock
                                       failure:(CSLoadFailureBlock)failureBlock{
    
    return [CSNetworkTool sendOKRequest:requestModel success:^(id returnValue) {
        
        if (returnValue) { // 请求数据判断
            CSNSLog(@"请求的数据：%@",returnValue);
        } else {
            CSNSLog(@" 请求数据为空");
            failureBlock([NSError errorWithDomain:@"数据解析失败!" code:110 userInfo:nil]);
        }
        NSDictionary *dic = nil;
        if ([returnValue isKindOfClass:[NSDictionary class]]) {
            dic = returnValue;
        }
        BOOL isError = [[dic valueForKey:kNetworkCodeKey] integerValue] == 1;
        if (isError) { //判断返回的数据是否为错误信息
            
            failureBlock([NSError errorWithDomain:[dic valueForKey:kNetworkMessageKey]
                                             code:[[dic valueForKey:kNetworkCodeKey] integerValue]
                                         userInfo:nil]);
            
        }
        
        id tempJson = dic[kNetworkDataKey];
        ///如果不需要转模型
        if ([aJsonClass isSubclassOfClass:[NSDictionary class]] ||
            !aJsonClass) {
            successBlock(tempJson);
        }
        ///字典
        if ([tempJson isKindOfClass:[NSDictionary class]]) {
            id modelData = [aJsonClass modelWithDictionary:tempJson];
            successBlock(modelData);
        }
        ///数组
        if ([tempJson isKindOfClass:[NSArray class]]) {
            id modelDataArr = [NSArray modelArrayWithClass:aJsonClass json:tempJson];
            successBlock(modelDataArr);
        }
        
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

/**
 http 发送请求入口
 
 @param requestModel 请求参数等信息
 @param successBlock 请求成功执行的block
 @param failureBlock 请求失败执行的block
 @return 返回当前请求的对象
 */
+ (NSURLSessionDataTask *)sendExtensionRequest:(CSNetworkModel *)requestModel
                                       success:(CSLoadSuccessBlock)successBlock
                                       failure:(CSLoadFailureBlock)failureBlock
{
    //失败回调
    void (^failResultBlock)(NSError *) = ^(NSError *error){
        
        //隐藏弹框
        if (requestModel.loadView && !requestModel.dataTableView) {
            [CSProgressHUD hideLoadingFromView:requestModel.loadView];
        }
        
        if (failureBlock) {
            failureBlock(error);
        }
        
        //判断Token状态是否为失效
        if (error.code == [kNetworkLoginFailStatus integerValue]) {
            //通知页面需要重新登录
            [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkTokenExpiryNotificationKey object:nil];
        }
        
        //如果请求完成后需要判断页面表格下拉控件,分页,空白提示页的状态
        UIScrollView *tableView = requestModel.dataTableView;
        if (tableView && [tableView isKindOfClass:[UIScrollView class]]) {
            [tableView showRequestTip:error];
        }
        
        //如果需要提示错误信息
        if (!requestModel.forbidTipErrorInfo) {
            
            //错误码在200-500内才提示服务端错误信息
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            if (error.code > kNetworkStatuesMin && error.code < kNetworkStatuesMax) {
                [CSProgressHUD showToastViewOnView:window text:error.domain];
                
            } else {
                [CSProgressHUD showToastViewOnView:window text:kNetworkFailCommomTip];
            }
        }
    };
    
    //请求地址为空则不请求
    if (!requestModel.requestUrl) {
        if (failResultBlock) {
            failResultBlock([NSError errorWithDomain:kNetworkFailCommomTip code:[kNetworkErrorStatues integerValue] userInfo:nil]);
        }
        return nil;
    };
    
    //网络不正常,直接走返回失败
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        
        
        
        if (failureBlock) {
            failResultBlock([NSError errorWithDomain:kNetworkConnectFailTip code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
        }
        return nil;
    }
    
    //成功回调
    void(^succResultBlock)(id responseObject, BOOL isCacheData) = ^(id responseObject, BOOL isCacheData){
        
        //判断是否为缓存数据
        requestModel.isCacheData = isCacheData;
        
        if (requestModel.loadView && !requestModel.dataTableView) { //防止页面上有其他弹框
            [CSProgressHUD hideLoadingFromView:requestModel.loadView];
        }
        
        //请求状态码为0表示成功，否则失败
        NSInteger code = [responseObject[kNetworkCodeKey] integerValue];
        if (code == [kNetworkSuccessStatus integerValue])
        {
            /** <1>.回调页面请求 */
            if (successBlock) {
                successBlock(responseObject);
            }
            
            /** <2>.如果请求完成后需要判断页面表格下拉控件,分页,空白提示页的状态 */
            UIScrollView *tableView = requestModel.dataTableView;
            if (tableView && [tableView isKindOfClass:[UIScrollView class]]) {
                [tableView showRequestTip:responseObject];
            }
            
            /** <3>.是否需要缓存 */
            if (isCacheData == NO && requestModel.requestCachePolicy == CSNetworkStoreCachePolicy) {
                
                
                
//                NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
//                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                NSData * data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
                
//                NSDictionary* data = @{};
//                if ([responseObject isKindOfClass:[NSString class]]) {
//                    NSString* dataString = (NSString*)responseObject;
//                    data = [dataString dictionaryValue];
//                }else{
//                
//                }
                
                if (responseObject) { //保存数据到数据库
                    NSString *cachekey = [self getCacheKeyByRequestUrl:requestModel.requestUrl parameter:requestModel.parameters];//缓存key
                    
                    CSCache* cache = [CSCache cacheWithName:@"CSNetworkTool"];
                    [cache setObject:responseObject forKey:cachekey withBlock:^{
                        CSNSLog(@"缓存文件成功~~~~:%@",cachekey);
                    }];
                    
                    //[OKFMDBTool saveDataToDB:data byObjectId:cachekey toTable:JsonDataTableType];
                }
            }
            
        } else { //请求code不正确,走失败
            failResultBlock([NSError errorWithDomain:responseObject[kNetworkMessageKey] code:code userInfo:nil]);
        }
    };
    
    //如果有网络缓存, 则立即返回缓存, 同时继续请求网络最新数据
    if (successBlock && requestModel.requestCachePolicy == CSNetworkStoreCachePolicy) {
        //缓存key
        NSString *cachekey = [self getCacheKeyByRequestUrl:requestModel.requestUrl parameter:requestModel.parameters];
        CSCache* cache = [CSCache cacheWithName:@"CSNetworkTool"];
        [cache objectForKey:cachekey withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
            CSNSLog(@"请求接口基地址= %@\n\n请求参数= %@\n\n缓存数据成功返回= %@",requestModel.requestUrl,requestModel.parameters,object);
            succResultBlock(object,YES);
        }];
    }
    
    //是否显示请求转圈
    if (requestModel.loadView && !requestModel.dataTableView) {
        [requestModel.loadView endEditing:YES];
        [CSProgressHUD hideLoadingFromView:requestModel.loadView];
        [CSProgressHUD showLoadingWithView:requestModel.loadView text:kNetworkLoginFailStatus];
    }
    
    __block NSURLSessionDataTask *sessionDataTask = nil;
    
    //发送网络请求,二次封装入口
    sessionDataTask = [CSNetworkTool sendOKRequest:requestModel success:^(id returnValue) {
        succResultBlock(returnValue, NO);
        
    } failure:^(NSError *error) {
        
        if (!requestModel.attemptRequestWhenFail) {
            
            NSInteger countNum = [objc_getAssociatedObject(requestModel, kRequestTimeCountKey) integerValue];
            if (countNum<3) {
                countNum++;
                CSNSLog(@"网络请求已失败，尝试第-----%zd-----次请求===%@\n\n",countNum,requestModel.requestUrl);
                
                //给requestModel关联一个重复请求次数的key
                objc_setAssociatedObject(requestModel, kRequestTimeCountKey, @(countNum), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                sessionDataTask = [CSNetworkTool sendExtensionRequest:requestModel success:successBlock failure:failureBlock];
                
            } else {
                failResultBlock(error);
            }
            
        } else {
            failResultBlock(error);
        }
    }];
    return sessionDataTask;
}




@end









