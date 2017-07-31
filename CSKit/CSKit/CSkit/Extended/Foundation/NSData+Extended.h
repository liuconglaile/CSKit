//
//  NSData+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/14.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSData (Extended)

#pragma mark - Hash
///=============================================================================
/// @name 哈希值
///=============================================================================

/** 返回一个小写的NSString为md2哈希 */
- (NSString *)md2String;

/** 返回md2哈希的NSData */
- (NSData *)md2Data;

/** 返回md4哈希的小写NSString */
- (NSString *)md4String;

/** 返回md4哈希的NSData */
- (NSData *)md4Data;

/** 为md5哈希返回小写的NSString */
- (NSString *)md5String;

/** 返回md5哈希的NSData */
- (NSData *)md5Data;

/** 为sha1哈希返回小写的NSString */
- (NSString *)sha1String;

/** 返回sha1哈希的NSData */
- (NSData *)sha1Data;

/** 为sha224哈希返回小写的NSString */
- (NSString *)sha224String;

/** 返回sha224哈希的NSData */
- (NSData *)sha224Data;

/** 返回sha256哈希的小写NSString */
- (NSString *)sha256String;

/** 返回sha256哈希的NSData */
- (NSData *)sha256Data;

/** 为sha384哈希返回小写的NSString */
- (NSString *)sha384String;

/** 返回一个用于sha384哈希的NSData */
- (NSData *)sha384Data;

/** 返回sha512哈希的小写NSString */
- (NSString *)sha512String;

/** 返回一个用于sha512哈希的NSData */
- (NSData *)sha512Data;

/** 使用带密钥的算法md5返回hmac的小写NSString */
- (NSString *)hmacMD5StringWithKey:(NSString *)key;

/** 使用关键字的算法md5返回hmac的NSData */
- (NSData *)hmacMD5DataWithKey:(NSData *)key;

/** 使用关键字的算法sha1返回hmac的小写NSString */
- (NSString *)hmacSHA1StringWithKey:(NSString *)key;

/** 使用关键字的算法sha1返回hmac的NSData */
- (NSData *)hmacSHA1DataWithKey:(NSData *)key;

/** 使用关键字的算法sha224返回hmac的小写NSString */
- (NSString *)hmacSHA224StringWithKey:(NSString *)key;

/** 使用关键字的算法sha224返回hmac的NSData */
- (NSData *)hmacSHA224DataWithKey:(NSData *)key;

/** 使用关键字的算法sha256返回hmac的小写NSString */
- (NSString *)hmacSHA256StringWithKey:(NSString *)key;

/** 使用关键字的算法sha256返回hmac的NSData */
- (NSData *)hmacSHA256DataWithKey:(NSData *)key;

/** 使用关键字的算法sha384返回hmac的小写NSString */
- (NSString *)hmacSHA384StringWithKey:(NSString *)key;

/** 使用关键字的算法sha384返回hmac的NSData */
- (NSData *)hmacSHA384DataWithKey:(NSData *)key;

/** 使用关键字的算法sha512返回hmac的小写NSString */
- (NSString *)hmacSHA512StringWithKey:(NSString *)key;

/** 使用关键字的算法sha512返回hmac的NSData */
- (NSData *)hmacSHA512DataWithKey:(NSData *)key;

/** 返回CRC32哈希的小写NSString */
- (NSString *)crc32String;

/**
 返回 CRC32哈希值.
 */
- (uint32_t)crc32;


#pragma mark - Encrypt and Decrypt
///=============================================================================
/// @name 加密和解密
///=============================================================================

/** 返回使用AES加密的NSData */
- (nullable NSData *)aes256EncryptWithKey:(NSData *)key iv:(nullable NSData *)iv;

/** 返回使用AES解密的NSData */
- (nullable NSData *)aes256DecryptWithkey:(NSData *)key iv:(nullable NSData *)iv;

/** 利用3DES加密数据 */
- (NSData *)encryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv;

/** 利用3DES解密数据 */
- (NSData *)decryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv;


#pragma mark - Encode and decode
///=============================================================================
/// @name 编码和解码
///=============================================================================

/** 返回以UTF8解码的字符串 */
- (nullable NSString *)utf8String;

/** 返回HEX中的大写NSString */
- (nullable NSString *)hexString;

/** 从十六进制字符串返回一个NSDatag */
+ (nullable NSData *)dataWithHexString:(NSString *)hexString;

/** 返回一个用于base64编码的NSString */
- (nullable NSString *)base64EncodedString;

/** 从base64编码的字符串返回一个NSData */
+ (nullable NSData *)dataWithBase64EncodedString:(NSString *)base64EncodedString;

/** 返回一个NSDictionary或NSArray来解码自己.如果发生错误,返回nil */
- (nullable id)jsonValueDecoded;


#pragma mark - Inflate and deflate
///=============================================================================
/// @name 压缩与解压
///=============================================================================

/** 从gzip数据解压缩数据 */
- (nullable NSData *)gzipInflate;

/** 将数据压缩为默认压缩级别的gzip */
- (nullable NSData *)gzipDeflate;

/** 从zlib压缩数据中解压缩数据 */
- (nullable NSData *)zlibInflate;

/** 压缩数据到zlib压缩的默认压缩级别 */
- (nullable NSData *)zlibDeflate;


#pragma mark - Others
///=============================================================================
/// @name 其它
///=============================================================================

/** 从 main bundle 创建数据 (比如 [UIImage imageNamed:])  */
+ (nullable NSData *)dataNamed:(NSString *)name;


/** 将APNS NSData类型token 格式化成字符串 */
- (NSString *)APNSToken;

/** 将URL作为key保存到磁盘里缓存起来 */
- (void)saveDataCacheWithIdentifier:(NSString *)identifier;

/** 取出缓存data */
+ (NSData *)getDataCacheWithIdentifier:(NSString *)identifier;


/** 格式为wav数据 原始音频数据 */
- (NSData *)wavDataWithPCMFormat:(AudioStreamBasicDescription)PCMFormat;


@end

NS_ASSUME_NONNULL_END


