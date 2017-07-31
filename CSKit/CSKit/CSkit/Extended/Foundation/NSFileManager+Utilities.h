//
//  NSFileManager+Utilities.h
//  CSCategory
//
//  Created by mac on 17/5/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Utilities)

/**
 获取文档目录的URL.
 
 @return Documents directory URL.
 */
+ (NSURL *)documentsURL;

/**
 获取文档目录的路径.
 
 @return Documents directory path.
 */
+ (NSString *)documentsPath;

/**
 获取Library目录的URL.
 
 @return Library directory URL.
 */
+ (NSURL *)libraryURL;

/**
 获取Library目录的路径.
 
 @return Library directory path.
 */
+ (NSString *)libraryPath;

/**
 获取缓存目录的URL.
 
 @return Caches directory URL.
 */
+ (NSURL *)cachesURL;

/**
 获取缓存目录的路径.
 
 @return Caches directory path.
 */
+ (NSString *)cachesPath;

/**
 增加了一个特殊的文件系统标志一个文件，以避免iCloud云备份它.
 
 @param path 文件路径来设置的属性.
 */
+ (BOOL)addSkipBackupAttributeToFile:(NSString *)path;

/**
 获取可用磁盘空间.
 
 @return 在兆字节的可用磁盘空间量.
 */
+ (double)availableDiskSpace;

@end
