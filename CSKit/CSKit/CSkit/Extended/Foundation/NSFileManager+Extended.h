//
//  NSFileManager+Extended.h
//  CSKit
//
//  Created by mac on 2017/10/11.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Extended)

/** 获取文档目录的URL */
+ (NSURL *)documentsURL;
/** 获取文档目录的路径 */
+ (NSString *)documentsPath;
/** 获取Library目录的URL */
+ (NSURL *)libraryURL;
/** 获取Library目录的路径 */
+ (NSString *)libraryPath;
/**获取缓存目录的URL*/
+ (NSURL *)cachesURL;
/**获取缓存目录的路径*/
+ (NSString *)cachesPath;
/**增加了一个特殊的文件系统标志一个文件,以避免iCloud云备份它*/
+ (BOOL)addSkipBackupAttributeToFile:(NSString *)path;
/** 获取可用磁盘空间 */
+ (double)availableDiskSpace;

@end
