//
//  CCHttpRequestTools+OKExtension.m
//  okdeer-commonLibrary
//
//  Created by mao wangxin on 2016/12/22.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKHttpRequestTools+OKExtension.h"
#import "AFNetworking.h"
#import "OKRequestTipBgView.h"
#import "OKFMDBTool.h"
#import "OKRequestTipBgView.h"
#import "CSKit.h"
#import "NSObject+CSModel.h"

//重复请求次数key
static char const * const kRequestTimeCountKey    = "kRequestTimeCountKey";

@implementation OKHttpRequestTools (OKExtension)

#pragma mark - 包装每个接口缓存数据的key

/**
 *  根据接口参数包装缓存数据key
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

#pragma mark - 包装请求入口


#define Net_Response_Param_MSG                @"message"
#define Net_Response_Param_CODE               @"code"
#define Net_Response_Param_DATA               @"data"

+ (NSURLSessionDataTask *)sendExtensionRequest:(OKHttpRequestModel *)requestModel
                                     jsonClass:(Class)aJsonClass
                                       success:(OKHttpSuccessBlock)successBlock
                                       failure:(OKHttpFailureBlock)failureBlock{
    
    __block NSURLSessionDataTask *sessionDataTask = nil;
    
    //发送网络请求,二次封装入口
    sessionDataTask = [OKHttpRequestTools sendExtensionRequest:requestModel success:^(id returnValue) {
        
        if (returnValue) { // 请求数据判断
            CSNSLog(@"请求的数据:%@",returnValue);
        } else {
            CSNSLog(@" 请求数据为空");
            failureBlock([NSError errorWithDomain:@"数据解析失败!" code:110 userInfo:nil]);
        }
        NSDictionary *dic = nil;
        if ([returnValue isKindOfClass:[NSDictionary class]]) {
            dic = returnValue;
        }
        
        /// code == 1,但是数据为空
        BOOL isError = [[dic valueForKey:Net_Response_Param_CODE] integerValue] == 1;
        if (isError) { //判断返回的数据是否为错误信息
            id tempData = [dic valueForKey:Net_Response_Param_DATA];
            if (tempData == nil) {
                
                failureBlock([NSError errorWithDomain:[dic valueForKey:Net_Response_Param_MSG]
                                                 code:[[dic valueForKey:Net_Response_Param_CODE] integerValue]
                                             userInfo:nil]);
            }
        }
        
        id tempJson = dic[Net_Response_Param_DATA];
        
        ///如果不需要转模型
        if (!aJsonClass) {
            if ([tempJson isKindOfClass:[NSDictionary class]] ||
                [tempJson isKindOfClass:[NSArray class]] ) {
                
                successBlock(tempJson);
            }else{
                failureBlock([NSError errorWithDomain:@"数据类型有误!" code:119 userInfo:nil]);
            }
            
        }else{
            ///字典
            if ([tempJson isKindOfClass:[NSDictionary class]]) {
                id modelData = [aJsonClass modelWithDictionary:tempJson];
                successBlock(modelData);
            }
            ///数组
            else if ([tempJson isKindOfClass:[NSArray class]]) {
                id modelDataArr = [NSArray modelArrayWithClass:aJsonClass json:tempJson];
                successBlock(modelDataArr);
            }
        }
        
        
        
        
    } failure:^(NSError *error) {
        CSNSLog(@"请求错误:%@",error);
        if (failureBlock) {
            failureBlock(error);
        }
    }];
    return sessionDataTask;
}

/**
 http 发送请求入口
 
 @param requestModel 请求参数等信息
 @param successBlock 请求成功执行的block
 @param failureBlock 请求失败执行的block
 @return 返回当前请求的对象
 */
+ (NSURLSessionDataTask *)sendExtensionRequest:(OKHttpRequestModel *)requestModel
                                       success:(OKHttpSuccessBlock)successBlock
                                       failure:(OKHttpFailureBlock)failureBlock{
    
    
    
    
    
    //缓存key
    NSString *cachekey = [self getCacheKeyByRequestUrl:requestModel.requestUrl parameter:requestModel.parameters];
    //取出缓存的值,可能为空
    NSDictionary *cacheDic = [OKFMDBTool getObjectById:cachekey fromTable:JsonDataTableType];
    
    
    
    
    //失败回调
    void (^failResultBlock)(NSError *) = ^(NSError *error){
        CSNSLog(@"\n请求链接:%@\n失败回调:%@\n",requestModel.requestUrl,error);
        
        ///用户不存在就退出吧
        
        //隐藏弹框
        if (requestModel.loadView && !requestModel.dataTableView) {
            [MBProgressHUD hideLoadingFromView:requestModel.loadView];
        }
        
        if (failureBlock) {
            failureBlock(error);
        }
        
        //如果请求完成后需要判断页面表格下拉控件,分页,空白提示页的状态
        UIScrollView *tableView = requestModel.dataTableView;
        if (tableView && [tableView isKindOfClass:[UIScrollView class]]) {
            [tableView showRequestTip:error];
        }
        
        //如果需要提示错误信息
        if (!requestModel.forbidTipErrorInfo) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //错误码在420-500内才提示服务端错误信息
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                if (error.code > kRequestTipsStatuesMin && error.code < kRequestTipsStatuesMax) {
                    [MBProgressHUD showToastViewOnView:window text:error.domain];
                } else {
                    //[MBProgressHUD showToastViewOnView:window text:RequestFailCommomTip];
                }
            });
            
            
        }
    };
    
    
    
    
    
    //成功回调
    void(^succResultBlock)(id responseObject, BOOL isCacheData) = ^(id responseObject, BOOL isCacheData){
        CSNSLog(@"\n请求链接:%@\n请求参数:%@\n\n返回数据:%@\n\n\n ",requestModel.requestUrl,requestModel.parameters,responseObject);
        //判断是否为缓存数据
        requestModel.isCacheData = isCacheData;
        
        if (requestModel.loadView && !requestModel.dataTableView) { //防止页面上有其他弹框
            [MBProgressHUD hideLoadingFromView:requestModel.loadView];
        }
        
        //请求状态码为1表示成功，否则失败
        NSInteger code = [responseObject[kRequestCodeKey] integerValue];
        if (code == [kRequestSuccessStatues integerValue])
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
            if (isCacheData == NO && requestModel.requestCachePolicy == RequestStoreCacheData) {
                
                NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSData * data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
                
                if (data) { //保存数据到数据库
                    NSString *cachekey = [self getCacheKeyByRequestUrl:requestModel.requestUrl parameter:requestModel.parameters];//缓存key
                    BOOL isYES = [OKFMDBTool saveDataToDB:data byObjectId:cachekey toTable:JsonDataTableType];
                    if (isYES) {
                        CSNSLog(@"缓存成功:✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️\n接口地址:%@",requestModel.requestUrl)
                    }else{
                        CSNSLog(@"缓存失败:✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️\n接口地址:%@",requestModel.requestUrl)
                    }
                }
            }
            
        } else { //请求code不正确,走失败
            failResultBlock([NSError errorWithDomain:responseObject[kRequestMessageKey] code:code userInfo:nil]);
        }
    };
    
    
    
    
    
    
    
    
    
    
    //请求地址为空则不请求
    if (!requestModel.requestUrl) {
        if (failResultBlock) {
            failResultBlock([NSError errorWithDomain:RequestFailCommomTip code:[kServiceErrorStatues integerValue] userInfo:nil]);
        }
        return nil;
    };
    
    
    
    
    
    
    //网络不正常,但是有缓存就返回缓存,否则直接走返回失败
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        
        //如果有缓存
        if (cacheDic) {
            CSNSLog(@"缓存数据返回成功:✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️\n接口地址:%@",requestModel.requestUrl)
            succResultBlock(cacheDic,YES);
        } else{
            if (failureBlock) {
                failResultBlock([NSError errorWithDomain:NetworkConnectFailTip code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
            }
        }
        
        
        
        return nil;
    }
    
    
    //如果有网络缓存, 则立即返回缓存, 同时继续请求网络最新数据
    if (successBlock && requestModel.requestCachePolicy == RequestStoreCacheData) {
        
        //如果有缓存
        if (cacheDic) {
            CSNSLog(@"缓存数据返回成功:✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️\n接口地址:%@",requestModel.requestUrl)
            succResultBlock(cacheDic,YES);
        }
    }
    
    //是否显示请求转圈
    if (requestModel.loadView && !requestModel.dataTableView) {
        [requestModel.loadView endEditing:YES];
        [MBProgressHUD hideLoadingFromView:requestModel.loadView];
        [MBProgressHUD showLoadingWithView:requestModel.loadView text:RequestLoadingTip];
    }
    
    
    
    
    @weakify(self)
    //发送网络请求,二次封装入口
    __block NSURLSessionDataTask *sessionDataTask = nil;
    sessionDataTask = [OKHttpRequestTools sendOKRequest:requestModel success:^(id returnValue) {
        
        
        succResultBlock(returnValue, NO);
    } failure:^(NSError *error) {
        @strongify(self)
        ///MARK:特殊情况处理
        if (error) {
            
            switch (error.code) {
                case kErrorCode1:///用户信息不存在
                case kErrorCode2:///ACCESSTOKEN 不正确
                case kErrorCode3:///ACCESSTOKEN 失效
                {
                    [self showTost];
                }break;
                    
                    
                    
                    
                default:{
                    if (!requestModel.attemptRequestWhenFail) {
                        
                        //获取已请求次数
                        NSInteger countNum = [objc_getAssociatedObject(requestModel, kRequestTimeCountKey) integerValue];
                        if (countNum<3) {
                            countNum++;
                            CSNSLog(@"网络请求已失败，尝试第-----%zd-----次请求===%@\n\n",countNum,requestModel.requestUrl);
                            //给requestModel关联一个重复请求次数的key
                            objc_setAssociatedObject(requestModel, kRequestTimeCountKey, @(countNum), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                            //递归请求
                            sessionDataTask = [OKHttpRequestTools sendExtensionRequest:requestModel success:successBlock failure:failureBlock];
                            
                        } else {
                            failResultBlock(error);
                        }
                    } else {
                        failResultBlock(error);
                    }
                }break;
            }
        }
    }];
    return sessionDataTask;
}


+ (void)showTost{
    
    //通知页面需要重新登录
//    LCBlockAlert* ale = [[LCBlockAlert alloc] initWithTitle:@"温馨提醒" andMessage:@"当前登录已失效"];
//    [ale addButtonWithTitle:@"确定" handler:^(LCBlockAlert *alertView, LCBlockAlertItem *item) {
//        [CSNoteCenter postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
//    }];
//    [ale show];
}



@end


