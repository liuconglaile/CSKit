//
//  NSURL+Extended.h
//  CSKit
//
//  Created by mac on 2017/10/18.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Extended)

@property(nonatomic,strong,readonly) NSDictionary *queryValue;

- (NSString  *)urlPath; // host+path
- (NSDictionary *)queryValues;
- (NSURL *)URLByAppendingPathComponent:(NSString *)string queryValue:(NSDictionary *)queryValue;
+ (NSURL *)URLWithString:(NSString *)string queryValue:(NSDictionary *)queryValue;
+ (NSURL *)URLWithString:(NSString *)string relativeToURL:(NSURL *)baseURL queryValues:(NSDictionary *)query;
- (NSString *)firstPathComponent;
- (NSString *)firstPathComponentRelativeTo:(NSString *)basePath;

@end
