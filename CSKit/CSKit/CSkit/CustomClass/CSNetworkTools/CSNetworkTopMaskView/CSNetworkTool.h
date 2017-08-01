//
//  CSNetworkTool.h
//  CSKit
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSNetworkModel.h"


typedef void (^CSLoadSuccessBlock) (id returnValue);
typedef void (^CSLoadFailureBlock) (NSError * error);


@interface CSNetworkTool : NSObject


/**
 http 发送请求入口

 @param requestModel 请求模型
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @return 请求体
 */
+ (NSURLSessionDataTask *)sendOKRequest:(CSNetworkModel *)requestModel
                                success:(CSLoadSuccessBlock)successBlock
                                failure:(CSLoadFailureBlock)failureBlock;

/**
 取消全局请求管理数组中所有请求操作
 可在注销&退出登录&内存警告时调用此方法
 */
+ (void)cancelGlobalAllReqMangerTask;

@end




