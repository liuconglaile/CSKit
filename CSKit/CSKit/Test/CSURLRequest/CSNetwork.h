//
//  CSNetwork.h
//  CSKit
//
//  Created by mac on 2017/10/19.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSURLRequest.h"
#import "CSResponse.h"

@interface CSNetwork : NSObject

@property (nonatomic, strong) CSURLRequest * request;
@property (nonatomic, strong) CSResponse * response;
@property (nonatomic, strong) NSString * baseURL;
@property (class, readonly, strong) CSNetwork * defaultManager;

///POST请求
- (void)POST:(NSString *)api Parameter:(id)aParameter responseBlock:(CSResponseBlock)responseBlock;
///GET请求
- (void)GET:(NSString *)api Parameter:(id)aParameter responseBlock:(CSResponseBlock)responseBlock;


- (void)sendRequestWithApi:(NSString *)api
                    method:(NSString *)method
                      type:(CSRequestType)type
                    Parameter:(id)aParameter
             responseBlock:(CSResponseBlock)responseBlock;

- (void)formDataUploadWithApi:(NSString *)api
                       Parameter:(id)aParameter
                        files:(NSDictionary *)files
                responseBlock:(CSResponseBlock)responseBlock;


///===========================================================
///MARK: 链式语句
///===========================================================
- (void(^)(NSString *api, id aParameter, CSResponseBlock block))POST;
- (void(^)(NSString *api, id aParameter, CSResponseBlock block))GET;
- (void(^)(NSString *api, NSString *method, CSRequestType type, id aParameter, CSResponseBlock block))sendRequest;
- (void(^)(NSString *api, id aParameter, NSDictionary *files,CSResponseBlock block))uploadFiles;

@end


