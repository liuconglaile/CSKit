//
//  CSTextRunDelegate.h
//  CSCategory
//
//  Created by mac on 2017/7/26.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

/**
 CTRunDelegateRef的包装器.
 
 示例代码:
 
     CSTextRunDelegate *delegate = [CSTextRunDelegate new];
     delegate.ascent = 20;
     delegate.descent = 4;
     delegate.width = 20;
     CTRunDelegateRef ctRunDelegate = delegate.CTRunDelegate;
     if (ctRunDelegate) {
         /// 添加属性串
         CFRelease(ctRunDelegate);
     }
 
 */

@interface CSTextRunDelegate : NSObject<NSCopying, NSCoding>


/**
 创建并返回CTRunDelegate.
 
 @discussion 使用后需要调用CFRelease().
 CTRunDelegateRef对此CSTextRunDelegate对象有很强的引用.
 在CoreText中,使用CTRunDelegateGetRefCon()获取此CSTextRunDelegate对象.
 
 @return CTRunDelegate对象.
 */
- (nullable CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED;

/**
 有关运行代理的其他信息.
 */
@property (nullable, nonatomic, strong) NSDictionary *userInfo;

/**
 运行中字形上升的值.
 */
@property (nonatomic) CGFloat ascent;

/**
 运行中字形下降的值.
 */
@property (nonatomic) CGFloat descent;

/**
 运行中字形的排版宽度.
 */
@property (nonatomic) CGFloat width;


@end
NS_ASSUME_NONNULL_END
