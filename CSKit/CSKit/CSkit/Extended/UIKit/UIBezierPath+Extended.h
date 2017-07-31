//
//  UIBezierPath+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (Extended)

/**
 创建并返回使用从指定字体生成的文本字形初始化的新UIBezierPath对象.
 
 @discussion 该方法不支持苹果表情符号.如果要获取表情符号图像,请尝试在'UIImage(Extended)'中的[UIImage imageWithEmoji:size:].
 
 @param text 文字生成字形路径.
 @param font 字体生成字形路径.
 @return 具有文本和字体的新路径对象,如果发生错误,则为nil.
 */
+ (nullable UIBezierPath *)bezierPathWithText:(NSString *)text font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
