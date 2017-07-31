//
//  NSParagraphStyle+CSText.h
//  CSCategory
//
//  Created by mac on 2017/7/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


/**
 提供'NSParagraphStyle'与CoreText一起使用的扩展
 */
@interface NSParagraphStyle (CSText)

/**
 从CoreText Style创建一个新的NSParagraphStyle对象.
 
 @param CTStyle  CoreText段落样式.
 @return NSParagraphStyle
 */
+ (nullable NSParagraphStyle *)styleWithCTStyle:(CTParagraphStyleRef)CTStyle;

/**
 创建并返回CoreText段落样式.(使用后需要调用CFRelease())
 */
- (nullable CTParagraphStyleRef)CTStyle CF_RETURNS_RETAINED;

@end
NS_ASSUME_NONNULL_END

