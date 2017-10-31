//
//  CSURLSession.h
//  CSKit
//
//  Created by mac on 2017/10/18.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 JSON请求的主体类型
 
 - CSURLConnectionJsonType: 此选项将将JSON请求的正文类型设置为"application/json"
 - CSURLConnectionvndapiJsonType: 此选项将将JSON请求的正文类型设置为"application/vnd.api+json". 某些Web API可能需要这样做
 */
typedef NS_ENUM(NSUInteger, CSURLConnectionJsonTypes) {
    CSURLConnectionJsonType = 0,
    CSURLConnectionvndapiJsonType = 1
};


/**
 该常量用于将请求方法设置为POST
 */
extern NSString * const CSURLPostMethod;
/**
 该常量用于将请求方法设置为PUT
 */
extern NSString * const CSURLPutMethod;
/**
 该常量用于将请求方法设置为PATCH
 */
extern NSString * const CSURLPatchMethod;
/**
 该常量用于将请求方法设置为DELETE
 */
extern NSString * const CSURLDeleteMethod;



@interface CSURLSession : NSObject

/**
 请求的用户代理. 示例: "MAL Updater OS X 2.2.13 (Macintosh; Mac OS X 10.12.3; en_US)"
 @see setUserAgent:
 */
@property (strong, setter=setUserAgent:) NSString *useragent;
/** 请求的POST方法. (e.g. POST) */
@property (strong, setter=setPostMethod:) NSString *postmethod;
/** 请求的标题 */
@property (strong) NSMutableDictionary *headers;
/** 请求的表单数据 */
@property (strong, setter=setFormData:) NSMutableDictionary *formdata;
/** 请求的响应 */
@property (weak) NSHTTPURLResponse *response;
/** 请求的响应数据 */
@property (strong, getter=getResponseData) NSData *responsedata;
/** 执行请求时包含任何错误 */
@property (weak, getter=getError) NSError *error;
/** 请求的URL */
@property (strong, setter=setURL:, getter=getURL) NSURL *URL;
/** 请求是否使用Cookie */
@property (setter=setUseCookies:) BOOL usecookies;

/** 创建一个CSURLSession实例 */
- (instancetype)init;
- (instancetype)initWithURL:(NSURL *)address;

/** 以字符串形式从响应中返回数据 */
- (NSString *)getResponseDataString;
/** 将JSON响应数据作为NSArray或NSDictionary返回的方便方法 */
- (id)getResponseDataJsonParsed;
/** 返回请求的状态代码 */
- (long)getStatusCode;

/**
 允许您向请求添加HTTP标头.
 @param object 标头的值.
 @param key    标头的名称.
 */
- (void)addHeader:(id)object
           forKey:(NSString *)key;
/**
 允许您添加包含数据的参数(parameter).
 @param object 参数的值.
 @param key 参数的名称.
 */
- (void)addFormData:(id)object
             forKey:(NSString *)key;

/** 启动GET同步请求 */
- (void)startRequest;
/**
 启动一个表单同步请求.
 如果没有指定aa post方法,它将默认为POST.
 */
- (void)startFormRequest;

/**
 使用任何JSON输入启动JSON同步请求.
 如果没有指定aa post方法,它将默认为POST.
 
 @param body JSON数据的字符串格式.
 @param bodytype JSON数据的类型.
 请参阅CSURLConnectionJsonTypes枚举以查看aviliable选项.
 */
- (void)startJSONRequest:(NSString *)body type:(int)bodytype;
- (void)startJSONFormRequest:(int)bodytype;

@end






