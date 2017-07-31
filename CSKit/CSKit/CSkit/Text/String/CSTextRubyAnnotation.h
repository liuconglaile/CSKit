//
//  CSTextRubyAnnotation.h
//  CSCategory
//
//  Created by mac on 2017/7/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/**
 CTRubyAnnotationRef包装器.
 
 Example:
 
     CSTextRubyAnnotation *ruby = [CSTextRubyAnnotation new];
     ruby.textBefore = @"zhù yīn";
     CTRubyAnnotationRef ctRuby = ruby.CTRubyAnnotation;
     if (ctRuby) {
         /// 添加属性串
         CFRelease(ctRuby);
     }
 
 */
@interface CSTextRubyAnnotation : NSObject

/// 指定如何将ruby文本和基本文本相对于彼此对齐.
@property (nonatomic) CTRubyAlignment alignment;

/// 指定红宝石文本如何突出相邻字符.
@property (nonatomic) CTRubyOverhang overhang;

/// 指定注释文本的大小为基本文本大小的百分比.
@property (nonatomic) CGFloat sizeFactor;

/**
 红宝石文本位于基本文本之前; 
 即在水平文本之上和垂直文本的右侧。
 */
@property (nullable, nonatomic, copy) NSString *textBefore;

/**
 红宝石文本位于基本文本之后;
 即水平文字下方,垂直文字左侧.
 */
@property (nullable, nonatomic, copy) NSString *textAfter;

/**
 红宝石文本位于基本文本的右侧,无论是水平还是垂直.
 这是Bopomofo注释附加在台湾的中文文本的方式.
 */
@property (nullable, nonatomic, copy) NSString *textInterCharacter;

/// 红宝石文字遵循基本文本,没有特殊的造型.
@property (nullable, nonatomic, copy) NSString *textInline;

/**
 从CTRuby对象创建一个ruby对象

 @param ctRuby CTRuby对象
 @return Ruby对象,发送错误则返回 nil
 */
+ (instancetype)rubyWithCTRubyRef:(CTRubyAnnotationRef)ctRuby NS_AVAILABLE_IOS(8_0);

/**
 从实例创建一个CTRuby对象

 @return 新的CTRuby对象,或发生错误时为NULL.返回值应在使用后释放
 */
- (nullable CTRubyAnnotationRef)CTRubyAnnotation CF_RETURNS_RETAINED NS_AVAILABLE_IOS(8_0);


@end
NS_ASSUME_NONNULL_END

