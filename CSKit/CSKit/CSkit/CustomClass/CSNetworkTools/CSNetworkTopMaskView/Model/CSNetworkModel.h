//
//  CSNetworkModel.h
//  CSKit
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 网络连接失败提示 */
FOUNDATION_EXTERN NSString *const kNetworkConnectFailTip;
/** 错误码在200-500以外的失败统一提示 */
FOUNDATION_EXTERN NSString *const kNetworkFailCommomTip;
/** 请求加载中统一提示 */
FOUNDATION_EXTERN NSString *const kNetworkLoadingTip;
/** 请求成功状态码 */
FOUNDATION_EXTERN NSString *const kNetworkSuccessStatus;
/** 请求失败状态码 */
FOUNDATION_EXTERN NSString *const kNetworkErrorStatues;
/** 数据码键 */
FOUNDATION_EXTERN NSString *const kNetworkCodeKey;
/** 后台反馈消息键 */
FOUNDATION_EXTERN NSString *const kNetworkMessageKey;
/** 数据键 */
FOUNDATION_EXTERN NSString *const kNetworkDataKey;
/** 列表数据键.可选 */
FOUNDATION_EXTERN NSString *const kNetworkListkey;
/** 友好状态码最小值 */
FOUNDATION_EXTERN NSInteger const kNetworkStatuesMin;
/** 友好状态码最大值 */
FOUNDATION_EXTERN NSInteger const kNetworkStatuesMax;
/** 登录失效状态 */
FOUNDATION_EXTERN NSString *const kNetworkLoginFailStatus;
/** 令牌失效通知key */
FOUNDATION_EXTERN NSString *const kNetworkTokenExpiryNotificationKey;




/**
 网络请求方法

 - CSNetworkMethodPOST:  POST
 - CSNetworkMethodGET: GET
 - CSNetworkMethodHEAD: HEAD
 - CSNetworkMethodPUT: PUT
 */
typedef NS_ENUM(NSUInteger, CSNetworkMethod) {
    CSNetworkMethodPOST = 0,
    CSNetworkMethodGET  = 1,
    CSNetworkMethodHEAD = 2,
    CSNetworkMethodPUT  = 3
};



@interface CSNetworkModel : NSObject

/** 
 请求参数字典信息
 */
@property (nonatomic, strong) id parameters;
/**
 必传参数:请求地址
 */
@property (nonatomic,copy) NSString *requestUrl;
/**
 请求类型(默认为post)
 */
@property (nonatomic, assign) CSNetworkMethod requestType;
/** 
 请求超时 (默认为60s) 
 */
@property (nonatomic,assign) int timeOut;

/** 
 可选参数:如果请求时传一个空数组进来,底层会自动管理相同的请求,禁止同时重复请求
 */
@property (nonatomic, strong) NSMutableArray <NSURLSessionDataTask *> *sessionDataTaskArr;

@end









