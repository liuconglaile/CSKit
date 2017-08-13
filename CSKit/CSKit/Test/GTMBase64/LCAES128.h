//
//  LCAES128.h
//  各种加密手段
//
//  Created by mac on 16/4/19.
//  Copyright © 2016年 zhangguobing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCAES128 : NSObject

/**
 *  32位MD5加密方式(长度是32字节中间16位字节和16加密的结果相同)
 *  经典的哈希算法不可逆
 *  @param NSString 加密的明文
 *  @param isUppercase 是否大写
 *  @return 加密后的密文
 */
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString isUppercase:(BOOL)isUppercase;

/**
 *  base64加密
 *
 *  @param input 明文（字符串类型）
 *
 *  @return 密文
 */
+ (NSString*)encodeBase64String:(NSString *)input;
/**
 *  base64解密
 *
 *  @param input 密文
 *
 *  @return 明文
 */
+ (NSString*)decodeBase64String:(NSString *)input;
/**
 *  base64加密
 *
 *  @param data 明文（二进制）
 *
 *  @return 密文（字符串）
 */
+ (NSString*)encodeBase64Data:(NSData *)data;
/**
 *  base64解密
 *
 *  @param data 密文（二进制）
 *
 *  @return 明文（字符串）
 */

+ (NSString*)decodeBase64Data:(NSData *)data;


+ (NSString*) AES128Encrypt:(NSString *)plainText;

+ (NSString*) AES128Decrypt:(NSString *)encryptText;

@end
