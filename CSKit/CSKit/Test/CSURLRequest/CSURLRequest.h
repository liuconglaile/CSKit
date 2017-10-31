//
//  CSURLRequest.h
//  CSKit
//
//  Created by mac on 2017/10/19.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 响应格式

 - CSRequestTypeJSON: 默认 json
 - CSRequestTypeData: xml -> data
 */
typedef NS_ENUM(NSUInteger, CSRequestType) {
    CSRequestTypeJSON,
    CSRequestTypeData
};

@interface CSURLRequest : NSMutableURLRequest

@property (nonatomic, strong) NSString * baseURL;
@property (nonatomic, strong) NSString * contentType;
@property (nonatomic, assign) CSRequestType requestType;

///默认 json
- (instancetype)init;


/**
 添加标头文件(文件 <--> 文件名)

 @param value 值
 @param key 键
 */
- (void)addHeaderValue:(NSString *)value forKey:(NSString *)key;


- (instancetype(^)(NSString *method, CSRequestType type, NSString *api, id parameter))set;


@end
