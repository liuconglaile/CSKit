//
//  NSString+Encrypt.m
//  CSKit
//
//  Created by mac on 2017/10/18.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "NSString+Encrypt.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#include <zlib.h>


#import "NSData+Extended.h"
#import "GTMBase64.h"

@implementation NSString (Encrypt)

- (NSString *)md2String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md2String];
}
- (NSString *)md4String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md4String];
}
- (NSString *)md5String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5String];
}
- (NSString *)sha1String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha1String];
}
- (NSString *)sha224String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha224String];
}
- (NSString *)sha256String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha256String];
}
- (NSString *)sha384String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha384String];
}
- (NSString *)sha512String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha512String];
}
- (NSString *)crc32String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] crc32String];
}
- (NSString *)hmacMD5StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacMD5StringWithKey:key];
}
- (NSString *)hmacSHA1StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacSHA1StringWithKey:key];
}
- (NSString *)hmacSHA224StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacSHA224StringWithKey:key];
}
- (NSString *)hmacSHA256StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacSHA256StringWithKey:key];
}
- (NSString *)hmacSHA384StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacSHA384StringWithKey:key];
}
- (NSString *)hmacSHA512StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacSHA512StringWithKey:key];
}

- (NSString*)encryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv {
    NSData *encrypted = [[self dataUsingEncoding:NSUTF8StringEncoding] encryptedWith3DESUsingKey:key andIV:iv];
    NSString *encryptedString = [encrypted base64EncodedString];
    
    return encryptedString;
}

- (NSString*)decryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv {
    NSData *decrypted = [[NSData dataWithBase64EncodedString:self] decryptedWith3DESUsingKey:key andIV:iv];
    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}




// 32位MD5加密方式
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString isUppercase:(BOOL)isUppercase{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    if (isUppercase) {
        return   [result uppercaseString];
    }else{
        return result;
    }
    
}

// base64加密和解密
+ (NSString*)encodeBase64String:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

+ (NSString*)decodeBase64String:(NSString * )input {
    
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

+ (NSString*)encodeBase64Data:(NSData *)data {
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

+ (NSString*)decodeBase64Data:(NSData *)data {
    data = [GTMBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}


/**
 AES128加密数据
 
 @param plainText 明文
 @param aKey 加密 key, 就是密码
 @param aIv 补码(偏移量)
 @return 加密后的字符串
 */
+(NSString *)AES128Encrypt:(NSString *)plainText AndKey:(NSString*)aKey AndIv:(NSString*)aIv{
    char keyPtr[kCCKeySizeAES128+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [aKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [aIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    
    int diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    int newSize = 0;
    
    if(diff > 0)
    {
        
        newSize = (int)dataLength + diff; // 这里把NSUInteger 强转为 int 类型
    }
    
    char dataPtr[newSize];
    memcpy(dataPtr, [data bytes], [data length]);
    for(int i = 0; i < diff; i++)
    {
        dataPtr[i + dataLength] = 0x00;
    }
    
    size_t bufferSize = newSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          0x0000,               //No padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          ivPtr,
                                          dataPtr,
                                          sizeof(dataPtr),
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [GTMBase64 stringByEncodingData:resultData];
    }
    free(buffer);
    return nil;
}

/**
 AES128解密数据
 
 @param encryptText 密文
 @param aKey 加密 key, 就是密码
 @param aIv 补码(偏移量)
 @return 解密后的字符串
 */
+(NSString *)AES128Decrypt:(NSString *)encryptText AndKey:(NSString*)aKey AndIv:(NSString*)aIv{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [aKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [aIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData *data = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          0x0000,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}

#define gkey            @"1234567812345678" //自行修改
#define gIv             @"1234567812345678" //自行修改


+(NSString *)AES128Encrypt:(NSString *)plainText
{
    return [self AES128Encrypt:plainText AndKey:gkey AndIv:gIv];
}

+(NSString *)AES128Decrypt:(NSString *)encryptText
{
    return [self AES128Decrypt:encryptText AndKey:gkey AndIv:gIv];
}

- (NSString *)base64EncodedString {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}
+ (NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString {
    NSData *data = [NSData dataWithBase64EncodedString:base64EncodedString];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


@end




