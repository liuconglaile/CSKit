//
//  CSTextAttribute.h
//  CSCategory
//
//  Created by mac on 2017/7/26.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class CSTextShadow;
NS_ASSUME_NONNULL_BEGIN

///MARK: ===================================================
///MARK: 枚举定义
///MARK: ===================================================


/**
 属性类型
 
 - CSTextAttributeTypeNone:     无属性
 - CSTextAttributeTypeUIKit:    UIKit属性,如UILabel/UITextField/drawInRect
 - CSTextAttributeTypeCoreText: CoreText属性
 - CSTextAttributeTypeCSText:   CSText属性，由CSText使用
 */
typedef NS_OPTIONS(NSInteger, CSTextAttributeType) {
    CSTextAttributeTypeNone     = 0,
    CSTextAttributeTypeUIKit    = 1 << 0,
    CSTextAttributeTypeCoreText = 1 << 1,
    CSTextAttributeTypeCSText   = 1 << 2,
};


/**
 从属性名称获取属性类型
 
 @param attributeName 属性名
 @return 属性类型
 */
extern CSTextAttributeType CSTextAttributeGetType(NSString *attributeName);


/**
 CSText中的线条样式(类似于NSUnderlineStyle)
 
 基本样式 (位掩码:0xFF)
 - CSTextLineStyleNone:   (      )不绘制一行,默认
 - CSTextLineStyleSingle: (──────)绘制单行
 - CSTextLineStyleThick:  (━━━━━━)绘制粗线
 - CSTextLineStyleDouble: (══════)绘制双线
 
 风格样式 (位掩码:0xF00)
 - CSTextLineStylePatternSolid:      (───────)绘制一条实线
 - CSTextLineStylePatternDot:        (‑ ‑ ‑ ‑)绘制一行点
 - CSTextLineStylePatternDash:       (— — — —)绘制破折号
 - CSTextLineStylePatternDashDot:    (— ‑ — ‑)绘制交替的虚线和点
 - CSTextLineStylePatternDashDotDot: (— ‑ ‑ —)绘制交替的破折号和两个点
 - CSTextLineStylePatternCircleDot:  (•••••••)绘制小圆点
 */
typedef NS_OPTIONS (NSInteger, CSTextLineStyle) {
    CSTextLineStyleNone       = 0x00,
    CSTextLineStyleSingle     = 0x01,
    CSTextLineStyleThick      = 0x02,
    CSTextLineStyleDouble     = 0x09,
    
    CSTextLineStylePatternSolid      = 0x000,
    CSTextLineStylePatternDot        = 0x100,
    CSTextLineStylePatternDash       = 0x200,
    CSTextLineStylePatternDashDot    = 0x300,
    CSTextLineStylePatternDashDotDot = 0x400,
    CSTextLineStylePatternCircleDot  = 0x900,
};



/**
 文字垂直对齐
 
 - CSTextVerticalAlignmentTop: 上
 - CSTextVerticalAlignmentCenter: 中
 - CSTextVerticalAlignmentBottom: 下
 */
typedef NS_ENUM(NSInteger, CSTextVerticalAlignment) {
    CSTextVerticalAlignmentTop =    0,
    CSTextVerticalAlignmentCenter = 1,
    CSTextVerticalAlignmentBottom = 2,
};


/**
 在CSText中定义方向
 
 - CSTextDirectionNone: 无
 - CSTextDirectionTop: 上
 - CSTextDirectionRight: 右
 - CSTextDirectionBottom: 下
 - CSTextDirectionLeft: 左
 */
typedef NS_OPTIONS(NSUInteger, CSTextDirection) {
    CSTextDirectionNone   = 0,
    CSTextDirectionTop    = 1 << 0,
    CSTextDirectionRight  = 1 << 1,
    CSTextDirectionBottom = 1 << 2,
    CSTextDirectionLeft   = 1 << 3,
};


/**
 trunction类型,告诉截断引擎正在请求哪种类型的截断
 
 - CSTextTruncationTypeNone: 无
 - CSTextTruncationTypeStart: 在线的开头截断,使结尾部分可见(....xxxx)
 - CSTextTruncationTypeEnd: 截断行尾,使起始部分可见(xxxx....)
 - CSTextTruncationTypeMiddle: 截断行中间,使起始部分和末尾部分都可见(xx....xx)
 */
typedef NS_ENUM (NSUInteger, CSTextTruncationType) {
    CSTextTruncationTypeNone   = 0,
    CSTextTruncationTypeStart  = 1,
    CSTextTruncationTypeEnd    = 2,
    CSTextTruncationTypeMiddle = 3,
};


///MARK: ===================================================
///MARK: 枚举定义
///MARK: ===================================================



///MARK: ===================================================
///MARK: 在CSText中定义属性名称
///MARK: ===================================================

/**
 这个属性的值是一个CSTextBackedString对象。
 使用此属性存储原始纯文本(如果被其他东西替换)(如附件)
 */
UIKIT_EXTERN NSString *const CSTextBackedStringAttributeName;

/**
 这个属性的值是一个'CSTextBinding'对象.
 使用此属性将一系列文本绑定在一起,就像它是一个单一的字符串一样
 */
UIKIT_EXTERN NSString *const CSTextBindingAttributeName;

/**
 这个属性的值是一个'CSTextShadow'对象.
 使用此属性将阴影添加到一系列文本.
 阴影将在文字下方绘制.使用CSTextShadow.subShadow添加多个阴影
 */
UIKIT_EXTERN NSString *const CSTextShadowAttributeName;

/**
 这个属性的值是一个'CSTextShadow'对象.
 使用此属性将内阴影添加到一系列文本.
 内影将在文字上方绘制.使用CSTextShadow.subShadow添加多个阴影.
 */
UIKIT_EXTERN NSString *const CSTextInnerShadowAttributeName;

/**
 这个属性的值是一个'CSTextDecoration'对象.
 使用此属性将下划线添加到一定范围的文本.
 下划线将在文字下方绘制
 */
UIKIT_EXTERN NSString *const CSTextUnderlineAttributeName;

/**
 这个属性的值是一个'CSTextDecoration'对象.
 使用此属性将删除线(删除行)添加到文本范围.
 删除线将在文字字形之上绘制
 */
UIKIT_EXTERN NSString *const CSTextStrikethroughAttributeName;

/**
 这个属性的值是一个'CSTextBorder'对象.
 使用此属性将封面边框或封面颜色添加到一系列文本.
 边框将被绘制在文字字形之上
 */
UIKIT_EXTERN NSString *const CSTextBorderAttributeName;

/**
 这个属性的值是一个'CSTextBorder'对象.
 使用此属性将背景边框或背景颜色添加到文本范围.
 边框将在文字下方绘制
 */
UIKIT_EXTERN NSString *const CSTextBackgroundBorderAttributeName;

/**
 这个属性的值是一个'CSTextBorder'对象.
 使用此属性将代码块边框添加到一行或多行文本.
 边框将在文字下方绘制
 */
UIKIT_EXTERN NSString *const CSTextBlockBorderAttributeName;

/**
 这个属性的值是一个'CSTextAttachment'对象.
 使用此属性将附件添加到文本。
 它应该与CTRunDelegate结合使用
 */
UIKIT_EXTERN NSString *const CSTextAttachmentAttributeName_text;

/**
 这个属性的值是一个'CSTextHighlight'对象.
 使用此属性可在一系列文本中添加可触摸的高亮状态
 */
UIKIT_EXTERN NSString *const CSTextHighlightAttributeName;

///这个属性的值是一个'NSValue'对象存储CGAffineTransform.
///使用此属性将变换添加到文本范围内的每个字形
UIKIT_EXTERN NSString *const CSTextGlyphTransformAttributeName;



UIKIT_EXTERN NSString *const CSTextAttachmentAttributeName;
UIKIT_EXTERN NSString *const CSTextLinkAttributedName;
UIKIT_EXTERN NSString *const CSTextLongPressAttributedName;
UIKIT_EXTERN NSString *const CSTextBackgroundColorAttributedName;
UIKIT_EXTERN NSString *const CSTextStrokeAttributedName;
UIKIT_EXTERN NSString *const CSTextBoundingStrokeAttributedName;





///MARK: ===================================================
///MARK: 字符串标记定义 String Token Define
///MARK: ===================================================
UIKIT_EXTERN NSString *const CSTextAttachmentToken; ///< 对象替换字符(U+FFFC),用于文本附件.
UIKIT_EXTERN NSString *const CSTextTruncationToken; ///< 水平省略号(U+2026),用于文本截断"…".








///MARK: ===================================================
///MARK: 属性值定义
///MARK: ===================================================

/**
 在CSText中定义的 tap/long 动作回调
 
 @param containerView 文本容器视图(CSLabel/CSTextView)
 @param text 文本全文
 @param range 文本范围(如果没有范围,range.location == NSNotFound)
 @param rect 'containerView'的Frame,(如果没有数据,则 rect = CGRectNull)
 */
typedef void(^CSTextAction)(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect);




/**
 文本高亮枚举
 
 - CSTextHighlightTypeNormal: 常规
 - CSTextHighlightTypeWholeText: 全文
 - CSTextHighlightTypeLongPress: 长按
 */
typedef NS_ENUM(NSUInteger, CSTextHighlightType) {
    CSTextHighlightTypeNormal,
    CSTextHighlightTypeWholeText,
    CSTextHighlightTypeLongPress
};












//MARK:=============================CSTextAttachment=============================
//MARK:文本的附件的封装,可以是图片或是UIView对象、CALayer对象
//MARK:=============================CSTextAttachment=============================

/**
 NSAttributedString类集群使用CSTextAttachment对象作为附件属性的值
 (存储在名为CSTextAttachmentAttributeName的键下的属性字符串中).
 
 当显示包含'CSTextAttachment'对象的属性字符串时,内容将被放置为文本度量.
 如果内容是'UIImage',那么它将被绘制到CGContext;
 如果内容是'UIView'或'CALayer',那么它将被添加到文本容器的视图或图层中.
 */

@interface CSTextAttachment : NSObject
<NSCopying,NSMutableCopying,NSCoding>
//@property (nonatomic,strong) id content;                      //内容
@property (nonatomic,assign) NSRange range;                     //在string中的range
@property (nonatomic,assign) CGRect frame;                      //frame
@property (nonatomic,strong) NSURL* URL;                        //URL
//@property (nonatomic,assign) UIViewContentMode contentMode;   //内容模式
@property (nonatomic,assign) UIEdgeInsets contentEdgeInsets;    //边缘内嵌大小
@property (nonatomic,strong) NSDictionary* userInfo;            //自定义的一些信息


@property (nullable, nonatomic, strong) id content;             ///< 支持的类型: UIImage, UIView, CALayer
@property (nonatomic) UIViewContentMode contentMode;            ///< 内容显示模式.
@property (nonatomic) UIEdgeInsets contentInsets;               ///< 内容间距.
//@property (nullable, nonatomic, strong) NSDictionary *userInfo; ///< 用户信息字典.

+ (instancetype)attachmentWithContent:(nullable id)content;
+ (instancetype)textAttachmentWithContent:(id)content;

@end























//MARK:=============================CSTextBackgroundColor========================
//MARK:文本背景颜色的封装
//MARK:=============================CSTextBackgroundColor========================
@interface CSTextBackgroundColor : NSObject  <NSCopying,NSMutableCopying,NSCoding>
@property (nonatomic,assign) NSRange range;                 //在字符串的range
@property (nonatomic,strong) UIColor* backgroundColor;      //背景颜色
@property (nonatomic,copy) NSArray<NSValue *>* positions;   //位置数组
@property (nonatomic,strong) NSDictionary* userInfo;        //自定义的一些信息

@end









//MARK:=============================CSTextStroke================================
//MARK:文本描边的封装（空心字）
//MARK:=============================CSTextStroke================================
@interface CSTextStroke : NSObject  <NSCopying,NSMutableCopying,NSCoding>
@property (nonatomic,assign) NSRange range;             //在字符串的range
@property (nonatomic,strong) UIColor* strokeColor;      //描边颜色
@property (nonatomic,assign) CGFloat strokeWidth;       //描边的宽度
@property (nonatomic,strong) NSDictionary* userInfo;    //自定义的一些信息

@end







//MARK:=============================CSTextBoundingStroke========================
//MARK:文本边框
//MARK:=============================CSTextBoundingStroke========================
/**
 NSAttributedString类集群使用CSTextBorder对象作为边界属性的值
 (存储在名为CSTextBorderAttributeName或CSTextBackgroundBorderAttributeName的键下的属性字符串中).
 
 它可以用于在一系列文本上绘制边框,或者绘制一系列文本的背景
 示例:
 ╭──────╮
 │ Text │
 ╰──────╯
 */

@interface CSTextBorder : NSObject<NSCopying,NSMutableCopying,NSCoding>
@property (nonatomic,assign) NSRange range;                   ///< 在字符串的range
//@property (nonatomic,strong) UIColor* strokeColor;          ///< 描边颜色
@property (nonatomic,copy) NSArray<NSValue *>* positions;     ///< 位置数组
@property (nonatomic,strong) NSDictionary* userInfo;          ///< 自定义的一些信息
@property (nonatomic) CSTextLineStyle lineStyle;              ///< 边框风格
@property (nonatomic) CGFloat strokeWidth;                    ///< 边框宽度
@property (nullable, nonatomic, strong) UIColor *strokeColor; ///< 边框颜色
@property (nonatomic) CGLineJoin lineJoin;                    ///< 边框连接
@property (nonatomic) UIEdgeInsets insets;                    ///< 边框<-->文本 之间的内间距
@property (nonatomic) CGFloat cornerRadius;                   ///< 边框角半径
@property (nullable, nonatomic, strong) CSTextShadow *shadow; ///< 边框阴影
@property (nullable, nonatomic, strong) UIColor *fillColor;   ///< 内部填充颜色


+ (instancetype)borderWithLineStyle:(CSTextLineStyle)lineStyle lineWidth:(CGFloat)width strokeColor:(nullable UIColor *)color;
+ (instancetype)borderWithFillColor:(nullable UIColor *)color cornerRadius:(CGFloat)cornerRadius;

@end










//MARK:=============================CSTextBackedString========================
//MARK:其他
//MARK:=============================CSTextBackedString========================
/**
 NSAttributedString类集群使用CSTextBackedString对象作为文本支持的字符串属性的值
 (存储在名为CSTextBackedStringAttributeName的关键字下的属性字符串中).
 
 它可用于(copy/paste)属性串纯文本.
 示例: If :) 根据自定义的表情符号代替 (如😊), 支持的字符串可以设置为 @":)".
 */
@interface CSTextBackedString : NSObject <NSCoding, NSCopying>
+ (instancetype)stringWithString:(nullable NSString *)string;
@property (nullable, nonatomic, copy) NSString *string; ///< 支持字符串
@end








/**
 NSAttributedString类集群使用CSTextBinding对象作为阴影属性的值
 (存储在名为CSTextBindingAttributeName的关键字下的属性字符串中)
 
 将其添加到一系列文本将使指定的字符'绑定在一起'.
 CSTextView将在文本选择和编辑期间将文本的范围视为单个字符.
 */
@interface CSTextBinding : NSObject <NSCoding, NSCopying>
+ (instancetype)bindingWithDeleteConfirm:(BOOL)deleteConfirm;
@property (nonatomic) BOOL deleteConfirm; ///< 在CSTextView中删除时确认范围
@end







/**
 NSAttributedString类集群使用CSTextShadow对象作为阴影属性的值
 (存储在名为CSTextShadowAttributeName或CSTextInnerShadowAttributeName的键下的属性字符串中).
 
 它类似于'NSShadow',但提供更多选项
 */
@interface CSTextShadow : NSObject <NSCoding, NSCopying>
+ (instancetype)shadowWithColor:(nullable UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

@property (nullable, nonatomic, strong) UIColor *color; ///< 阴影颜色
@property (nonatomic) CGSize offset;                    ///< 阴影偏移
@property (nonatomic) CGFloat radius;                   ///< 阴影模糊半径
@property (nonatomic) CGBlendMode blendMode;            ///< 阴影混合模式
@property (nullable, nonatomic, strong) CSTextShadow *subShadow;  ///< 将在父影子之上添加的子影子

+ (instancetype)shadowWithNSShadow:(NSShadow *)nsShadow; ///< 将NSShadow转换为CSTextShadow
- (NSShadow *)nsShadow; ///< 将CSTextShadow转换为NSShadow
@end









/**
 NSAttributedString类集群使用CSTextDecorationLine对象作为装饰线属性的值
 (存储在名为CSTextUnderlineAttributeName或CSTextStrikethroughAttributeName的键下的属性字符串中).
 
 当它用作下划线时,该行在文本字形下面绘制
 当它用作删除线时，该行在文本字形之上绘制
 */
@interface CSTextDecoration : NSObject <NSCoding, NSCopying>
+ (instancetype)decorationWithStyle:(CSTextLineStyle)style;
+ (instancetype)decorationWithStyle:(CSTextLineStyle)style width:(nullable NSNumber *)width color:(nullable UIColor *)color;
@property (nonatomic) CSTextLineStyle style;                   ///< 线条风格
@property (nullable, nonatomic, strong) NSNumber *width;       ///< 线宽(nil表示自动宽度)
@property (nullable, nonatomic, strong) UIColor *color;        ///< 线颜色(nil表示自动颜色)
@property (nullable, nonatomic, strong) CSTextShadow *shadow;  ///< 线阴影
@end









//MARK:=============================CSTextHighlight=============================
//MARK:文本链接的封装
//MARK:=============================CSTextHighlight=============================
/**
 CSTextHighlight对象由NSAttributedString类集群用作可触摸突出显示属性的值
 (存储在名为CSTextHighlightAttributeName的键下的属性字符串中)
 
 在'CSLabel'或'CSTextView'中显示属性字符串时,用户可以触摸高亮文本的范围.
 如果文本范围变为突出显示状态,则'CSTextHighlight'中的'attributes'将用于修改(设置或删除)显示范围内的原始属性
 */
@interface CSTextHighlight : NSObject <NSCopying,NSMutableCopying,NSCoding>
@property (nonatomic,assign) NSRange range;                 //在字符串的range
@property (nonatomic,strong) UIColor* linkColor;            //链接的颜色
@property (nonatomic,strong) UIColor* hightlightColor;      //高亮颜色
@property (nonatomic,copy) NSArray<NSValue *>* positions;   //位置数组
@property (nullable,nonatomic,strong) id content;           //内容
@property (nonatomic,strong) NSDictionary* userInfo;        //自定义的一些信息
@property (nonatomic,assign) CSTextHighlightType type;      //高亮类型



/**
 突出显示时,您可以应用于属性字符串中的文本的属性.
 Key:   与 CoreText/CSText 属性名称相同.
 Value: 突出显示时修改属性值 (NSNull 用于删除属性).
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, id> *attributes;

/**
 创建具有指定属性的高亮对象.
 
 @param attributes 突出显示时将替换原始属性的属性,如果值为NSNull,则在突出显示时将被删除.
 */
+ (instancetype)highlightWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes;

/**
 高亮时背景颜色.
 
 @param color 背景颜色.
 */
+ (instancetype)highlightWithBackgroundColor:(nullable UIColor *)color;

// 设置'attributes'的便利方法.
- (void)setFont:(nullable UIFont *)font;
- (void)setColor:(nullable UIColor *)color;
- (void)setStrokeWidth:(nullable NSNumber *)width;
- (void)setStrokeColor:(nullable UIColor *)color;
- (void)setShadow:(nullable CSTextShadow *)shadow;
- (void)setInnerShadow:(nullable CSTextShadow *)shadow;
- (void)setUnderline:(nullable CSTextDecoration *)underline;
- (void)setStrikethrough:(nullable CSTextDecoration *)strikethrough;
- (void)setBackgroundBorder:(nullable CSTextBorder *)border;
- (void)setBorder:(nullable CSTextBorder *)border;
- (void)setAttachment:(nullable CSTextAttachment *)attachment;

///**
// 用户信息字典,默认为nil.
// */
//@property (nullable, nonatomic, copy) NSDictionary *userInfo;

/**
 当用户轻击回调函数,默认值为nil.
 如果值为nil,CSTextView或CSLabel将要求其委托来处理点击操作.
 */
@property (nullable, nonatomic, copy) CSTextAction tapAction;

/**
 (当用户长按高亮时)长按动作回调函数,默认为nil
 如果值为nil,CSTextView或CSLabel将要求其委托处理长按操作.
 */
@property (nullable, nonatomic, copy) CSTextAction longPressAction;


@end





///** 文字格式 */
//@interface CSTextGlyph : NSObject
///<,NSMutableCopying,NSCoding>
//
//@property (nonatomic,assign) CGGlyph glyph;
//@property (nonatomic,assign) CGPoint position;
//@property (nonatomic,assign) CGFloat ascent;
//@property (nonatomic,assign) CGFloat descent;
//@property (nonatomic,assign) CGFloat leading;
//@property (nonatomic,assign) CGFloat width;
//@property (nonatomic,assign) CGFloat height;
//
//@end



NS_ASSUME_NONNULL_END
