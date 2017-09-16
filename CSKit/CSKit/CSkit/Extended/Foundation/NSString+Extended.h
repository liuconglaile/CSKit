//
//  NSString+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, NSStringScoreOption) {
    NSStringScoreOptionNone = 1 << 0,
    NSStringScoreOptionFavorSmallerWords = 1 << 1,
    NSStringScoreOptionReducedLongStringPenalty = 1 << 2
};

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extended)

#pragma mark - Hash
///=============================================================================
/// @name 哈希值
///=============================================================================

/** 返回md2哈希的小写NSString. */
- (nullable NSString *)md2String;

/** 返回md4哈希的小写NSString. */
- (nullable NSString *)md4String;

/** 返回md5哈希的小写NSString. */
- (nullable NSString *)md5String;

/** 返回sha1哈希的小写NSString. */
- (nullable NSString *)sha1String;

/** 返回sha224哈希的小写NSString. */
- (nullable NSString *)sha224String;

/** 返回sha256哈希的小写NSString. */
- (nullable NSString *)sha256String;

/** 返回sha384哈希的小写NSString. */
- (nullable NSString *)sha384String;

/** 返回sha512哈希的小写NSString. */
- (nullable NSString *)sha512String;

/** 基于密钥返回md5哈希的小写NSString. */
- (nullable NSString *)hmacMD5StringWithKey:(NSString *)key;

/** 基于密钥返回sha1哈希的小写NSString. */
- (nullable NSString *)hmacSHA1StringWithKey:(NSString *)key;

/** 基于密钥返回sha224哈希的小写NSString. */
- (nullable NSString *)hmacSHA224StringWithKey:(NSString *)key;

/** 基于密钥返回sha256哈希的小写NSString. */
- (nullable NSString *)hmacSHA256StringWithKey:(NSString *)key;

/** 基于密钥返回sha384哈希的小写NSString.  */
- (nullable NSString *)hmacSHA384StringWithKey:(NSString *)key;

/** 基于密钥返回sha512哈希的小写NSString. */
- (nullable NSString *)hmacSHA512StringWithKey:(NSString *)key;

/** 返回crc32哈希的小写NSString */
- (nullable NSString *)crc32String;

- (nullable NSString*)encryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv;
- (nullable NSString*)decryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv;


/**
 32位MD5加密方式(长度是32字节中间16位字节和16加密的结果相同)
 经典的哈希算法不可逆
 
 @param srcString 加密的明文
 @param isUppercase 是否大写
 @return 加密后的密文
 */
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString isUppercase:(BOOL)isUppercase;

/**
 base64加密
 
 @param input 明文（字符串类型）
 @return 密文
 */
+ (NSString*)encodeBase64String:(NSString *)input;
/**
 base64解密
 
 @param input 密文
 @return 明文
 */
+ (NSString*)decodeBase64String:(NSString *)input;

/**
 base64加密

 @param data 明文（二进制）
 @return 密文（字符串）
 */
+ (NSString*)encodeBase64Data:(NSData *)data;

/**
 base64解密

 @param data 密文（二进制
 @return 明文（字符串）
 */
+ (NSString*)decodeBase64Data:(NSData *)data;


/**
 AES128加密数据
 
 @param plainText 明文
 @param aKey 加密 key, 就是密码
 @param aIv 补码(偏移量)
 @return 加密后的字符串
 */
+ (NSString *)AES128Encrypt:(NSString *)plainText AndKey:(NSString*)aKey AndIv:(NSString*)aIv;

/**
 AES128解密数据
 
 @param encryptText 密文
 @param aKey 加密 key, 就是密码
 @param aIv 补码(偏移量)
 @return 解密后的字符串
 */
+ (NSString *)AES128Decrypt:(NSString *)encryptText AndKey:(NSString*)aKey AndIv:(NSString*)aIv;

+ (NSString*) AES128Encrypt:(NSString *)plainText;
+ (NSString*) AES128Decrypt:(NSString *)encryptText;


#pragma mark - 拼音处理
///=============================================================================
/// @name 拼音处理
///=============================================================================
- (NSString*)pinyinWithPhoneticSymbol;
- (NSString*)pinyin;
- (NSArray*)pinyinArray;
- (NSString*)pinyinWithoutBlank;
- (NSArray*)pinyinInitialsArray;
- (NSString*)pinyinInitialsString;

#pragma mark - 编码和解码
///=============================================================================
/// @name 编码和解码
///=============================================================================

/** 返回base64编码的NSString. */
- (nullable NSString *)base64EncodedString;

/** 返回base64解码的NSString */
+ (nullable NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString;

/** URL编码为UTF-8的字符串. */
- (NSString *)stringByURLEncode;

/** URL解码为UTF-8的字符串 */
- (NSString *)stringByURLDecode;

/** URLString解码 */
+(NSString *)decodeURLString:(NSString *)string;

/** 将常见的 HTML 符号转换为实体 */
- (NSString *)stringByEscapingHTML;

/** JSON字符串转成NSDictionary */
- (NSDictionary *)dictionaryValue;

/** 判断URL中是否包含中文 */
- (BOOL)isContainChinese;
/** 是否包含空格 */
- (BOOL)isContainBlank;

/** Unicode编码的字符串转成NSString */
- (NSString *)makeUnicodeToString;





#pragma mark - 绘制相关
///=============================================================================
/// @name 绘制相关
///=============================================================================

/** 使用指定的约束渲染字符串,并返回该字符串的size */
- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;


/** 基于指定的约束,并返回单行状态下的字符串宽度 */
- (CGFloat)widthForFont:(UIFont *)font;

/** 基于指定的约束,并返回字符串渲染所需高度 */
- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width;

/** 字符串分页 */
- (NSArray *)getPagesOfString:(NSString *)cache
                     withFont:(UIFont*)font
                       inRect:(CGRect)r;



#pragma mark - Regular Expression
///=============================================================================
/// @name 正则表达式
///=============================================================================


/** 是否匹配正则表达式 */
- (BOOL)matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options;


/** 匹配正则表达式,并使用匹配中的每个对象执行给定的块 */
- (void)enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block;


/** 返回包含匹配与模板字符串替换正则表达式的新字符串 */
- (NSString *)stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                          withString:(NSString *)replacement;


#pragma mark - NSNumber Compatible
///=============================================================================
/// @name NSNumber 兼容
///=============================================================================

// 现在可以使用NSString作为NSNumber.
@property (readonly) char charValue;
@property (readonly) unsigned char unsignedCharValue;
@property (readonly) short shortValue;
@property (readonly) unsigned short unsignedShortValue;
@property (readonly) unsigned int unsignedIntValue;
@property (readonly) long longValue;
@property (readonly) unsigned long unsignedLongValue;
@property (readonly) unsigned long long unsignedLongLongValue;
@property (readonly) NSUInteger unsignedIntegerValue;


#pragma mark - Utilities
///=============================================================================
/// @name 公共方法
///=============================================================================

/** 生成 UUID NSString e.g. "D1178E50-2A4D-4F1F-9BD3-F6AAB00E06B1" */
+ (NSString *)stringWithUUID;


/** 获取一个14位的毫秒时间戳 */
+ (NSString *)UUIDTimestamp;

/** 返回包含给定UTF32Char中的字符的字符串 */
+ (nullable NSString *)stringWithUTF32Char:(UTF32Char)char32;

/** 返回一个包含给定UTF32Char数组中字符的字符串 */
+ (nullable NSString *)stringWithUTF32Chars:(const UTF32Char *)char32 length:(NSUInteger)length;

/** 枚举字符串指定范围内的unicode字符(UTF-32) */
- (void)enumerateUTF32CharInRange:(NSRange)range usingBlock:(void (^)(UTF32Char char32, NSRange range, BOOL *stop))block;

/** 修剪头部和尾部的空白字符(空格和换行符) */
- (NSString *)stringByTrim;

/** 将缩放修饰符添加到文件名(不带拓展名),From @"name" to @"name@2x" */
- (NSString *)stringByAppendingNameScale:(CGFloat)scale;

/** 将缩放修饰符添加到文件路径(具有路径扩展名),From @"name.png" to @"name@2x.png" */
- (NSString *)stringByAppendingPathScale:(CGFloat)scale;

/** 返回路径比例 */
- (CGFloat)pathScale;

/** 判断字符串是否非 nil,@"",@"  ",@"\n" 将返回NO;否则返回YES.*/
- (BOOL)isNotBlank;

/** 如果目标字符串包含在接收器中,则返回YES */
- (BOOL)containsString:(NSString *)string;

/** 如果目标字符集包含在接收器内,则返回YES */
- (BOOL)containsCharacterSet:(NSCharacterSet *)set;

/** 尝试解析这个字符串并返回一个'NSNumber' */
- (nullable NSNumber *)numberValue;

/** 使用UTF-8编码返回NSData. */
- (nullable NSData *)dataValue;

/** 返回 NSMakeRange(0,self.length). */
- (NSRange)rangeOfAll;

/** 返回从接收器解码的 NSDictionary / NSArray. 如果发生错误,返回nil */
- (nullable id)jsonValueDecoded;

/** 从 main bundle的文件创建一个字符串(类似于[UIImage imageNamed:]) */
+ (nullable NSString *)stringNamed:(NSString *)name;


/** 字符串规范化空格 */
- (instancetype)stringNormalizingWhitespace;

/** 获取字符数量 */
- (int)wordsCount;

/** 反转序字符串 */
+ (NSString *)reverseString:(NSString *)strSrc;

/** 清除HTML标签 */
- (NSString *)stringByStrippingHTML;

/** 清除js脚本标签 */
- (NSString *)stringByRemovingScriptsAndStrippingHTML;

/** 去除空格 */
- (NSString *)trimmingWhitespace;

/** 去除字符串与空行 */
- (NSString *)trimmingWhitespaceAndNewlines;

/** 过滤非法字符 关键字 []{}（#%-*+=_）\\|~(＜＞$%^&*)_+ */
+(NSString *)filterString:(NSString *)string target:(NSString *)target;

/** 过滤非法字符 关键字 []{}（#%-*+=_）\\|~(＜＞$%^&*)_+ */
- (NSString *)filter:(NSString *)target;


- (CGFloat)scoreAgainst:(NSString *)otherString;
- (CGFloat)scoreAgainst:(NSString *)otherString fuzziness:(nullable NSNumber *)fuzziness;
- (CGFloat)scoreAgainst:(NSString *)otherString fuzziness:(nullable NSNumber *)fuzziness options:(NSStringScoreOption)options;



/** 根据文件URL 返回对应的MIMEType */
- (NSString *)MIMEType;

/** 根据文件URL后缀 返回对应的MIMEType */
+ (NSString *)MIMETypeForExtension:(NSString *)extension;

/** 常见MIME集合 */
+ (NSDictionary *)MIMEDict;


@end

NS_ASSUME_NONNULL_END

