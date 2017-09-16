//
//  CSNetworkTool+Extension.h
//  CSKit
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSNetworkTool.h"
#import "CSNetworkModel+Extension.h"
#import "UIScrollView+CSNetworkExtension.h"




/**
 此网络请求,底层封装解决的问题:
 
 1.每个请求只需要设置loadView属性,即可添加请求时的转圈,和请求完成时取消转圈;
 2.每个请求只需要设置forbidTipErrorInfo属性,即可自动根据服务端code判断是否添加请求失败提示弹框
 3.每个请求只需要设置CCRequestCachePolicy属性,即可提供是否需要缓存网络数据到数据库;
 4.如果页面上有表格的请求,只需要设置dataTableView属性,即可自动控制表格上下拉刷新控件的收起状态;
 5.处理了表格如果有分页数据, 底层根据服务端的totalPage字段自动判断是否还有下一页逻辑,页面累加返回数据即可;
 6.处理了如果请求无数据, 请求失败, 无网络请求失败时,则自动根据状态,添加相关提示页,并点击按钮可再次重试请求操作;
 7.处理了如果请求失败，只需设置属性，则底层自动重复请求多次的操作(可自定义重复的次数);
 */
@interface CSNetworkTool (Extension)



+ (NSURLSessionDataTask *)sendExtensionRequest:(CSNetworkModel *)requestModel
                                      Progress:(CSProgress)aProgress
                                       success:(CSSuccess)successBlock
                                       failure:(CSFailure)failureBlock;


+ (NSURLSessionDataTask *)sendExtensionRequest:(CSNetworkModel *)requestModel
                                     jsonClass:(Class)aJsonClass
                                       success:(CSSuccess)successBlock
                                       failure:(CSFailure)failureBlock;



@end
