//
//  CSFileHash.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/**
 文件哈希算法类型
 */
typedef NS_OPTIONS (NSUInteger, CSFileHashType) {
    CSFileHashTypeMD2     = 1 << 0, ///< MD2 hash
    CSFileHashTypeMD4     = 1 << 1, ///< MD4 hash
    CSFileHashTypeMD5     = 1 << 2, ///< MD5 hash
    CSFileHashTypeSHA1    = 1 << 3, ///< SHA1 hash
    CSFileHashTypeSHA224  = 1 << 4, ///< SHA224 hash
    CSFileHashTypeSHA256  = 1 << 5, ///< SHA256 hash
    CSFileHashTypeSHA384  = 1 << 6, ///< SHA384 hash
    CSFileHashTypeSHA512  = 1 << 7, ///< SHA512 hash
    CSFileHashTypeCRC32   = 1 << 8, ///< crc32 checksum
    CSFileHashTypeAdler32 = 1 << 9, ///< adler32 checksum
};


/**
 用于计算具有高性能和低内存使用的文件的散列的实用程序.
 见'CSFileHashType'对于所有支持的哈希值(校验)类型.
 
 示例代码:
 
 CSFileHash *hash = [CSFileHash hashForFile:@"/tmp/Xcode6.dmg" types:CSFileHashTypeMD5 | CSFileHashTypeSHA1];
 NSLog(@"md5:%@ sha1:%@", hash.md5String, hash.sha1String);
 
 */
@interface CSFileHash : NSObject


/**
 开始计算文件哈希并返回结果 (阻塞线程)

 @param filePath 要访问的文件的路径
 @param types 文件哈希算法类型
 @return 文件Hash结果,或发生错误时为nil
 */
+ (nullable CSFileHash *)hashForFile:(NSString *)filePath types:(CSFileHashType)types;

/**
 开始计算文件哈希并返回结果(阻塞线程)

 @param filePath 文件路径
 @param types 哈希算法类型
 @param block 计算过程中调用块(文件总大小,已处理文件大小,开关)
 @return 文件Hash结果,或发生错误时为nil
 */
+ (nullable CSFileHash *)hashForFile:(NSString *)filePath
                               types:(CSFileHashType)types
                          usingBlock:(nullable void (^)(UInt64 totalSize, UInt64 processedSize, BOOL *stop))block;


@property (nonatomic, readonly) CSFileHashType types; ///< 哈希类型

@property (nullable, nonatomic, strong, readonly) NSString *md2String; ///< md2 小写哈希字符串
@property (nullable, nonatomic, strong, readonly) NSString *md4String; ///< md4 小写哈希字符串
@property (nullable, nonatomic, strong, readonly) NSString *md5String; ///< md5 小写哈希字符串
@property (nullable, nonatomic, strong, readonly) NSString *sha1String; ///< sha1 小写哈希字符串
@property (nullable, nonatomic, strong, readonly) NSString *sha224String; ///< sha224 小写哈希字符串
@property (nullable, nonatomic, strong, readonly) NSString *sha256String; ///< sha256 小写哈希字符串
@property (nullable, nonatomic, strong, readonly) NSString *sha384String; ///< sha384 小写哈希字符串
@property (nullable, nonatomic, strong, readonly) NSString *sha512String; ///< sha512 小写哈希字符串
@property (nullable, nonatomic, strong, readonly) NSString *crc32String; ///< crc32 小写效验字符串
@property (nullable, nonatomic, strong, readonly) NSString *adler32String; ///< adler32 小写效验字符串

@property (nullable, nonatomic, strong, readonly) NSData *md2Data; ///< md2 hash
@property (nullable, nonatomic, strong, readonly) NSData *md4Data; ///< md4 hash
@property (nullable, nonatomic, strong, readonly) NSData *md5Data; ///< md5 hash
@property (nullable, nonatomic, strong, readonly) NSData *sha1Data; ///< sha1 hash
@property (nullable, nonatomic, strong, readonly) NSData *sha224Data; ///< sha224 hash
@property (nullable, nonatomic, strong, readonly) NSData *sha256Data; ///< sha256 hash
@property (nullable, nonatomic, strong, readonly) NSData *sha384Data; ///< sha384 hash
@property (nullable, nonatomic, strong, readonly) NSData *sha512Data; ///< sha512 hash
@property (nonatomic, readonly) uint32_t crc32; ///< crc32 checksum
@property (nonatomic, readonly) uint32_t adler32; ///< adler32 checksum

@end
NS_ASSUME_NONNULL_END


