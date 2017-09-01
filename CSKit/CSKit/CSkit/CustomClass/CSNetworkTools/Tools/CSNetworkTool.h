//
//  CSNetworkTool.h
//  CSKit
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSNetworkModel.h"


//typedef void (^CSLoadSuccessBlock) (id returnValue);
//typedef void (^CSLoadFailureBlock) (NSError * error);


typedef void (^CSProgress)(NSProgress *downloadProgress);
typedef void (^CSSuccess)(id responseObject);
typedef void (^CSFailure)(NSError   *error);




@interface CSNetworkTool : NSObject



/**
 发起请求入口

 @param requestModel 请求模型
 @param aProgress 请求进度
 @param aSuccess 请求成功回调
 @param aFailure 请求失败回调
 @return 请求体
 */
+ (NSURLSessionDataTask *)sendRequest:(CSNetworkModel *)requestModel
                             Progress:(CSProgress)aProgress
                              Success:(CSSuccess)aSuccess
                              Failure:(CSFailure)aFailure;


/**
 取消全局请求管理数组中所有请求操作
 可在注销&退出登录&内存警告时调用此方法
 */
+ (void)cancelGlobalAllReqMangerTask;

@end




