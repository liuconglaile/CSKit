//
//  CSNetworkModel+Extension.h
//  CSKit
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSNetworkModel.h"


/**
 缓存策略

 - CSNetworkIgnoreCachePolicy: 忽略
 - CSNetworkStoreCachePolicy: 缓存
 如果设置缓存数据,则下次相同的请求地址,则优先返回缓存数据.同时请求最新的数据再返回(则返回两次)
 */
typedef NS_ENUM(NSUInteger, CSNetworkCachePolicy) {
    CSNetworkIgnoreCachePolicy,
    CSNetworkStoreCachePolicy
};

@interface CSNetworkModel (Extension)

/** 
 请求时转圈的父视图
 */
@property (nonatomic, strong) UIView *loadView;

/** 
 页面上有表格如果传此参数,请求完成后会自动刷新页面,控制表格下拉刷新状态, 
 请求失败&空数据等 会自动添加空白页
 */
@property (nonatomic, strong) UIScrollView *dataTableView;

/** 
 是否在底层提示失败信息 (默认提示)
 */
@property (nonatomic, assign) BOOL forbidTipErrorInfo;

/** 
 是否在失败是尝试重新请求,(如果尝试则3次)
 */
@property (nonatomic, assign) BOOL attemptRequestWhenFail;

/** 
 缓存策略
 */
@property (nonatomic, assign) CSNetworkCachePolicy requestCachePolicy;

/** 
 此次返回的数据是否为缓存数据 
 */
@property (nonatomic, assign) BOOL isCacheData;


@end



