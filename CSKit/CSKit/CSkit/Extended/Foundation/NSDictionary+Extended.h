//
//  NSDictionary+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Extended)

#pragma mark - 字典转换器
///=============================================================================
/// @name 字典转换器
///=============================================================================

/**
 从指定的属性列表数据创建并返回一个字典.
 
 @param plist   其根对象是字典的属性列表数据.
 @return 从二进制plist数据创建的新字典,如果发生错误,则为nil.
 */
+ (nullable NSDictionary *)dictionaryWithPlistData:(NSData *)plist;

/**
 从指定的属性列表创建并返回一个字典xml字符串.
 
 @param plist   一个属性列表,其根对象是字典的xml字符串.
 @return 从plist字符串创建的新字典,如果发生错误,则为nil.
 
 @discussion 苹果已经实现了这种方法,但没有公开.
 */
+ (nullable NSDictionary *)dictionaryWithPlistString:(NSString *)plist;


/**
 将url参数转换成NSDictionary

 @param query url参数
 @return NSDictionary
 */
+ (NSDictionary *)dictionaryWithURLQuery:(NSString *)query;
- (NSString *)URLQueryString;

/**
 将字典序列化为二进制属性列表数据.
 
 @return 二进制plist数据,如果发生错误,则为nil.
 
 @discussion 苹果已经实现了这种方法,但没有公开.
 */
- (nullable NSData *)plistData;

/**
 将字典序列化为xml属性列表字符串.
 
 @return 一个plist xml字符串,如果发生错误,则为nil.
 */
- (nullable NSString *)plistString;

/**
 返回一个包含字典键的新数组,密钥应为NSString,它们将按升序排序.
 
 @return 一个包含字典键的新数组,或者如果字典没有条目,则为空数组.
 */
- (NSArray *)allKeysSorted;

/**
 返回一个包含按键排序的字典值的新数组
 数组中的值的顺序由键定义.密钥应为NSString,它们将按升序排序.
 
 @return 一个新的数组,其中包含按键排序的字典值,或者如果字典没有条目,则为空数组.
 */
- (NSArray *)allValuesSortedByKeys;

/**
 返回BOOL值,告诉字典是否具有键的对象.
 
 @param key The key.
 */
- (BOOL)containsObjectForKey:(id)key;

/**
 返回一个包含键条目的新字典.如果键为空或无,则返回一个空字典.
 
 @param keys The keys.
 @return 键的条目.
 */
- (NSDictionary *)entriesForKeys:(NSArray *)keys;

/** 将字典转换为json字符串.如果发生错误,返回nil. */
- (nullable NSString *)jsonStringEncoded;

/** 将字典转换为json字符串格式化.如果发生错误,返回nil. */
- (nullable NSString *)jsonPrettyStringEncoded;

/**
 尝试解析XML并将其包装到字典中.如果你只是想从一个小的xml获得一些值,请试试看.
 
 例如 XML: "<config><a href="test.com">link</a></config>"
 返回: @{@"_name":@"config", @"a":{@"_text":@"link",@"href":@"test.com"}}
 
 @param xmlDataOrString NSData或NSString格式的XML.
 @return 返回一个新的字典,如果发生错误,则返回nil.
 */
+ (nullable NSDictionary *)dictionaryWithXML:(id)xmlDataOrString;

#pragma mark - 字典键值获取
///=============================================================================
/// @name 字典键值获取
///=============================================================================

- (BOOL)boolValueForKey:(NSString *)key default:(BOOL)def;

- (char)charValueForKey:(NSString *)key default:(char)def;
- (unsigned char)unsignedCharValueForKey:(NSString *)key default:(unsigned char)def;

- (short)shortValueForKey:(NSString *)key default:(short)def;
- (unsigned short)unsignedShortValueForKey:(NSString *)key default:(unsigned short)def;

- (int)intValueForKey:(NSString *)key default:(int)def;
- (unsigned int)unsignedIntValueForKey:(NSString *)key default:(unsigned int)def;

- (long)longValueForKey:(NSString *)key default:(long)def;
- (unsigned long)unsignedLongValueForKey:(NSString *)key default:(unsigned long)def;

- (long long)longLongValueForKey:(NSString *)key default:(long long)def;
- (unsigned long long)unsignedLongLongValueForKey:(NSString *)key default:(unsigned long long)def;

- (float)floatValueForKey:(NSString *)key default:(float)def;
- (double)doubleValueForKey:(NSString *)key default:(double)def;

- (NSInteger)integerValueForKey:(NSString *)key default:(NSInteger)def;
- (NSUInteger)unsignedIntegerValueForKey:(NSString *)key default:(NSUInteger)def;

- (nullable NSNumber *)numberValueForKey:(NSString *)key default:(nullable NSNumber *)def;
- (nullable NSString *)stringValueForKey:(NSString *)key default:(nullable NSString *)def;

- (void)each:(void (^)(id k, id v))block;
- (void)eachKey:(void (^)(id k))block;
- (void)eachValue:(void (^)(id v))block;
- (NSArray *)map:(id (^)(id key, id value))block;
- (NSDictionary *)pick:(NSArray *)keys;
- (NSDictionary *)omit:(NSArray *)key;

- (BOOL)hasKey:(NSString *)key;
- (NSString*)stringForKey:(id)key;
- (NSNumber*)numberForKey:(id)key;
- (NSDecimalNumber *)decimalNumberForKey:(id)key;
- (NSArray*)arrayForKey:(id)key;
- (NSDictionary*)dictionaryForKey:(id)key;
- (NSInteger)integerForKey:(id)key;
- (NSUInteger)unsignedIntegerForKey:(id)key;
- (BOOL)boolForKey:(id)key;
- (int16_t)int16ForKey:(id)key;
- (int32_t)int32ForKey:(id)key;
- (int64_t)int64ForKey:(id)key;
- (char)charForKey:(id)key;
- (short)shortForKey:(id)key;
- (float)floatForKey:(id)key;
- (double)doubleForKey:(id)key;
- (long long)longLongForKey:(id)key;
- (unsigned long long)unsignedLongLongForKey:(id)key;
- (NSDate *)dateForKey:(id)key dateFormat:(NSString *)dateFormat;

//CG
- (CGFloat)CGFloatForKey:(id)key;
- (CGPoint)pointForKey:(id)key;
- (CGSize)sizeForKey:(id)key;
- (CGRect)rectForKey:(id)key;


@end


@interface NSMutableDictionary(Extended)

/** 同上 */
+ (nullable NSMutableDictionary *)dictionaryWithPlistData:(NSData *)plist;
+ (nullable NSMutableDictionary *)dictionaryWithPlistString:(NSString *)plist;


/**
 删除并返回与给定键相关联的值.
 
 @param aKey 返回和删除相应值的键.
 @return 与aKey关联的值,如果没有值与aKey相关联,则为nil.
 */
- (nullable id)popObjectForKey:(id)aKey;

/**
 返回包含键条目的新字典,并删除这些来自接收者的条目.如果键为空或无,则返回空字典.
 
 @param keys The keys.
 @return 键的条目.
 */
- (NSDictionary *)popEntriesForKeys:(NSArray *)keys;


- (void)setObj:(id)i forKey:(NSString*)key;
- (void)setString:(NSString*)i forKey:(NSString*)key;
- (void)setBool:(BOOL)i forKey:(NSString*)key;
- (void)setInt:(int)i forKey:(NSString*)key;
- (void)setInteger:(NSInteger)i forKey:(NSString*)key;
- (void)setUnsignedInteger:(NSUInteger)i forKey:(NSString*)key;
- (void)setCGFloat:(CGFloat)f forKey:(NSString*)key;
- (void)setChar:(char)c forKey:(NSString*)key;
- (void)setFloat:(float)i forKey:(NSString*)key;
- (void)setDouble:(double)i forKey:(NSString*)key;
- (void)setLongLong:(long long)i forKey:(NSString*)key;
- (void)setPoint:(CGPoint)o forKey:(NSString*)key;
- (void)setSize:(CGSize)o forKey:(NSString*)key;
- (void)setRect:(CGRect)o forKey:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
