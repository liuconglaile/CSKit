//
//  CCHttpRequestTools.h
//  okdeer-commonLibrary
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OKHttpRequestModel.h"

typedef void (^OKHttpSuccessBlock) (id returnValue);
typedef void (^OKHttpFailureBlock) (NSError * error);


@interface OKHttpRequestTools : NSObject

/**
 http 发送请求入口
 @param requestModel 请求参数等信息
 @param successBlock 请求成功执行的block
 @param failureBlock 请求失败执行的block
 @return 返回当前请求的对象
 */
+ (NSURLSessionDataTask *)sendOKRequest:(OKHttpRequestModel *)requestModel
                              success:(OKHttpSuccessBlock)successBlock
                              failure:(OKHttpFailureBlock)failureBlock;

/**
 * 取消全局请求管理数组中所有请求操作, (可在注销,退出登录,内存警告时调用此方法)
 */
+ (void)cancelGlobalAllReqMangerTask;

@end
