//
//  NSHTTPCookieStorage+Utilities.h
//  CSCategory
//
//  Created by mac on 17/5/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPCookieStorage (Utilities)

/**
 *  @brief 存储 UIWebView cookies到磁盘目录
 */
- (void)saveCookie;
/**
 *  @brief 读取UIWebView cookies从磁盘目录
 */
- (void)loadCookie;

@end



/*
 持久化 UIWebView的cookies 到磁盘。要使用一个初始的NSURLRequest发送的cookie，你必须在加载cookies以后执行下列操作:
 
 NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:yourURL];
 NSDictionary* headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
 [request setAllHTTPHeaderFields:headers];
 
 参考: http://www.jianshu.com/p/e17e855f2d20
 
 
 概述
 
 有时候我们通过cookie判断登录状态，以及进行session跟踪，虽然主要工作是后台完成的，但我们也需要进行一些操作。
 请求接口时，如果没有cookie后台会生成一个cookie返回给客户端，客户端会自动存储本地，所以只需要每次取出来再次传过去就可以了。
 
 取出cookie
 
 NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
 NSDictionary *cookieDict = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
 NSString *cookie = [cookieDict objectForKey:@"Cookie"];
 //设置http的header的cookie
 [urlRequest setValue:cookie forHTTPHeaderField:@"Cookie"];
 
 
 退出登录时，删除cookie
 
 NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
 for (NSHTTPCookie *cookie in cookiesArray) {
 [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
 }
 
 */
