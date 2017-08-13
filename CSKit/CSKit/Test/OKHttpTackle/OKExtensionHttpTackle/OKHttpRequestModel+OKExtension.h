//
//  OKHttpRequestModel+OKExtension.h
//  okdeer-commonLibrary
//
//  Created by mao wangxin on 2016/12/22.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKHttpRequestModel.h"
#import <UIKit/UIKit.h>

//如果请求时缓存了网络数据,则下次相同的请求地址,则会优先返回缓存数据,同时请求最新的数据再返回
typedef enum : NSUInteger {
    RequestIgnoreCacheData, //忽略网络数据
    RequestStoreCacheData,  //缓存网络数据
} CCRequestCachePolicy;//是否需要缓存网络数据


/**
 * 网络请求Model扩展信息
 */
@interface OKHttpRequestModel (OKExtension)


/** 请求时转圈的父视图 */
@property (nonatomic, strong) UIView *loadView;

/** 页面上有表格如果传此参数,请求完成后会自动刷新页面,控制表格下拉刷新状态, 请求失败,空数据等 会自动添加空白页 */
@property (nonatomic, strong) UIScrollView *dataTableView;

/** 是否在底层提示失败信息 (默认提示) */
@property (nonatomic, assign) BOOL forbidTipErrorInfo;

/** 是否在失败是尝试重新请求，(如果尝试则3次) */
@property (nonatomic, assign) BOOL attemptRequestWhenFail;

/** 是否需要在底层缓存当前网络数据 */
@property (nonatomic, assign) CCRequestCachePolicy requestCachePolicy;

/** 此次返回的数据是否为缓存数据 */
@property (nonatomic, assign) BOOL isCacheData;

@end
