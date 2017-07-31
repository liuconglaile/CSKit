//
//  NSUserDefaults+Utilities.h
//  CSCategory
//
//  Created by mac on 17/5/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Utilities)

- (void)setValue:(id)value  forKey:(NSString *)key iCloudSync:(BOOL)sync;
- (void)setObject:(id)value forKey:(NSString *)key iCloudSync:(BOOL)sync;

- (id)valueForKey:(NSString *)key  iCloudSync:(BOOL)sync;
- (id)objectForKey:(NSString *)key iCloudSync:(BOOL)sync;

- (BOOL)synchronizeAlsoiCloudSync:(BOOL)sync;






/*
 * defaultName 参数 key
 * 这个key存储的是啥就啥类型 类型不对则没有 你懂得
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

#pragma mark - WRITE FOR STANDARD

+ (void)setObject:(id)value forKey:(NSString *)defaultName;

#pragma mark - READ ARCHIVE FOR STANDARD

+ (id)arcObjectForKey:(NSString *)defaultName;

#pragma mark - WRITE ARCHIVE FOR STANDARD

+ (void)setArcObject:(id)value forKey:(NSString *)defaultName;




@end
