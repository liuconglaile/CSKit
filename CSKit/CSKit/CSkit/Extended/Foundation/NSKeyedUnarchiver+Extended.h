//
//  NSKeyedUnarchiver+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedUnarchiver (Extended)


/**
 与 unarchiveObjectWithData: 相同, 除了它通过引用返回异常.

 @param data 数据需要取消存档
 @param exception 指针,无异常是返回 nil,如果发生异常表示指针不为NULL,指向NSException
 @return NSKeyedUnarchiver
 */
+ (nullable id)unarchiveObjectWithData:(NSData *)data
                             exception:(NSException *_Nullable *_Nullable)exception;

/**
 与 unarchiveObjectWithFile:相同,除非返回异常.
 
 @param path       存档对象文件的路径.
 
 @param exception  指针,无异常是返回 nil,如果发生异常表示指针不为NULL,指向NSException.
 */
+ (nullable id)unarchiveObjectWithFile:(NSString *)path
                             exception:(NSException *_Nullable *_Nullable)exception;

@end

NS_ASSUME_NONNULL_END

