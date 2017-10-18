//
//  NSString+Encrypt.h
//  CSKit
//
//  Created by mac on 2017/10/18.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Encrypt)

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


/** 返回base64编码的NSString. */
- (nullable NSString *)base64EncodedString;

/** 返回base64解码的NSString */
+ (nullable NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString;

@end


NS_ASSUME_NONNULL_END



