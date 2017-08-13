//
//  OKHttpRequestModel+OKExtension.m
//  okdeer-commonLibrary
//
//  Created by mao wangxin on 2016/12/22.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKHttpRequestModel+OKExtension.h"
#import <objc/runtime.h>

static char const * const kLoadViewKey              = "kLoadViewKey";
static char const * const kDataTableViewKey         = "kDataTableViewKey";
static char const * const kForbidTipErrorInfoKey    = "kForbidTipErrorInfoKey";
static char const * const kAttemptRequestWhenFail   = "kAttemptRequestWhenFail";
static char const * const kRequestCachePolicyKey    = "kRequestCachePolicyKey";
static char const * const kIsCacheDataKey           = "kIsCacheDataKey";


@implementation OKHttpRequestModel (OKExtension)


#pragma mark - ========== 请求时的转圈父视图 ==========

- (void)setLoadView:(UIView *)loadView
{
    objc_setAssociatedObject(self, kLoadViewKey, loadView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)loadView
{
    return objc_getAssociatedObject(self, kLoadViewKey);
}

#pragma mark - ========== 页面上有表格如果传此参数,请求完成后会帮你刷新页面,控制下拉刷新状态等 ==========

- (void)setDataTableView:(UIScrollView *)dataTableView
{
    objc_setAssociatedObject(self, kDataTableViewKey, dataTableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)dataTableView
{
    return objc_getAssociatedObject(self, kDataTableViewKey);
}

#pragma mark - ========== 是否在底层提示失败信息 (默认提示) ==========

- (void)setForbidTipErrorInfo:(BOOL)forbidTipErrorInfo
{
    objc_setAssociatedObject(self, kForbidTipErrorInfoKey, @(forbidTipErrorInfo), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)forbidTipErrorInfo
{
    id value = objc_getAssociatedObject(self, kForbidTipErrorInfoKey);
    return [value boolValue];
}

#pragma mark - ========== 是否在失败是尝试重新请求，(如果尝试则3次) ==========

- (void)setAttemptRequestWhenFail:(BOOL)attemptRequestWhenFail
{
    objc_setAssociatedObject(self, kAttemptRequestWhenFail, @(attemptRequestWhenFail), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)attemptRequestWhenFail
{
    id value = objc_getAssociatedObject(self, kAttemptRequestWhenFail);
    return [value boolValue];
}

#pragma mark - ========== 请求缓存策略 ==========
/**
 * 如果请求时缓存了网络数据,则下次相同的请求地址时,
 * 则会优先返回缓存数据,同时请求最新的数据再返回
 */
- (void)setRequestCachePolicy:(CCRequestCachePolicy)requestCachePolicy
{
    objc_setAssociatedObject(self, kRequestCachePolicyKey, @(requestCachePolicy), OBJC_ASSOCIATION_ASSIGN);
}

- (CCRequestCachePolicy)requestCachePolicy
{
    id obj = objc_getAssociatedObject(self, kRequestCachePolicyKey);
    CCRequestCachePolicy policy = [obj integerValue];
    return policy;
}

#pragma mark - ========== 此次返回的数据是否为缓存数据 ==========

- (void)setIsCacheData:(BOOL)isCacheData
{
    objc_setAssociatedObject(self, kIsCacheDataKey, @(isCacheData), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isCacheData
{
    id value = objc_getAssociatedObject(self, kIsCacheDataKey);
    return [value boolValue];
}

@end
