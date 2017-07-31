//
//  NSAttributedString+CSText.h
//  CSCategory
//
//  Created by mac on 2017/7/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

#if __has_include(<CSKit/CSKit.h>)
#import <CSKit/CSTextAttribute.h>
#import <CSKit/CSTextRubyAnnotation.h>
#else
#import "CSTextAttribute.h"
#import "CSTextRubyAnnotation.h"
#endif

NS_ASSUME_NONNULL_BEGIN



///MARK: ===================================================
///MARK: 以下设置大多基于 CoreText:3.2 UIKit:6.0 CSKit:6.0
///MARK: ===================================================




/**
 从属性字符串获取预定义的属性.
 包括在UIKit,CoreText和CSText中定义的所有属性
 */
@interface NSAttributedString (CSText)

/** 将字符串存档到数据.如果发生错误,返回nil */
- (nullable NSData *)archiveToData;


/**
 从数据中取消存档字符串
 
 @param data 归档的属性字符串数据
 @return 如果发生错误,返回nil
 */
+ (nullable instancetype)unarchiveFromData:(NSData *)data;



///MARK: ===================================================
///MARK: 检索富文本属性字符串的属性信息
///MARK: ===================================================

/** 返回第一个字符的属性 */
@property (nullable, nonatomic, copy, readonly) NSDictionary<NSString *, id> *attributes;

/**
 返回给定索引处字符的属性
 如果索引超出接收者字符的末尾,则引发'NSRangeException'
 
 @param index 用于返回属性的索引.该值必须位于接收器的边界内
 @return 索引处字符的属性
 */
- (nullable NSDictionary<NSString *, id> *)attributesAtIndex:(NSUInteger)index;

/**
 返回给定索引处的字符给定名称的属性值
 如果索引超出接收者字符的末尾,则引发'NSRangeException'
 
 @param attributeName 属性的名称
 @param index 用于返回属性的索引.该值必须位于接收器的边界内
 @return 名称为'attribute'的属性名为'attributeName'的值,如果没有此属性,则为nil.
 */
- (nullable id)attribute:(NSString *)attributeName atIndex:(NSUInteger)index;



///MARK: ===================================================
///MARK: 获取富文本属性字符串的属性
///MARK: ===================================================


/**
 文本的字体(只读)
 
 @discussion 默认是 Helvetica (Neue) 12.
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:3.2 UIKit:6.0 CSKit:6.0
 */
@property (nullable, nonatomic, strong, readonly) UIFont *font;
- (nullable UIFont *)fontAtIndex:(NSUInteger)index;

/**
 字距调整. (只读)
 
 @discussion
 默认是标准字距.字距属性指示以下字符应该从当前字符的字体以点为单位定义的默认偏移量移动多少点;
 一个正的肯恩指示一个偏移越远,一个负的凯恩表示一个更接近当前角色的移动.
 如果此属性不存在,将使用标准字距调整.
 如果此属性设置为0.0,则不会完成任何字距调整.
 
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:3.2 UIKit:6.0 CSKit:6.0
 */
@property (nullable, nonatomic, strong, readonly) NSNumber *kern;
- (nullable NSNumber *)kernAtIndex:(NSUInteger)index;

/**
 前景色. (只读)
 
 @discussion Default is Black.
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:3.2 UIKit:6.0 CSKit:6.0
 */
@property (nullable, nonatomic, strong, readonly) UIColor *color;
- (nullable UIColor *)colorAtIndex:(NSUInteger)index;

/**
 背景颜色. (只读)
 
 @discussion Default is nil (or no background).
 @discussion 获取此属性返回第一个字符的属性.
 @since UIKit:6.0
 */
@property (nullable, nonatomic, strong, readonly) UIColor *backgroundColor;
- (nullable UIColor *)backgroundColorAtIndex:(NSUInteger)index;

/**
 笔划宽度. (只读)
 
 @discussion
 默认值为0.0(无笔画).
 该属性被解释为字体大小的百分比,控制文本绘制模式：正值仅用笔画影响绘图;
 负值用于笔画和填充. 概要文本的典型值为3.0.
 
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:3.2  UIKit:6.0
 */
@property (nullable, nonatomic, strong, readonly) NSNumber *strokeWidth;
- (nullable NSNumber *)strokeWidthAtIndex:(NSUInteger)index;

/**
 笔画颜色. (只读)
 
 @discussion 默认为 nil (与前景色相同).
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:3.2  UIKit:6.0
 */
@property (nullable, nonatomic, strong, readonly) UIColor *strokeColor;
- (nullable UIColor *)strokeColorAtIndex:(NSUInteger)index;

/**
 文字阴影. (只读)
 
 @discussion 默认为 nil (no shadow).
 @discussion 获取此属性返回第一个字符的属性.
 @since UIKit:6.0  YYKit:6.0
 */
@property (nullable, nonatomic, strong, readonly) NSShadow *shadow;
- (nullable NSShadow *)shadowAtIndex:(NSUInteger)index;

/**
 删除线风格. (只读)
 
 @discussion 默认值为NSUnderlineStyleNone (no strikethrough).
 @discussion 获取此属性返回第一个字符的属性.
 @since UIKit:6.0
 */
@property (nonatomic, readonly) NSUnderlineStyle strikethroughStyle;
- (NSUnderlineStyle)strikethroughStyleAtIndex:(NSUInteger)index;

/**
 删除线颜色. (只读)
 
 @discussion 默认值为nil(与前景颜色相同).
 @discussion 获取此属性返回第一个字符的属性.
 @since UIKit:7.0
 */
@property (nullable, nonatomic, strong, readonly) UIColor *strikethroughColor;
- (nullable UIColor *)strikethroughColorAtIndex:(NSUInteger)index;

/**
 下划线风格. (只读)
 
 @discussion 默认值为NSUnderlineStyleNone (no underline).
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:3.2  UIKit:6.0
 */
@property (nonatomic, readonly) NSUnderlineStyle underlineStyle;
- (NSUnderlineStyle)underlineStyleAtIndex:(NSUInteger)index;

/**
 下划线颜色. (只读)
 
 @discussion 默认为 nil (与前景色相同).
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:3.2  UIKit:7.0
 */
@property (nullable, nonatomic, strong, readonly) UIColor *underlineColor;
- (nullable UIColor *)underlineColorAtIndex:(NSUInteger)index;

/**
 连字队形控制. (只读)
 
 @discussion
 默认值为int值1.连线属性确定显示字符串时应使用什么类型的连字.
 值为0表示只应使用对文本正确呈现至关重要的连字,1表示应使用标准连字,2表示应使用所有可用的连字.
 哪些连字是标准的取决于脚本和可能的字体.
 
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:3.2 UIKit:6.0 CSKit:6.0
 */
@property (nullable, nonatomic, strong, readonly) NSNumber *ligature;
- (nullable NSNumber *)ligatureAtIndex:(NSUInteger)index;

/**
 文字效果. (只读)
 
 @discussion 默认值为nil(无效果).当前唯一支持的值NSTextEffectLetterpressStyle.
 @discussion 获取此属性返回第一个字符的属性.
 @since UIKit:7.0
 */
@property (nullable, nonatomic, strong, readonly) NSString *textEffect;
- (nullable NSString *)textEffectAtIndex:(NSUInteger)index;

/**
 字形偏斜值. (只读)
 
 @discussion 默认为0 (没有偏斜).
 @discussion 获取此属性返回第一个字符的属性.
 @since UIKit:7.0
 */
@property (nullable, nonatomic, strong, readonly) NSNumber *obliqueness;
- (nullable NSNumber *)obliquenessAtIndex:(NSUInteger)index;

/**
 字形的扩展因子的日志....不太懂. (只读)
 
 @discussion 默认值为0(无扩展).
 @discussion 获取此属性返回第一个字符的属性.
 @since UIKit:7.0
 */
@property (nullable, nonatomic, strong, readonly) NSNumber *expansion;
- (nullable NSNumber *)expansionAtIndex:(NSUInteger)index;

/**
 角色偏离基线,以点为单位. (只读)
 
 @discussion 默认值为0.
 @discussion 获取此属性返回第一个字符的属性.
 @since UIKit:7.0
 */
@property (nullable, nonatomic, strong, readonly) NSNumber *baselineOffset;
- (nullable NSNumber *)baselineOffsetAtIndex:(NSUInteger)index;

/**
 雕文定向控制. (只读)
 
 @discussion 默认为NO.NO值表示要使用水平字形,YES表示要使用垂直字形.
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:4.3  YYKit:6.0
 */
@property (nonatomic, readonly) BOOL verticalGlyphForm;
- (BOOL)verticalGlyphFormAtIndex:(NSUInteger)index;

/**
 指定文本语言. (只读)
 
 @discussion
 值必须是包含区域设置标识符的NSString.
 默认设置为未设置. 当此属性设置为有效的标识符时,它将用于选择本地化字形(如果字体支持)和特定于区域设置的线路断开规则.
 
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:7.0  YYKit:7.0
 */
@property (nullable, nonatomic, strong, readonly) NSString *language;
- (nullable NSString *)languageAtIndex:(NSUInteger)index;

/**
 指定一个双向覆盖或嵌入. (只读)
 
 @discussion 请参阅NSWritingDirection和NSWritingDirectionAttributeName.
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:6.0  UIKit:7.0  YYKit:6.0
 */
@property (nullable, nonatomic, strong, readonly) NSArray<NSNumber *> *writingDirection;
- (nullable NSArray<NSNumber *> *)writingDirectionAtIndex:(NSUInteger)index;

/**
 一个NSParagraphStyle对象,用于指定线对齐,制表符,写入方向等. (只读)
 
 @discussion 默认值为nil ([NSParagraphStyle defaultParagraphStyle]).
 @discussion 获取此属性返回第一个字符的属性.
 @since CoreText:6.0  UIKit:6.0  YYKit:6.0
 */
@property (nullable, nonatomic, strong, readonly) NSParagraphStyle *paragraphStyle;
- (nullable NSParagraphStyle *)paragraphStyleAtIndex:(NSUInteger)index;






///MARK: ===================================================
///MARK: 获取富文本字符串段落属性
///MARK: ===================================================

/**
 文本对齐(NSParagraphStyle的包装器).只读
 
 根据段落中包含的第一个脚本的行扫描方向,自然文本对齐实现为左对齐或右对齐
 */
@property (nonatomic, readonly) NSTextAlignment alignment;
- (NSTextAlignment)alignmentAtIndex:(NSUInteger)index;

/**
 断开线的模式(NSParagraphStyle的包装器).只读
 */
@property (nonatomic, readonly) NSLineBreakMode lineBreakMode;
- (NSLineBreakMode)lineBreakModeAtIndex:(NSUInteger)index;

/**
 一行片段的底部与下一个片段的顶部之间的距离.(NSParagraphStyle的包装器).只读
 */
@property (nonatomic, readonly) CGFloat lineSpacing;
- (CGFloat)lineSpacingAtIndex:(NSUInteger)index;

/**
 段落结束后的空格(NSParagraphStyle的包装器).只读
 
 @discussion
 该属性包含在段落末尾添加的空格(以点为单位),将其与以下段落分开.
 此值必须为非负数.段落之间的空间通过添加前一段的paragraphSpacing和当前段落的SpacingBefore来确定.
 @discussion 默认值为 0.
 */
@property (nonatomic, readonly) CGFloat paragraphSpacing;
- (CGFloat)paragraphSpacingAtIndex:(NSUInteger)index;

/**
 段落顶部和文本内容开头之间的距离.
 (NSParagraphStyle包装器). (只读)
 
 @discussion 该属性包含段落顶部和文本内容开头之间的空格(以点为单位).
 @discussion 默认值为 0.
 @since CoreText:6.0  UIKit:6.0  YYKit:6.0
 */
@property (nonatomic, readonly) CGFloat paragraphSpacingBefore;
- (CGFloat)paragraphSpacingBeforeAtIndex:(NSUInteger)index;

/**
 第一行的缩进 (NSParagraphStyle包装器). (只读)
 
 @discussion 该属性包含从文本容器的前边缘到段落第一行开头的距离(以点为单位).此值始终为非负数
 @discussion 默认值为 0.
 @since CoreText:6.0  UIKit:6.0  YYKit:6.0
 */
@property (nonatomic, readonly) CGFloat firstLineHeadIndent;
- (CGFloat)firstLineHeadIndentAtIndex:(NSUInteger)index;

/**
 接收机的线以外的缩进. (NSParagraphStyle包装器). (只读)
 
 @discussion 该属性包含从文本容器的前边缘到除第一个之外的行的开头的距离(以点为单位).此值始终为非负数.
 @discussion 默认值为 0.
 
 @since CoreText:6.0  UIKit:6.0  YYKit:6.0
 */
@property (nonatomic, readonly) CGFloat headIndent;
- (CGFloat)headIndentAtIndex:(NSUInteger)index;

/**
 尾部缩进 (NSParagraphStyle包装器). (只读)
 
 @discussion
 如果为正,则该值是与前导边距的距离(例如,从左到右文本的左边距).
 如果为0或负数,则为距离后边距的距离.
 
 @discussion 默认值为 0.
 @since CoreText:6.0  UIKit:6.0  YYKit:6.0
 */
@property (nonatomic, readonly) CGFloat tailIndent;
- (CGFloat)tailIndentAtIndex:(NSUInteger)index;

/**
 接收器的最小行高 (NSParagraphStyle包装器). (只读)
 
 @discussion
 此属性包含接收器中任何行占用的最小高度,无论任何附加图形的字体大小或大小如何.此值必须为非负数.
 
 @discussion 默认值为 0.
 @since CoreText:6.0  UIKit:6.0  YYKit:6.0
 */
@property (nonatomic, readonly) CGFloat minimumLineHeight;
- (CGFloat)minimumLineHeightAtIndex:(NSUInteger)index;

/**
 接收机的最大行高 (NSParagraphStyle包装器). (只读)
 
 @discussion
 此属性包含接收器中任何行占用的最大高度,无论任何附加图形的字体大小或大小如何.
 此值始终为非负数.超过此高度的雕文和图形将与相邻的线重叠; 然而,最大高度为0意味着没有行高限制.
 虽然此限制适用于线路本身,但线间距在相邻线路之间增加了额外的空间.
 
 @discussion 默认值为 0 (no limit).
 @since CoreText:6.0  UIKit:6.0  YYKit:6.0
 */
@property (nonatomic, readonly) CGFloat maximumLineHeight;
- (CGFloat)maximumLineHeightAtIndex:(NSUInteger)index;

/**
 行高倍数 (NSParagraphStyle包装器). (只读)
 
 @discussion 此属性包含要使用的换行符模式布局段落文本.
 @discussion 默认值为 0 (no multiple).
 @since CoreText:6.0  UIKit:6.0  YYKit:6.0
 */
@property (nonatomic, readonly) CGFloat lineHeightMultiple;
- (CGFloat)lineHeightMultipleAtIndex:(NSUInteger)index;

/**
 The base writing direction (NSParagraphStyle包装器). (只读)
 
 @discussion
 如果您指定了NSWritingDirectionNaturalDirection,
 则接收器将写入方向解析为NSWritingDirectionLeftToRight或NSWritingDirectionRightToLeft,
 这取决于用户的'language'首选项设置的方向.
 
 @discussion Default is NSWritingDirectionNatural.
 @since CoreText:6.0  UIKit:6.0  YYKit:6.0
 */
@property (nonatomic, readonly) NSWritingDirection baseWritingDirection;
- (NSWritingDirection)baseWritingDirectionAtIndex:(NSUInteger)index;

/**
 The paragraph's threshold for hyphenation. (NSParagraphStyle包装器). (只读)
 
 @discussion
 有效值介于0.0和1.0之间.当文本宽度(断开,无连字符)与行片段的宽度的比率小于连字符因子时,尝试进行连字.
 当段落的连字系数为0.0时,使用布局管理器的连字符因子.当两者都为0.0时,连字符被禁用.
 
 @discussion 默认值为 0.
 @since UIKit:6.0
 */
@property (nonatomic, readonly) float hyphenationFactor;
- (float)hyphenationFactorAtIndex:(NSUInteger)index;

/**
 文档范围的默认标签间隔 (NSParagraphStyle包装器). (只读)
 
 @discussion 此属性表示以点为单位的默认制表符间隔.tabStops中指定的最后一个选项卡放置在该距离的整数倍(如果为正).
 
 @discussion 默认值为 0.
 @since CoreText:7.0  UIKit:7.0  YYKit:7.0
 */
@property (nonatomic, readonly) CGFloat defaultTabInterval;
- (CGFloat)defaultTabIntervalAtIndex:(NSUInteger)index;

/**
 表示接收器选项卡的NSTextTab对象数组停止.
 (NSParagraphStyle包装器). (只读)
 
 @discussion 按位置排序的NSTextTab对象定义段落样式的制表位.
 @discussion 默认值为12个TabStops,间隔为28.0.
 @since CoreText:7.0  UIKit:7.0  YYKit:7.0
 */
@property (nullable, nonatomic, copy, readonly) NSArray<NSTextTab *> *tabStops;
- (nullable NSArray<NSTextTab *> *)tabStopsAtIndex:(NSUInteger)index;


///MARK: ===================================================
///MARK: 获取CSText富文本属性
///MARK: ===================================================

/**
 文本阴影. (只读)
 
 @discussion 默认值为 nil (no shadow).
 */
@property (nullable, nonatomic, strong, readonly) CSTextShadow *textShadow;
- (nullable CSTextShadow *)textShadowAtIndex:(NSUInteger)index;

/**
 文本内阴影. (只读)
 
 @discussion 默认值为 nil (no shadow).
 */
@property (nullable, nonatomic, strong, readonly) CSTextShadow *textInnerShadow;
- (nullable CSTextShadow *)textInnerShadowAtIndex:(NSUInteger)index;

/**
 The text underline. (只读)
 
 @discussion 默认值为 nil (no underline).
 */
@property (nullable, nonatomic, strong, readonly) CSTextDecoration *textUnderline;
- (nullable CSTextDecoration *)textUnderlineAtIndex:(NSUInteger)index;

/**
 文本删除线. (只读)
 
 @discussion 默认值为 nil (no strikethrough).
 */
@property (nullable, nonatomic, strong, readonly) CSTextDecoration *textStrikethrough;
- (nullable CSTextDecoration *)textStrikethroughAtIndex:(NSUInteger)index;

/**
 文本边框. (只读)
 
 @discussion 默认值为nil（无边框）.
 
 */
@property (nullable, nonatomic, strong, readonly) CSTextBorder *textBorder;
- (nullable CSTextBorder *)textBorderAtIndex:(NSUInteger)index;

/**
 文字边框背景. (只读)
 
 @discussion 默认值为nil(无背景边框)
 */
@property (nullable, nonatomic, strong, readonly) CSTextBorder *textBackgroundBorder;
- (nullable CSTextBorder *)textBackgroundBorderAtIndex:(NSUInteger)index;


/**
 字形变换(只读)
 
 默认值为CGAffineTransformIdentity(无变换)
 */
@property (nonatomic, readonly) CGAffineTransform textGlyphTransform;
- (CGAffineTransform)textGlyphTransformAtIndex:(NSUInteger)index;


///MARK: ===================================================
///MARK: 查询CSText
///MARK: ===================================================

/**
 返回范围中的纯文本.
 如果有'CSTextBackedStringAttributeName'属性,则所支持的字符串将替换归因的字符串范围.
 
 @param range 接收器范围.
 @return 文本.
 */
- (nullable NSString *)plainTextForRange:(NSRange)range;



///MARK: ===================================================
///MARK: 为CSText创建附件字符串
///MARK: ===================================================

/**
 创建并返回附件.
 
 @param content      内容附件 (UIImage/UIView/CALayer).
 @param contentMode  附件显示模式
 @param width        内容宽度限制.
 @param ascent       内容上升值.
 @param descent      内容下降值.
 
 @return An attributed string, or nil if an error occurs.
 @since YYKit:6.0
 */
+ (NSMutableAttributedString *)attachmentStringWithContent:(nullable id)content
                                               contentMode:(UIViewContentMode)contentMode
                                                     width:(CGFloat)width
                                                    ascent:(CGFloat)ascent
                                                   descent:(CGFloat)descent;

/**
 创建并返回附件.
 
 
 示例: ContentMode:bottom Alignment:Top.
 
 The text      The attachment holder
 ↓                ↓
 ─────────┌──────────────────────┐───────
 / \   │                      │ / ___|
 / _ \  │                      │| |
 / ___ \ │                      │| |___     ←── 文本行
 /_/   \_\│    ██████████████    │ \____|
 ─────────│    ██████████████    │───────
 │    ██████████████    │
 │    ██████████████ ←───────────────── 附件内容
 │    ██████████████    │
 └──────────────────────┘
 
 @param content        内容附件 (UIImage/UIView/CALayer).
 @param contentMode    附件显示模式
 @param attachmentSize 附件 size.
 @param font           字体大小.
 @param alignment      水平对齐方式.
 
 @return An attributed string, or nil if an error occurs.
 @since YYKit:6.0
 */
+ (NSMutableAttributedString *)attachmentStringWithContent:(nullable id)content
                                               contentMode:(UIViewContentMode)contentMode
                                            attachmentSize:(CGSize)attachmentSize
                                               alignToFont:(UIFont *)font
                                                 alignment:(CSTextVerticalAlignment)alignment;

/**
 创建并从四方形图像返回一个属性,就像它是一个表情符号.
 
 @param image     四方形的图像.
 @param fontSize  字体大小.
 @return 富文本字符串,如果发生错误,则返回 nil.
 */
+ (nullable NSMutableAttributedString *)attachmentStringWithEmojiImage:(UIImage *)image
                                                              fontSize:(CGFloat)fontSize;


///MARK: ===================================================
///MARK: 公告方法
///MARK: ===================================================

/**
 返回NSMakeRange(0,self.length).
 */
- (NSRange)rangeOfAll;

/**
 如果YES,它在整个文本范围内共享相同的属性.
 */
- (BOOL)isSharedAttributesInAllRange;

/**
 如果YES,则可以使用[drawWithRect:options:context:]方法绘制或使用UIKit显示.
 如果NO,则应使用CoreText或CSText绘制
 
 @discussion
 如果方法返回NO,则表示UIKit不支持至少一个属性(如CTParagraphStyleRef).
 如果在UIKit中显示此字符串,则可能会丢失一些属性,甚至会使应用程序崩溃.
 */
- (BOOL)canDrawWithUIKit;




@end









/**
 主要用于设置富文本字符串的attributes属性.
 包括在UIKit,CoreText和YYText中定义的所有属性.
 */
@interface NSMutableAttributedString (CSText)

///MARK: ===================================================
///MARK: 设置字符富文本属性
///MARK: ===================================================

/**
 设置attributes属性集(字典).
 
 @discussion 旧的attributes将删除.
 @param attributes  包含要设置的属性的字典,或nil删除所有属性的字典.
 */
- (void)setAttributes:(nullable NSDictionary<NSString *, id> *)attributes;

/**
 根据指定属性名设置富文本属性.
 
 @param name   文档指定的属性名.
 @param value  属性名对应的值. 如果为 nil或者NSNull可删除对应属性.
 */
- (void)setAttribute:(NSString *)name value:(nullable id)value;

/**
 基于指定范围根据属性名设置富文本属性.
 
 @param name   文档指定的属性名.
 @param value  属性名对应的值. 如果为 nil或者NSNull可删除对应属性.
 @param range  指定的属性/值对应用于的字符范围.
 */
- (void)setAttribute:(NSString *)name value:(nullable id)value range:(NSRange)range;

/**
 删除指定范围内的所有属性.
 
 @param range  指定的范围.
 */
- (void)removeAttributesInRange:(NSRange)range;


///MARK: ===================================================
///MARK: 设置富文本字符串的属性
///MARK: ===================================================
/** 文本的字体 */
@property (nullable, nonatomic, strong, readwrite) UIFont *font;
- (void)setFont:(nullable UIFont *)font range:(NSRange)range;

/**
 默认是标准字距.
 字距属性指示以下字符应该从当前字符的字体以点为单位定义的默认偏移量移动多少点;
 一个正的肯恩指示一个偏移越远,一个负的凯恩表示一个更接近当前角色的移动.
 如果此属性不存在,将使用标准字距调整.
 如果此属性设置为0.0,则不会完成任何字距调整.
 
 设置此属性适用于整个文本字符串.获取此属性返回第一个字符的属性.
 */
@property (nullable, nonatomic, strong, readwrite) NSNumber *kern;
- (void)setKern:(nullable NSNumber *)kern range:(NSRange)range;

/**
 前景色(默认值为黑色)
 */
@property (nullable, nonatomic, strong, readwrite) UIColor *color;
- (void)setColor:(nullable UIColor *)color range:(NSRange)range;

/**
 背景颜色(默认为透明)
 */
@property (nullable, nonatomic, strong, readwrite) UIColor *backgroundColor;
- (void)setBackgroundColor:(nullable UIColor *)backgroundColor range:(NSRange)range;

/**
 笔划宽度
 
 默认值为0.0(无笔画).
 该属性被解释为字体大小的百分比,控制文本绘制模式:正值仅用笔画影响绘图;
 负值用于笔画和填充.概要文本的典型值为3.0
 */
@property (nullable, nonatomic, strong, readwrite) NSNumber *strokeWidth;
- (void)setStrokeWidth:(nullable NSNumber *)strokeWidth range:(NSRange)range;

/**
 笔画颜色(默认为 nil, 与前景色一致).
 */
@property (nullable, nonatomic, strong, readwrite) UIColor *strokeColor;
- (void)setStrokeColor:(nullable UIColor *)strokeColor range:(NSRange)range;

/**
 文字阴影.默认值为nil(无阴影)
 */
@property (nullable, nonatomic, strong, readwrite) NSShadow *shadow;
- (void)setShadow:(nullable NSShadow *)shadow range:(NSRange)range;

/**
 删除线风格.默认值为NSUnderlineStyleNone(无删除线)
 */
@property (nonatomic, readwrite) NSUnderlineStyle strikethroughStyle;
- (void)setStrikethroughStyle:(NSUnderlineStyle)strikethroughStyle range:(NSRange)range;

/**
 删除线颜色.默认值为nil(与前景颜色相同)
 */
@property (nullable, nonatomic, strong, readwrite) UIColor *strikethroughColor;
- (void)setStrikethroughColor:(nullable UIColor *)strikethroughColor range:(NSRange)range NS_AVAILABLE_IOS(7_0);

/**
 下划线风格.默认值为NSUnderlineStyleNone(无下划线)
 */
@property (nonatomic, readwrite) NSUnderlineStyle underlineStyle;
- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle range:(NSRange)range;

/**
 下划线颜色.默认值为nil(与前景颜色相同)
 */
@property (nullable, nonatomic, strong, readwrite) UIColor *underlineColor;
- (void)setUnderlineColor:(nullable UIColor *)underlineColor range:(NSRange)range;

/**
 连字队形控制.(具体详情查看NSAttributedString+CSText)
 */
@property (nullable, nonatomic, strong, readwrite) NSNumber *ligature;
- (void)setLigature:(nullable NSNumber *)ligature range:(NSRange)range;

/**
 文字效果.默认值为nil(无效果).
 当前唯一支持的值是NSTextEffectLetterpressStyle
 */
@property (nullable, nonatomic, strong, readwrite) NSString *textEffect;
- (void)setTextEffect:(nullable NSString *)textEffect range:(NSRange)range NS_AVAILABLE_IOS(7_0);

/**
 字形偏斜.默认值为0(无偏移)
 */
@property (nullable, nonatomic, strong, readwrite) NSNumber *obliqueness;
- (void)setObliqueness:(nullable NSNumber *)obliqueness range:(NSRange)range NS_AVAILABLE_IOS(7_0);

/**
 The log of the expansion factor to be applied to glyphs.
 
 @discussion 默认值为 0 (no expansion).
 @discussion Set this property applies to the entire text string.
 Get this property returns the first character's attribute.
 @since UIKit:7.0
 */
@property (nullable, nonatomic, strong, readwrite) NSNumber *expansion;
- (void)setExpansion:(nullable NSNumber *)expansion range:(NSRange)range NS_AVAILABLE_IOS(7_0);

/**
 角色偏离基线,以点为单位.默认值为0。
 */
@property (nullable, nonatomic, strong, readwrite) NSNumber *baselineOffset;
- (void)setBaselineOffset:(nullable NSNumber *)baselineOffset range:(NSRange)range NS_AVAILABLE_IOS(7_0);

/**
 雕文定向控制.默认为NO.NO值表示要使用水平字形,YES表示要使用垂直字形
 */
@property (nonatomic, readwrite) BOOL verticalGlyphForm;
- (void)setVerticalGlyphForm:(BOOL)verticalGlyphForm range:(NSRange)range;

/**
 指定文本语言
 */
@property (nullable, nonatomic, strong, readwrite) NSString *language;
- (void)setLanguage:(nullable NSString *)language range:(NSRange)range NS_AVAILABLE_IOS(7_0);

/**
 指定双向覆盖或嵌入.请参阅NSWritingDirection和NSWritingDirectionAttributeName
 */
@property (nullable, nonatomic, strong, readwrite) NSArray<NSNumber *> *writingDirection;
- (void)setWritingDirection:(nullable NSArray<NSNumber *> *)writingDirection range:(NSRange)range;

/**
 NSParagraphStyle对象,用于指定线对齐,标签尺,写入方向等
 */
@property (nullable, nonatomic, strong, readwrite) NSParagraphStyle *paragraphStyle;
- (void)setParagraphStyle:(nullable NSParagraphStyle *)paragraphStyle range:(NSRange)range;


///MARK: ===================================================
///MARK: 设置富文本字符串的段落属性
///MARK: ===================================================

/**
 文本对齐(NSParagraphStyle的包装器)
 */
@property (nonatomic, readwrite) NSTextAlignment alignment;
- (void)setAlignment:(NSTextAlignment)alignment range:(NSRange)range;

/**
 设置断开线的模式(NSParagraphStyle的包装器),默认是NSLineBreakByWordWrapping
 */
@property (nonatomic, readwrite) NSLineBreakMode lineBreakMode;
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range;

/**
 一块片段的底部与下一个片段的顶部之间的距离.(NSParagraphStyle的包装器)
 */
@property (nonatomic, readwrite) CGFloat lineSpacing;
- (void)setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range;

/**
 段落结束后的空格(NSParagraphStyle的包装器).
 
 @discussion
 该属性包含在段落末尾添加的空格(以点为单位),将其与以下段落分开.
 此值必须为非负数.段落之间的空间通过添加前一段的paragraphSpacing和当前段落的SpacingBefore来确定
 */
@property (nonatomic, readwrite) CGFloat paragraphSpacing;
- (void)setParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range;

/**
 段落顶部和文本内容开头之间的距离.(NSParagraphStyle的包装器).
 */
@property (nonatomic, readwrite) CGFloat paragraphSpacingBefore;
- (void)setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range;

/**
 第一行的缩进.(NSParagraphStyle的包装器)
 */
@property (nonatomic, readwrite) CGFloat firstLineHeadIndent;
- (void)setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range;

/**
 接收机的线以外的缩进.(NSParagraphStyle的包装器)
 
 @discussion 该属性包含从文本容器的前边缘到除第一个之外的行的开头的距离(以点为单位).此值始终为非负数.
 @discussion 默认值为 0.
 */
@property (nonatomic, readwrite) CGFloat headIndent;
- (void)setHeadIndent:(CGFloat)headIndent range:(NSRange)range;

/**
 尾部缩进(NSParagraphStyle的包装器)
 */
@property (nonatomic, readwrite) CGFloat tailIndent;
- (void)setTailIndent:(CGFloat)tailIndent range:(NSRange)range;

/**
 接收者的最小高度(NSParagraphStyle的包装器)
 */
@property (nonatomic, readwrite) CGFloat minimumLineHeight;
- (void)setMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range;

/**
 接收者的最大行高(NSParagraphStyle的包装器)
 
 @discussion
 此属性包含接收器中任何行占用的最大高度,无论任何附加图形的字体大小或大小如何.
 此值始终为非负数.超过此高度的雕文和图形将与相邻的线重叠; 然而,最大高度为0意味着没有行高限制.虽然此限制适用于线路本身,但线间距在相邻线路之间增加了额外的空间.
 @discussion 默认值为 0 (no limit).
 */
@property (nonatomic, readwrite) CGFloat maximumLineHeight;
- (void)setMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range;

/**
 行高度的个数(NSParagraphStyle的包装器)
 
 @discussion 此属性包含要使用的换行符模式布局段落的文本.
 @discussion 默认值为 0 (no multiple).
 */
@property (nonatomic, readwrite) CGFloat lineHeightMultiple;
- (void)setLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range;

/**
 基本写作方向(NSParagraphStyle的包装器).
 就是内容方向,内容左靠边
 
 @discussion
 如果您指定了NSWritingDirectionNaturalDirection,
 则接收器将写入方向解析为NSWritingDirectionLeftToRight或NSWritingDirectionRightToLeft,
 这取决于用户的'language'首选项设置的方向.
 @discussion 默认值是 NSWritingDirectionNatural.
 */
@property (nonatomic, readwrite) NSWritingDirection baseWritingDirection;
- (void)setBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range;

/**
 段落的连字阈值(NSParagraphStyle的包装器).
 
 @discussion
 有效值介于0.0和1.0之间.
 当文本宽度(断开,无连字符)与行片段的宽度的比率小于连字符因子时,尝试进行连字.
 当段落的连字系数为0.0时,使用布局管理器的连字符因子.
 当两者都为0.0时,连字符被禁用
 */
@property (nonatomic, readwrite) float hyphenationFactor;
- (void)setHyphenationFactor:(float)hyphenationFactor range:(NSRange)range;

/**
 文档范围的默认标签间隔(NSParagraphStyle的包装器).
 
 @discussion
 此属性表示以点为单位的默认制表符间隔.
 tabStops中指定的最后一个选项卡放置在该距离的整数倍(如果为正)
 */
@property (nonatomic, readwrite) CGFloat defaultTabInterval;
- (void)setDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range NS_AVAILABLE_IOS(7_0);

/**
 表示接收机的制表NSTextTab对象的数组(NSParagraphStyle的包装器).
 
 @discussion 该NSTextTab对象,按位置排序,定义制表位的段落样式.
 @discussion 默认值为12个TabStops,间隔为28.0.
 */
@property (nullable, nonatomic, copy, readwrite) NSArray<NSTextTab *> *tabStops;
- (void)setTabStops:(nullable NSArray<NSTextTab *> *)tabStops range:(NSRange)range NS_AVAILABLE_IOS(7_0);

///MARK: ===================================================
///MARK: 设置CSText富文本属性
///MARK: ===================================================

/**
 文字阴影,默认值为nil(无阴影)
 */
@property (nullable, nonatomic, strong, readwrite) CSTextShadow *textShadow;
- (void)setTextShadow:(nullable CSTextShadow *)textShadow range:(NSRange)range;

/**
 文本内阴影,默认值为nil(无阴影)
 */
@property (nullable, nonatomic, strong, readwrite) CSTextShadow *textInnerShadow;
- (void)setTextInnerShadow:(nullable CSTextShadow *)textInnerShadow range:(NSRange)range;

/**
 文字下划线,默认值为nil(无下划线)
 */
@property (nullable, nonatomic, strong, readwrite) CSTextDecoration *textUnderline;
- (void)setTextUnderline:(nullable CSTextDecoration *)textUnderline range:(NSRange)range;

/**
 文本删除线,默认值为nil(无删除线)
 */
@property (nullable, nonatomic, strong, readwrite) CSTextDecoration *textStrikethrough;
- (void)setTextStrikethrough:(nullable CSTextDecoration *)textStrikethrough range:(NSRange)range;

/**
 文本边框,默认值为nil(无边框)
 */
@property (nullable, nonatomic, strong, readwrite) CSTextBorder *textBorder;
- (void)setTextBorder:(nullable CSTextBorder *)textBorder range:(NSRange)range;

/**
 文字边框背景,默认值为nil(无边框背景)
 */
@property (nullable, nonatomic, strong, readwrite) CSTextBorder *textBackgroundBorder;
- (void)setTextBackgroundBorder:(nullable CSTextBorder *)textBackgroundBorder range:(NSRange)range;

/**
 文本形变,默认值为CGAffineTransformIdentity(无变换)
 */
@property (nonatomic, readwrite) CGAffineTransform textGlyphTransform;
- (void)setTextGlyphTransform:(CGAffineTransform)textGlyphTransform range:(NSRange)range;


///MARK: ===================================================
///MARK: 设置范围的不连续富文本属性
///MARK: ===================================================
- (void)setSuperscript:(nullable NSNumber *)superscript range:(NSRange)range;
- (void)setGlyphInfo:(nullable CTGlyphInfoRef)glyphInfo range:(NSRange)range;
- (void)setCharacterShape:(nullable NSNumber *)characterShape range:(NSRange)range;
- (void)setRunDelegate:(nullable CTRunDelegateRef)runDelegate range:(NSRange)range;
- (void)setBaselineClass:(nullable CFStringRef)baselineClass range:(NSRange)range;
- (void)setBaselineInfo:(nullable CFDictionaryRef)baselineInfo range:(NSRange)range;
- (void)setBaselineReferenceInfo:(nullable CFDictionaryRef)referenceInfo range:(NSRange)range;
- (void)setRubyAnnotation:(nullable CTRubyAnnotationRef)ruby range:(NSRange)range NS_AVAILABLE_IOS(8_0);
- (void)setAttachment:(nullable NSTextAttachment *)attachment range:(NSRange)range NS_AVAILABLE_IOS(7_0);
- (void)setLink:(nullable id)link range:(NSRange)range NS_AVAILABLE_IOS(7_0);
- (void)setTextBackedString:(nullable CSTextBackedString *)textBackedString range:(NSRange)range;
- (void)setTextBinding:(nullable CSTextBinding *)textBinding range:(NSRange)range;
- (void)setTextAttachment:(nullable CSTextAttachment *)textAttachment range:(NSRange)range;
- (void)setTextHighlight:(nullable CSTextHighlight *)textHighlight range:(NSRange)range;
- (void)setTextBlockBorder:(nullable CSTextBorder *)textBlockBorder range:(NSRange)range;
- (void)setTextRubyAnnotation:(nullable CSTextRubyAnnotation *)ruby range:(NSRange)range NS_AVAILABLE_IOS(8_0);


///MARK: ===================================================
///MARK: 文字高亮的便利方法
///MARK: ===================================================

/**
 设置文字高亮便利方法
 
 @param range 范围文字范围
 @param color 颜色文字颜色
 @param backgroundColor 文字高亮时背景颜色
 @param userInfo 用户信息字典
 @param tapAction 轻点时间
 @param longPressAction 长按事件
 */
- (void)setTextHighlightRange:(NSRange)range
                        color:(nullable UIColor *)color
              backgroundColor:(nullable UIColor *)backgroundColor
                     userInfo:(nullable NSDictionary *)userInfo
                    tapAction:(nullable CSTextAction)tapAction
              longPressAction:(nullable CSTextAction)longPressAction;


/**
 设置文字高亮便利方法
 
 @param range 范围文字范围
 @param color 颜色文字颜色
 @param backgroundColor 文字高亮时背景颜色
 @param tapAction 轻点时间
 */
- (void)setTextHighlightRange:(NSRange)range
                        color:(nullable UIColor *)color
              backgroundColor:(nullable UIColor *)backgroundColor
                    tapAction:(nullable CSTextAction)tapAction;

/**
 设置文字高亮便利方法
 
 @param range 范围文字范围
 @param color 颜色文字颜色
 @param backgroundColor 文字高亮时背景颜色
 @param userInfo 用户信息字典
 */
- (void)setTextHighlightRange:(NSRange)range
                        color:(nullable UIColor *)color
              backgroundColor:(nullable UIColor *)backgroundColor
                     userInfo:(nullable NSDictionary *)userInfo;

///MARK: ===================================================
///MARK: 公共方法
///MARK: ===================================================

/**
 在给定位置插入给定字符串的字符.新字符串从位置继承第一个替换字符的富文本属性
 
 @param string 要插入到接收器的字符串,不能为nil
 @param location 插入字符串的位置.位置不能超过接收器的范围
 */
- (void)insertString:(NSString *)string atIndex:(NSUInteger)location;

/**
 给接收端添加一个给定字符串的字符.新的字符串继承接收者尾部的属性
 
 @param string 要附加到接收者的字符串,不能为nil
 */
- (void)appendString:(NSString *)string;

/**
 在连接表情符号范围内使用[UIColor clearColor]设置前景色.绘文字绘图不会被前景色的影响.
 
 @discussion
 在iOS8.3中,苹果发布了一些新的多样化表情.
 有一些表情符号可以组合成一个新的'加入表情符号'.
 连接器是unicode字符'ZERO WIDTH JOINER'(U+200D).
 例如:👩👧👧👩👧👧-->👩👧👧👩👧👧.
 
 当在同一个CTL中有超过5个'加入表情符号'时,CoreText可能会在表情符号之上渲染一些额外的字形.
 这是CoreText中的一个错误,尝试避免这种方法.iOS 9中修复了这个错误.
 */
- (void)setClearColorToJoinedEmoji;

/**
 删除指定范围内的所有不连续属性.请参见'allDiscontinuousAttributeKeys'.
 
 @param range 文字范围.
 */
- (void)removeDiscontinuousAttributesInRange:(NSRange)range;

/**
 返回所有不连续的属性键,如RunDelegate/Attachment/Ruby.
 
 @discussion 这些属性只能设置为指定的文本范围,并且在编辑文本时不应扩展到其他范围.
 */
+ (NSArray<NSString *> *)allDiscontinuousAttributeKeys;

@end






NS_ASSUME_NONNULL_END





