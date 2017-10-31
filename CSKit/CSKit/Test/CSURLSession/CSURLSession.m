//
//  CSURLSession.m
//  CSKit
//
//  Created by mac on 2017/10/18.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSURLSession.h"
#import "CSURLResponse.h"

@interface CSURLSession ()

@property (strong) NSMutableURLRequest *request;

@end



@implementation CSURLSession

#pragma Post Methods Constants
NSString * const CSURLPostMethod = @"POST";
NSString * const CSURLPutMethod = @"PUT";
NSString * const CSURLPatchMethod = @"PATCH";
NSString * const CSURLDeleteMethod = @"DELETE";



#pragma constructors
- (instancetype)init {
    // 设置默认用户代理
    _useragent =[NSString stringWithFormat:@"%@ %@ (Macintosh; Mac OS X %@; %@)", [NSBundle mainBundle].infoDictionary[@"CFBundleName"],[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"], [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"][@"ProductVersion"], [NSLocale currentLocale].localeIdentifier];
    return [super init];
}
- (instancetype)initWithURL:(NSURL *)address {
    _URL = address;
    return [self init];
}
#pragma getters
- (NSString *)getResponseDataString {
    NSString *datastring = [[NSString alloc] initWithData:_responsedata encoding:NSUTF8StringEncoding];
    return datastring;
}
- (id)getResponseDataJsonParsed {
    return [NSJSONSerialization JSONObjectWithData:_responsedata options:0 error:nil];
}
- (long)getStatusCode {
    return _response.statusCode;
}
#pragma mutators
- (void)addHeader:(id)object
           forKey:(NSString *)key {
    NSLock * lock = [NSLock new]; // NSMutableArray不是线程安全的,在执行操作之前锁定
    [lock lock];
    if (_formdata == nil) {
        //初始化头数据数组
        _headers = [NSMutableDictionary new];
    }
    [_headers setObject:object forKey:key];
    [lock unlock]; //完成操作,解锁
}
-(void)addFormData:(id)object
            forKey:(NSString *)key{
    NSLock * lock = [NSLock new]; // NSMutableArray不是线程安全的,在执行操作之前锁定
    [lock lock];
    if (_formdata == nil) {
        //初始化表单数据数组
        _formdata = [NSMutableDictionary new];
    }
    [_formdata setObject:object forKey:key];
    [lock unlock]; //完成操作,解锁
}
#pragma request functions
-(void)startRequest {
    // 发送同步请求
    _request = [NSMutableURLRequest requestWithURL:_URL];
    // 不要使用Cookies
    _request.HTTPShouldHandleCookies = _usecookies;
    // 设置超时
    _request.timeoutInterval = 15;
    // 设置用户代理
    [_request setValue:_useragent forHTTPHeaderField:@"User-Agent"];
    NSLock * lock = [NSLock new]; // NSMutableArray不是线程安全的,在执行操作之前锁定
    [lock lock];
    // 设置其他标头,如果有的话
    [self setAllHeaders];
    [lock unlock];
    // 发送请求
    CSURLResponse * urlsessionresponse = [self performNSURLSessionRequest];
    _responsedata = urlsessionresponse.responsedata;
    _error = urlsessionresponse.error;
    _response = urlsessionresponse.response;
}
-(void)startFormRequest {
    // 发送同步请求
    _request = [NSMutableURLRequest requestWithURL:_URL];
    // 设置方法
    if (_postmethod.length != 0) {
        _request.HTTPMethod = _postmethod;
    }
    else {
        _request.HTTPMethod = @"POST";
    }
    // 设置内容类型以形成数据
    [_request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    // 不要使用Cookies
    _request.HTTPShouldHandleCookies = _usecookies;
    // 设置用户代理
    [_request setValue:_useragent forHTTPHeaderField:@"User-Agent"];
    // 设置超时
    _request.timeoutInterval = 15;
    NSLock * lock = [NSLock new]; // NSMutableArray不是线程安全的,在执行操作之前锁定
    [lock lock];
    //设置发送数据
    _request.HTTPBody = [self encodeDictionaries:_formdata];
    // 设置其他标头,如果有的话
    [self setAllHeaders];
    [lock unlock];
    // 发起请求
    CSURLResponse * urlsessionresponse = [self performNSURLSessionRequest];
    _responsedata = urlsessionresponse.responsedata;
    _error = urlsessionresponse.error;
    _response = urlsessionresponse.response;
}
-(void)startJSONRequest:(NSString *)body type:(int)bodytype {
    // 发送同步请求
    _request = [NSMutableURLRequest requestWithURL:_URL];
    // 设置方法
    if (_postmethod.length != 0) {
        _request.HTTPMethod = _postmethod;
    }
    else {
        _request.HTTPMethod = @"POST";
    }
    // 设置内容类型以形成数据
    switch (bodytype){
        case 0:
            [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        case 1:
            [_request setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
            break;
    }
    // 不要使用Cookies
    _request.HTTPShouldHandleCookies = _usecookies;
    // 设置用户代理
    [_request setValue:_useragent forHTTPHeaderField:@"User-Agent"];
    // 设置超时
    _request.timeoutInterval = 5;
    NSLock * lock = [NSLock new]; // NSMutableArray不是线程安全的,在执行操作之前锁定
    [lock lock];
    //设置发送数据
    _request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    // 设置其他标头,如果有的话
    [self setAllHeaders];
    [lock unlock];
    // 发起请求
    CSURLResponse * urlsessionresponse = [self performNSURLSessionRequest];
    _responsedata = urlsessionresponse.responsedata;
    _error = urlsessionresponse.error;
    _response = urlsessionresponse.response;
}
-(void)startJSONFormRequest:(int)bodytype {
    
    // 发送同步请求
    _request = [NSMutableURLRequest requestWithURL:_URL];
    // 设置方法
    if (_postmethod.length != 0) {
        _request.HTTPMethod = _postmethod;
    }
    else {
        _request.HTTPMethod = @"POST";
    }
    // 设置内容类型以形成数据
    switch (bodytype){
        case 0:
            [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        case 1:
            [_request setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
            break;
    }
    // 不要使用Cookies
    _request.HTTPShouldHandleCookies = _usecookies;
    // 设置用户代理
    [_request setValue:_useragent forHTTPHeaderField:@"User-Agent"];
    // 设置超时
    _request.timeoutInterval = 5;
    NSLock * lock = [NSLock new]; // NSMutableArray不是线程安全的,在执行操作之前锁定
    [lock lock];
    //设置发送数据
    NSError *jerror;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_formdata options:0 error:&jerror];
    if (!jsonData) {}
    else{
        NSString *JSONString = [[NSString alloc] initWithBytes:jsonData.bytes length:jsonData.length encoding:NSUTF8StringEncoding];
        _request.HTTPBody = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    }
    // 设置其他标头,如果有的话
    [self setAllHeaders];
    [lock unlock];
    // 发起请求
    CSURLResponse * urlsessionresponse = [self performNSURLSessionRequest];
    _responsedata = urlsessionresponse.responsedata;
    _error = urlsessionresponse.error;
    _response = urlsessionresponse.response;
}

#pragma helpers
- (NSData*)encodeDictionaries:(NSDictionary *)dic {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dic.allKeys) {
        NSString *encodedValue = [dic[key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}
-(CSURLResponse *)performNSURLSessionRequest {
    // Based on http://demianturner.com/2016/08/synchronous-nsurlsession-in-obj-c/
    __block NSHTTPURLResponse *urlresponse = nil;
    __block NSData *data = nil;
    __block NSError * error2 = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:_request completionHandler:^(NSData *taskData, NSURLResponse *rresponse, NSError *eerror) {
        data = taskData;
        urlresponse = (NSHTTPURLResponse *)rresponse;
        error2 = eerror;
        dispatch_semaphore_signal(semaphore);
        
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return [[CSURLResponse alloc] initWithData:data withResponse:urlresponse withError:error2];
}
- (void)setAllHeaders {
    if (_headers != nil) {
        for (NSString *key in _headers.allKeys ) {
            //设置任何头文件
            [_request setValue:_headers[key] forHTTPHeaderField:key];
        }
    }
}




@end
