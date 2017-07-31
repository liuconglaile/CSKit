//
//  NSURL+Utilities.h
//  CSCategory
//
//  Created by mac on 2017/5/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Utilities)

@property(nonatomic,strong,readonly) NSDictionary *queryValue;

- (NSString  *)urlPath; // host+path

- (NSDictionary *)queryValues;

- (NSURL *)URLByAppendingPathComponent:(NSString *)string queryValue:(NSDictionary *)queryValue;

+ (NSURL *)URLWithString:(NSString *)string queryValue:(NSDictionary *)queryValue;

+ (NSURL *)URLWithString:(NSString *)string relativeToURL:(NSURL *)baseURL queryValues:(NSDictionary *)query;

- (NSString *)firstPathComponent;

- (NSString *)firstPathComponentRelativeTo:(NSString *)basePath;

@end
