//
//  CSURLRequest.m
//  CSKit
//
//  Created by mac on 2017/10/19.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSURLRequest.h"
#import <UIKit/UIKit.h>


#define CSREQUEST_BOUNDARY @"CSREQUESTBOUNDARY" ///请求边界
#define CSREQUEST_LINE @"\r\n"                  ///分界线

@interface NSMutableData (body)

- (void)appendStr:(NSString *)str;

@end
@implementation NSMutableData (body)
///拼接数据
- (void)appendStr:(NSString *)str{
    [self appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}


@end



@interface CSURLRequest()
/** 分割线边界 */
@property (nonatomic, strong)NSString *boundary;
@end


@implementation CSURLRequest

- (NSString *)boundary{
    if (!_boundary || _boundary.length == 0) {
        _boundary = CSREQUEST_BOUNDARY;
    }
    return _boundary;
}


- (void)setContentType:(NSString *)contentType{
    [self addHeaderValue:contentType forKey:@"content-Type"];
}

- (void)setRequestType:(CSRequestType)requestType{
    
    switch (requestType) {
        case CSRequestTypeJSON:{
            self.contentType = @"application/json";
        }break;
        case CSRequestTypeData:{
            self.contentType = @"multipart/form-data";
        }break;
        default:
            break;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultSet];
    }
    return self;
}

- (void)defaultSet{
    self.requestType = CSRequestTypeJSON;//设置为json
    self.timeoutInterval = 15;//超时时间设为20s
}

- (void)addHeaderValue:(NSString *)value forKey:(NSString *)key{
    
    if (value) {
        [self addValue:value forHTTPHeaderField:key];
    }
}

- (instancetype (^)(NSString *, CSRequestType, NSString *, id))set{
    
    return ^(NSString *method, CSRequestType type, NSString *api, id parameter){
        self.HTTPMethod = method;
        self.requestType = type;
        [self urlHandler:api];
        [self parameterHandler:parameter];
        return self;
    };
}




///===========================================================
///MARK: 参数相关处理
///===========================================================

- (void)parameterHandler:(id)aParameter{
    
    [self.HTTPMethod isEqualToString:@"GET"]?[self parameterGETHandler:aParameter]:[self parameterPOSTHandler:aParameter];
}

- (void)parameterPOSTHandler:(id)aParameter{
    
    if (aParameter == nil||self.URL == nil) {
        return;
    }
    if ([aParameter isKindOfClass:[NSData class]]) {
        self.HTTPBody = aParameter;
    }else if ([aParameter isKindOfClass:[NSString class]]){
        self.HTTPBody = [aParameter dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        if (self.requestType == CSRequestTypeJSON) {
            
            self.HTTPBody = [NSJSONSerialization dataWithJSONObject:aParameter options:kNilOptions error:NULL];
        }else if (self.requestType == CSRequestTypeData){
            
            [self parameterFormDataHandler:aParameter];
        }
        
    }
    
}

- (void)parameterGETHandler:(id)aParameter{
    
    if (aParameter == nil||self.URL == nil) {
        return;
        
    }else if ([aParameter isKindOfClass:[NSString class]]){
        
        self.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@",self.URL.absoluteString,aParameter]];
        
    }else if ([aParameter isKindOfClass:[NSDictionary class]]){
        
        NSMutableString *mutableStr = [NSMutableString stringWithString:self.URL.absoluteString];
        for (NSString *key in ((NSDictionary *)aParameter).allKeys) {
            [mutableStr appendFormat:@"&%@=%@",key,aParameter[key]];
        }
        self.URL = [NSURL URLWithString:[self fixUrl:mutableStr]];
        
    }else{
        NSLog(@"错误的参数类型");
    }
}

- (void)parameterFormDataHandler:(NSDictionary *)aParameter{
    
    self.contentType = [[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",self.boundary];
    NSString *beginBoundary = [NSString stringWithFormat:@"--%@",self.boundary];
    NSString *endBoundary = [NSString stringWithFormat:@"%@--",beginBoundary];
    NSMutableData *bodyData = [NSMutableData data];
    NSArray *keys = aParameter.allKeys;
    
    for (NSString *key in keys) {
        id value = aParameter[key];
        //分割线，换一行
        [bodyData appendStr:[NSString stringWithFormat:@"%@%@",beginBoundary,CSREQUEST_LINE]];
        
        if ([value isKindOfClass:[UIImage class]]||[value isKindOfClass:[NSData class]]) {
            [bodyData appendStr:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"\"%@",key,CSREQUEST_LINE]];
            //设置文件类型:"application/octet-stream"为二进制流可转为任意文件形式，换两行
            [bodyData appendStr:[NSString stringWithFormat:@"Content-Type: application/octet-stream; charset=utf-8%@%@",CSREQUEST_LINE,CSREQUEST_LINE]];
            if ([value isKindOfClass:[UIImage class]]) {
                [bodyData appendData:UIImageJPEGRepresentation(value, 1.0)];
            }else{
                [bodyData appendData:value];
            }
            //设置图片后换一行
            [bodyData appendStr:CSREQUEST_LINE];
        }else{
            //key后换两行 value后换一行
            [bodyData appendStr:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"%@%@%@%@",key,CSREQUEST_LINE,CSREQUEST_LINE,value,CSREQUEST_LINE]];
        }
    }
    //结束分割线，换一行
    [bodyData appendStr:[NSString stringWithFormat:@"%@%@",endBoundary,CSREQUEST_LINE]];
    [self addHeaderValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forKey:@"Content-Length"];
    self.HTTPBody = bodyData;
}


///===========================================================
///MARK: URL相关处理
///===========================================================

- (void)urlHandler:(NSString *)api{
    if ([self isUrl:api]) {
        self.URL = [NSURL URLWithString:[self deleteSpace:api]];
    }else{
        if ([self isUrl:self.baseURL]) {
            self.URL = [self formartUrlWithApi:api];
        }else{
            NSLog(@"\n【VDRequest】:URL ERROR");
        }
    }
}
- (BOOL)isUrl:(NSString *)strUrl{
    if (!strUrl) {
        return NO;
    }else{
        
        NSURL *url = [NSURL URLWithString:[self deleteSpace:strUrl]];
        if ([url.scheme isEqualToString:@"http"]||[url.scheme isEqualToString:@"https"]) {
            return YES;
        }
    }
    return NO;
}
- (NSString *)deleteSpace:(NSString *)str{
    
    if (!str) {
        return nil;
    }
    NSString *str1= [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return [str2 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
}
- (NSString *)fixUrl:(NSString *)str{
    
    NSString *urlStr = [str stringByReplacingOccurrencesOfString:@"?" withString:@"&"];
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"&&" withString:@"&"];
    NSRange range = [urlStr rangeOfString:@"&"];
    
    if (range.location != NSNotFound) {
        
        urlStr = [urlStr stringByReplacingCharactersInRange:range withString:@"?"];
    }
    return urlStr;
}
- (NSURL *)formartUrlWithApi:(NSString *)api{
    
    if (![self deleteSpace:api]) {
        
        return [NSURL URLWithString:[self deleteSpace:self.baseURL]];
    }
    
    NSString *scheme = [NSURL URLWithString:self.baseURL].scheme;
    NSString *firstUrl = [self.baseURL substringFromIndex:[scheme isEqualToString:@"http"]?7:8];
    firstUrl = [NSString stringWithFormat:@"%@%@",firstUrl,api];
    firstUrl = [firstUrl stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    
    return [NSURL URLWithString:[self deleteSpace:[NSString stringWithFormat:@"%@://%@",scheme,firstUrl]]];
}



@end





