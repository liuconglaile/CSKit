//
//  NSUserDefaults+Extended.h
//  CSKit
//
//  Created by mac on 2017/10/18.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Extended)

/**
 快速存储值
 
 @param value 值
 @param key 键
 @param sync 是否云盘
 */
- (void)setValue:(id)value  forKey:(NSString *)key iCloudSync:(BOOL)sync;
- (void)setObject:(id)value forKey:(NSString *)key iCloudSync:(BOOL)sync;


/**
 快速取值
 
 @param key 键
 @param sync 是否云盘
 @return 值
 */
- (id)valueForKey:(NSString *)key  iCloudSync:(BOOL)sync;
- (id)objectForKey:(NSString *)key iCloudSync:(BOOL)sync;

- (BOOL)synchronizeAlsoiCloudSync:(BOOL)sync;



/**
 基于 key 获取所存储的相关类型值
 
 @param defaultName  key
 @return  值.如果不是相同类型则返回 nil
 */
+ (NSString *)stringForKey:(NSString *)defaultName;
+ (NSArray *)arrayForKey:(NSString *)defaultName;
+ (NSDictionary *)dictionaryForKey:(NSString *)defaultName;
+ (NSData *)dataForKey:(NSString *)defaultName;
+ (NSArray *)stringArrayForKey:(NSString *)defaultName;
+ (NSInteger)integerForKey:(NSString *)defaultName;
+ (float)floatForKey:(NSString *)defaultName;
+ (double)doubleForKey:(NSString *)defaultName;
+ (BOOL)boolForKey:(NSString *)defaultName;
+ (NSURL *)URLForKey:(NSString *)defaultName;



/**
 快速存储
 
 @param value 值
 @param defaultName 键
 */
+ (void)setObject:(id)value forKey:(NSString *)defaultName;
+ (id)arcObjectForKey:(NSString *)defaultName;
+ (void)setArcObject:(id)value forKey:(NSString *)defaultName;

@end
