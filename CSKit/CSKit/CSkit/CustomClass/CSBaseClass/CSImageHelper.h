//
//  CSImageHelper.h
//  CSKit
//
//  Created by mac on 2017/8/3.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CSKit.h"

/**
 统一处理图片缓存
 */
@interface CSImageHelper : NSObject

/// 图片资源 bundle
+ (NSBundle *)bundle;

/// 图片 cache
+ (CSMemoryCache *)imageCache;

/// 从微博 bundle 里获取图片 (有缓存)
+ (UIImage *)imageNamed:(NSString *)name;

/// 从path创建图片 (有缓存)
+ (UIImage *)imageWithPath:(NSString *)path;

/// 圆角头像的 manager
+ (CSWebImageManager *)avatarImageManager;

@end
