//
//  CSNetworkModel.m
//  CSKit
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSNetworkModel.h"


/** 网络连接失败提示 */
NSString *const kNetworkConnectFailTip = @"网络开小差,请稍后再试哦!";
/** 错误码在200-500以外的失败统一提示 */
NSString *const kNetworkFailCommomTip = @"加载失败,请重试!";
/** 请求加载中统一提示 */
NSString *const kNetworkLoadingTip = @"加载中...";
/** 请求成功状态码 */
NSString *const kNetworkSuccessStatus = @"1";
/** 请求失败状态码 */
NSString *const kNetworkErrorStatues = @"9";
/** 数据码键 */
NSString *const kNetworkCodeKey = @"code";
/** 后台反馈消息键 */
NSString *const kNetworkMessageKey = @"msg";
/** 数据键 */
NSString *const kNetworkDataKey = @"data";
/** 列表数据键.可选 */
NSString *const kNetworkListkey = @"data";
/** 友好状态码最小值 */
NSInteger const kNetworkStatuesMin = 200;
/** 友好状态码最大值 */
NSInteger const kNetworkStatuesMax = 500;
/** 登录失效状态 */
NSString *const kNetworkLoginFailStatus = @"40116";
/** 令牌失效通知key */
NSString *const kNetworkTokenExpiryNotificationKey = @"kNetworkTokenExpiryNotificationKey";


@implementation CSNetworkModel

@end
