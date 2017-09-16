//
//  CSTextLayout.h
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>

#if __has_include(<CSKit/CSKit.h>)
#import <CSKit/CSTextDebugOption.h>
#import <CSKit/CSTextLine.h>
#import <CSKit/CSTextInput.h>
#else
#import "CSTextDebugOption.h"
#import "CSTextLine.h"
#import "CSTextInput.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@protocol CSTextLinePositionModifier;


/**
 布局中最大文本容器大小.
 */
extern const CGSize CSTextContainerMaxSize;

/**
 CSTextContainer类定义了一个文本布局的区域.
 CSTextLayout类使用一个或多个CSTextContainer对象来生成布局.
 
 CSTextContainer定义了矩形区域('size'和'insets')或非矩形形状('path'),
 您可以在文本容器的边界矩形内定义排除路径,以便文本在排除路径周围排列.
 
 此类中的所有方法都是线程安全的.
 
 示例:
 
 ┌─────────────────────────────┐  <-------- 容器
 │                             │
 │    asdfasdfasdfasdfasdfa   <------------ 容器间距
 │    asdfasdfa   asdfasdfa    │
 │    asdfas         asdasd    │
 │    asdfa        <----------------------- 容器排除路径
 │    asdfas         adfasd    │
 │    asdfasdfa   asdfasdfa    │
 │    asdfasdfasdfasdfasdfa    │
 │                             │
 └─────────────────────────────┘
 */
@interface CSTextContainer : NSObject <NSCoding, NSCopying>

/**
 创建一个指定尺寸的容器
 
 @param size 大小
 @return 容器
 */
+ (instancetype)containerWithSize:(CGSize)size;

/**
 创建具有指定尺寸和内间距的容器
 
 @param size 尺寸
 @param insets 内间距
 @return 容器
 */
+ (instancetype)containerWithSize:(CGSize)size insets:(UIEdgeInsets)insets;

/**
 创建具有指定路径的容器
 
 @param path 路径
 @return 容器
 */
+ (instancetype)containerWithPath:(nullable UIBezierPath *)path;

/**
 约束的大小
 如果大小大于CSTextContainerMaxSize,将被剪辑
 */
@property CGSize size;

/**
 约束的内间距
 内间距的值不应该为负值,默认为UIEdgeInsetsZero
 */
@property UIEdgeInsets insets;

/**
 自定义约束路径.
 设置该属性忽略'size'和'insets'.默认值为nil
 */
@property (nullable, copy) UIBezierPath *path;

/**
 用于路径排除UIBezierPath的阵列.默认值为nil
 */
@property (nullable, copy) NSArray<UIBezierPath *> *exclusionPaths;


/**
 路径线宽.默认值为0
 */
@property CGFloat pathLineWidth;


/**
 YES:(PathFillEvenOdd)
 如果路径被赋予CGContextEOFillPath,文本将被填充到将被绘制的区域中
 
 NO: (PathFillWindingNumber)
 如果将路径赋给CGContextFillPath,则文本将填写将被绘制的区域
 
 默认值为 YES
 */
@property (getter=isPathFillEvenOdd) BOOL pathFillEvenOdd;


/**
 文本是否是垂直形式(可用于CJK文本布局)
 默认值为NO
 */
@property (getter=isVerticalForm) BOOL verticalForm;

/**
 最大行数为0表示无限制.
 默认值为0
 */
@property NSUInteger maximumNumberOfRows;

/**
 行截断类型,默认为none
 */
@property CSTextTruncationType truncationType;

/**
 截断令牌.
 如果没有,则布局将使用'...'. 默认值为nil
 */
@property (nullable, copy) NSAttributedString *truncationToken;

/**
 此修饰符应用于布局完成之前的行,给你机会修改行位置.
 默认值为nil
 */
@property (nullable, copy) id<CSTextLinePositionModifier> linePositionModifier;
@end








/**
 CSTextLinePositionModifier协议声明了在文本布局进度中修改行位置所需的方法.
 示例参见'CSTextLinePositionSimpleModifier'
 */
@protocol CSTextLinePositionModifier <NSObject, NSCopying>
@required

/**
 此方法将在布局完成之前调用.
 该方法应该是线程安全的
 
 @param lines CSTextLine的数组
 @param text 文本
 @param container 布局容器
 */
- (void)modifyLines:(NSArray<CSTextLine *> *)lines fromText:(NSAttributedString *)text inContainer:(CSTextContainer *)container;
@end







/**
 CSTextLinePositionModifier的简单实现.
 它可以固定每个线的位置移动到规定值时,允许每一行高度是相同的
 */
@interface CSTextLinePositionSimpleModifier : NSObject <CSTextLinePositionModifier>
@property (assign) CGFloat fixedLineHeight; ///< 固定线高度(两条基线之间的距离).
@end



















/**
 CSTextLayout类是一个只读类存储文本布局结果.
 此类中的所有属性都是只读的,不应该被更改.
 这个类中的方法是线程安全的(除了一些绘图方法).
 示例:(带有排除路径的布局)
 
 ┌──────────────────────────┐  <------ 容器
 │ [--------Line0--------]  │  <- Row0
 │ [--------Line1--------]  │  <- Row1
 │ [-Line2-]     [-Line3-]  │  <- Row2
 │ [-Line4]       [Line5-]  │  <- Row3
 │ [-Line6-]     [-Line7-]  │  <- Row4
 │ [--------Line8--------]  │  <- Row5
 │ [--------Line9--------]  │  <- Row6
 └──────────────────────────┘
 */
@interface CSTextLayout : NSObject


///MARK: ===================================================
///MARK: 生成文本布局
///MARK: ===================================================

+ (CSTextLayout *)layout:(UIFont *)font color:(UIColor*)color width:(CGFloat )width string:(NSString *)string max:(BOOL)max;

/**
 使用给定的容器大小和文本生成布局
 
 @param size 尺寸
 @param text 文本
 @return 布局类,发生错误是为 nil
 */
+ (nullable CSTextLayout *)layoutWithContainerSize:(CGSize)size
                                                text:(NSAttributedString *)text;


/**
 使用给定的容器和文本生成布局
 
 @param container 容器,如果传入 nil, 该方法则返回 nil
 @param text 文本
 @return 布局类,发生错误是为 nil
 */
+ (nullable CSTextLayout *)layoutWithContainer:(CSTextContainer *)container
                                            text:(NSAttributedString *)text;


/**
 使用给定的容器和文本生成布局
 
 @param container 容器,如果传入 nil, 该方法则返回 nil
 @param text 文本
 @param range 文本范围.(如果超出范围,则返回nil; 如果范围的长度为0,则表示长度无限制)
 @return 布局类,发生错误是为 nil
 */
+ (nullable CSTextLayout *)layoutWithContainer:(CSTextContainer *)container
                                            text:(NSAttributedString *)text
                                           range:(NSRange)range;


/**
 使用给定的容器和文本生成布局
 参数如果传入 nil, 该方法则返回 nil
 
 @param containers 容器对象
 @param text  文本
 @return CSTextLayout对象数组(计数与容器相同),发生错误则返回 nil
 */
+ (nullable NSArray<CSTextLayout *> *)layoutWithContainers:(NSArray<CSTextContainer *> *)containers
                                                        text:(NSAttributedString *)text;


/**
 使用给定的容器和文本生成布局
 参数如果传入 nil, 该方法则返回 nil
 
 @param containers 容器对象
 @param text  文本
 @param range 文本范围.(如果超出范围,则返回nil; 如果范围的长度为0,则表示长度无限制)
 @return CSTextLayout对象数组(计数与容器相同),发生错误则返回 nil
 */
+ (nullable NSArray<CSTextLayout *> *)layoutWithContainers:(NSArray<CSTextContainer *> *)containers
                                                        text:(NSAttributedString *)text
                                                       range:(NSRange)range;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;


///MARK: ===================================================
///MARK: 文本布局属性
///MARK: ===================================================

///< 文本容器
@property (nonatomic, strong, readonly) CSTextContainer *container;
///< 文本
@property (nonatomic, strong, readonly) NSAttributedString *text;
///< 在文本中的文本范围
@property (nonatomic, readonly) NSRange range;
///< CTFrameSetter
@property (nonatomic, readonly) CTFramesetterRef frameSetter;
///< CTFrame
@property (nonatomic, readonly) CTFrameRef frame;
///< CSTextLine 的数组，没有截断
@property (nonatomic, strong, readonly) NSArray<CSTextLine *> *lines;
///< 具有截断令牌的CSTextLine,或nil
@property (nullable, nonatomic, strong, readonly) CSTextLine *truncatedLine;
///< CSTextAttachment的数组
@property (nullable, nonatomic, strong, readonly) NSArray<CSTextAttachment *> *attachments;
///< 文本中NSRange(由NSValue包装)的数组
@property (nullable, nonatomic, strong, readonly) NSArray<NSValue *> *attachmentRanges;
///< 在容器中的CGRect数组(由NSValue包装)
@property (nullable, nonatomic, strong, readonly) NSArray<NSValue *> *attachmentRects;
///< 设置附件的集合 (UIImage/UIView/CALayer)
@property (nullable, nonatomic, strong, readonly) NSSet *attachmentContentsSet;
///< 行数
@property (nonatomic, readonly) NSUInteger rowCount;
///< 可见文本范围
@property (nonatomic, readonly) NSRange visibleRange;
///< Bounding rect (glyphs)
@property (nonatomic, readonly) CGRect textBoundingRect;
///< Bounding size (glyphs and insets, ceil to pixel)
@property (nonatomic, readonly) CGSize textBoundingSize;
///< Has highlight attribute
@property (nonatomic, readonly) BOOL containsHighlight;
///< Has block border attribute
@property (nonatomic, readonly) BOOL needDrawBlockBorder;
///< Has background border attribute
@property (nonatomic, readonly) BOOL needDrawBackgroundBorder;
///< Has shadow attribute
@property (nonatomic, readonly) BOOL needDrawShadow;
///< Has underline attribute
@property (nonatomic, readonly) BOOL needDrawUnderline;
///< Has visible text
@property (nonatomic, readonly) BOOL needDrawText;
///< Has attachment attribute
@property (nonatomic, readonly) BOOL needDrawAttachment;
///< Has inner shadow attribute
@property (nonatomic, readonly) BOOL needDrawInnerShadow;
///< Has strickthrough attribute
@property (nonatomic, readonly) BOOL needDrawStrikethrough;
///< Has border attribute
@property (nonatomic, readonly) BOOL needDrawBorder;

///MARK: ===================================================
///MARK: 查询文本布局信息
///MARK: ===================================================
/**
 第一行索引.
 
 @param row  行索引.
 @return 行索引,如果没有找到NSNotFound.
 */
- (NSUInteger)lineIndexForRow:(NSUInteger)row;

/**
 行数.
 
 @param row  行索引.
 @return 行索引,如果发生错误则返回NSNotFound.
 */
- (NSUInteger)lineCountForRow:(NSUInteger)row;

/**
 对于行的行索引.
 
 @param line 行索引.
 @return 行索引,如果没有找到NSNotFound.
 */
- (NSUInteger)rowIndexForLine:(NSUInteger)line;

/**
 行索引为指定点.
 
 @discussion 如果有在该点没有文字,返回NSNotFound.
 @param point  容器中的一个点.
 @return 行索引,如果没有找到NSNotFound.
 */
- (NSUInteger)lineIndexForPoint:(CGPoint)point;

/**
 最接近指定点的行索引.
 
 @param point  容器中的一个点.
 @return 行索引,如果在布局中没有行,则为NSNotFound.
 */
- (NSUInteger)closestLineIndexForPoint:(CGPoint)point;

/**
 指定行中文本位置的容器中的偏移量.
 
 @discussion 偏移量是文本位置的基线point.x.如果容器是垂直形式,则偏移量为基线point.y
 
 @param position   字符串中的文本位置.
 @param lineIndex  行索引.
 @return 容器中的偏移量,如果未找到则为CGFLOAT_MAX.
 */
- (CGFloat)offsetForTextPosition:(NSUInteger)position lineIndex:(NSUInteger)lineIndex;

/**
 指定行中某个点的文本位置.
 
 @discussion 这个方法只是调用CTLineGetStringIndexForPosition()并且不考虑表情符号,换行符,绑定文本...
 
 @param point      容器中的一个点.
 @param lineIndex  行索引.
 @return 文本位置,如果没有找到NSNotFound.
 */
- (NSUInteger)textPositionForPoint:(CGPoint)point lineIndex:(NSUInteger)lineIndex;

/**
 与指定点最近的文本位置.
 
 @discussion 这种方法考虑了表情符号,换行符,绑定文本和文本亲和度的限制.
 
 @param point  容器中的一个点.
 @return 文本位置,如果没有找到,则为nil.
 */
- (nullable CSTextPosition *)closestPositionToPoint:(CGPoint)point;

/**
 在文本视图中移动选择抓取器时返回新的位置.
 
 @discussion 在文本选择期间有两个抓取器,用户只能同时移动一个抓取器.
 
 @param point          容器中的point.
 @param oldPosition    移动抓取器的旧文本位置.
 @param otherPosition  文本选择视图中的另一个位置.
 
 @return 文本位置,如果没有找到,则为nil.
 */
- (nullable CSTextPosition *)positionForPoint:(CGPoint)point
                                  oldPosition:(CSTextPosition *)oldPosition
                                otherPosition:(CSTextPosition *)otherPosition;

/**
 返回容器中给定点的字符或字符范围.如果该点没有文本,返回nil.
 
 @discussion 这种方法考虑了表情符号,换行符,绑定文本和文本亲和度的限制.
 
 @param point  容器中的point.
 @return 表示在点处包围字符(或字符)的范围的对象.如果没有找到则为 nil.
 */
- (nullable CSTextRange *)textRangeAtPoint:(CGPoint)point;

/**
 返回容器中给定点的最接近的字符或字符范围.
 
 @discussion 这种方法考虑了表情符号,换行符,绑定文本和文本亲和度的限制.
 
 @param point  容器中的point.
 @return 表示在点处包围字符(或字符)的范围的对象.如果没有找到则为 nil.
 */
- (nullable CSTextRange *)closestTextRangeAtPoint:(CGPoint)point;

/**
 如果位置在表情符号内,组合字符序列,换行符'\\r\\n'或自定义绑定范围内,则通过扩展位置返回范围.
 否则,从位置返回零长度范围
 
 @param position 标识布局位置的文本位置对象.
 @return 扩展位置的文本范围对象.如果发生错误,则返回 nil
 */
- (nullable CSTextRange *)textRangeByExtendingPosition:(CSTextPosition *)position;

/**
 从指定的方向返回给定偏移量的文本范围,从另一文本位置到布局的某个方向最远的范围.
 
 @param position  标识布局位置的文本位置对象.
 @param direction 表示布局方向的常数(右,左,上,下).
 @param offset    A character offset from position.
 
 @return 文本范围对象,表示从位置到在方向最远的程度的距离.如果发生错误则返回 nil.
 */
- (nullable CSTextRange *)textRangeByExtendingPosition:(CSTextPosition *)position
                                           inDirection:(UITextLayoutDirection)direction
                                                offset:(NSInteger)offset;

/**
 返回给定文本位置的行索引.
 
 @discussion 此方法考虑到文本的亲和性.
 @param position 标识布局位置的文本位置对象.
 @return 行索引,如果没有找到NSNotFound.
 */
- (NSUInteger)lineIndexForPosition:(CSTextPosition *)position;

/**
 返回基线位置对于给定的文本位置.
 
 @param position 标识布局中位置的对象.
 @return 文本的基准位置,如果没有找到,则为CGPointZero.
 */
- (CGPoint)linePositionForPosition:(CSTextPosition *)position;

/**
 返回用来绘制插入符的frame,在一个给定的插入点.
 
 @param position 标识布局中位置的对象.
 @return 定义用于绘制插入符区域的frame.正常容器中的宽度总是为0,垂直形式的容器中的高度总是为0
 如果没有找到,则返回CGRectNull.
 */
- (CGRect)caretRectForPosition:(CSTextPosition *)position;

/**
 返回在布局中包含文本范围的第一个frame.
 
 @param range 表示布局中文本范围的对象.
 @return 文字范围内的第一个frame.您可以使用此矩形绘制校正frame.当范围包含多行文本时,名称中的'第一'是指包围第一行的frame.
 如果没有找到,则返回CGRectNull.
 */
- (CGRect)firstRectForRange:(CSTextRange *)range;

/**
 返回在布局中包含文本范围的frame.
 
 @param range 表示布局中文本范围的对象.
 @return 指定范围区域的frame.如果没有找到,则返回CGRectNull.
 */
- (CGRect)rectForRange:(CSTextRange *)range;

/**
 返回对应文本中选择文本的rect数组.
 
 @param range 表示文本范围的对象.
 @return 包含选择的CSTextSelectionRect对象的数组.如果没有找到,则该数组为空.
 */
- (NSArray<CSTextSelectionRect *> *)selectionRectsForRange:(CSTextRange *)range;

/**
 返回对应文本中选择文本的rect数组.
 
 @param range 表示文本范围的对象.
 @return 包含选择的CSTextSelectionRect对象的数组.如果没有找到,则该数组为空.
 */
- (NSArray<CSTextSelectionRect *> *)selectionRectsWithoutStartAndEndForRange:(CSTextRange *)range;

/**
 返回对应的文本范围的开始和结束的选择rect.开始和结束矩形可以用来显示采集.
 
 @param range 示文本范围的对象.
 @return CSTextSelectionRect对象的数组包含选择的开始和结束.如果没有找到,则该数组为空.
 */
- (NSArray<CSTextSelectionRect *> *)selectionRectsWithOnlyStartAndEndForRange:(CSTextRange *)range;


///MARK: ===================================================
///MARK: 绘制文本布局
///MARK: ===================================================
/**
 绘制布局并显示附件.
 
 @discussion
 如果'view'参数不是nil,则附件视图将添加到该'view',
 并且如果'layer'参数不是nil,则附着层将添加到该'layer'.
 
 @warning
 此方法应该在主线程上调用,如果'view'或'layer'参数不是nil和有UIView的或CALayer的附件中的布局.
 否则,它可以在任何线程上调用.
 
 @param context 绘制上下文.传递nil以避免文字和图像绘制.
 @param size    上下文尺寸.
 @param point   绘制布局的点.
 @param view    附件视图将添加到此视图.
 @param layer   附件层将添加到该层.
 @param debug   调试选项,传递 nil, 可避免调试.
 @param cancel  取消检查程序块.它会在绘制进度被调用.如果返回YES,则进一步的绘制进度将被取消.通过nil忽略此功能.
 */
- (void)drawInContext:(nullable CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
                 view:(nullable UIView *)view
                layer:(nullable CALayer *)layer
                debug:(nullable CSTextDebugOption *)debug
               cancel:(nullable BOOL (^)(void))cancel;

/**
 绘制布局文本和图像(无视图或图层附件).
 
 @discussion 这个方法是线程安全的,可以在任何线程上调用.
 
 @param context 绘制上下文.传递nil以避免文字和图像绘制.
 @param size    上下文尺寸.
 @param debug   调试选项,传递 nil, 可避免调试.
 */
- (void)drawInContext:(nullable CGContextRef)context
                 size:(CGSize)size
                debug:(nullable CSTextDebugOption *)debug;
/**
 显示视图和图层附件.
 
 @warning 这个方法必须在主线程上调用.
 @param view  附件视图将添加到此视图.
 @param layer 附件层将添加到该层.
 */
- (void)addAttachmentToView:(nullable UIView *)view layer:(nullable CALayer *)layer;

/**
 从父容器中删除附件视图和图层.
 
 @warning 这个方法必须在主线程上调用.
 */
- (void)removeAttachmentFromViewAndLayer;

@end










NS_ASSUME_NONNULL_END







