//
//  NSBundle+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 提供'NSBundle'的拓展以获取 @2x or @3x...等资源
 
 例如: ico.png, ico@2x.png, ico@3x.png. 
 默认将返回:@"ico" ofType:@"png"
 在 iPhone6 将返回 "ico@2x.png"的路径.
 */
@interface NSBundle (Extended)

/**
 一组NSNumber对象,显示路径规模搜索的最佳顺序.
 e.g. iPhone3GS:@[@1,@2,@3] iPhone5:@[@2,@3,@1]  iPhone6 Plus:@[@3,@2,@1]
 */
+ (NSArray<NSNumber *> *)preferredScales;


/**
 返回由指定的资源文件标识的完整路径名名称和扩展名,并驻留在给定的捆绑包目录中.它首先搜索该文件与当前屏幕的比例(例如@2x),然后从较高的搜索扩展到较低的规模

 @param name 目录中包含的资源文件的名称由bundlePath指定
 @param ext 如果扩展名为空字符串或nil,则扩展名为假定不存在,并且该文件是遇到的第一个完全匹配名称的文件
 @param bundlePath 顶级bundle目录的路径.这必须是有效路径 例如,要指定Mac应用程序的捆绑包目录可能会指定路径/Applications/MyApp.app
 @return 资源文件的完整路径名,如果未找到资源,则返回 nil. 如果bundlePath指定的bundle未找到此方法也返回nil(参数不存在或不可读目录)
 */
+ (nullable NSString *)pathForScaledResource:(NSString *)name
                                      ofType:(nullable NSString *)ext
                                 inDirectory:(NSString *)bundlePath;


/**
 根据文件名&文件拓展名获取文件路径
 */
- (nullable NSString *)pathForScaledResource:(NSString *)name ofType:(nullable NSString *)ext;

- (nullable NSString *)pathForScaledResource:(NSString *)name
                                      ofType:(nullable NSString *)ext
                                 inDirectory:(nullable NSString *)subpath;

@end

NS_ASSUME_NONNULL_END
