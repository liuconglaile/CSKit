//
//  CSLabel.h
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<CSKit/CSKit.h>)
#import <CSKit/CSTextParser.h>
#import <CSKit/CSTextLayout.h>
#import <CSKit/CSTextAttribute.h>
#else
#import "CSTextParser.h"
#import "CSTextLayout.h"
#import "CSTextAttribute.h"
#endif


NS_ASSUME_NONNULL_BEGIN

#if !TARGET_INTERFACE_BUILDER
//这个代码将在应用程序本身运行


/**
 该CSLabel类实现一个只读的文本视图.
  
 @discussion API和行为类似于UILabel，但提供了更多的功能：
  
 * 它支持异步布局和渲染(以避免阻塞UI线程).
 * 它扩展了CoreText属性以支持更多的文本效果.
 * 允许添加UIImage，UIView和CALayer作为文本附件.
 * 允许在某些范围的文本中添加“高亮”链接，以允许用户进行交互.
 * 它允许添加容器路径和排除路径来控制文本容器的形状.
 * 支持垂直格式布局显示CJK文本.
  
 请参阅NSAttributedString+CSText.h以获取更多便利的方法来设置属性.
 有关详细信息,请参阅CSTextAttachment.h和CSTextLayout.h.
 */
@interface CSLabel : UIView




#pragma mark - Accessing the Text Attributes
///=============================================================================
/// @name Accessing the Text Attributes
///=============================================================================

/**
 The text displayed by the label. Default is nil.
 Set a new value to this property also replaces the text in `attributedText`.
 Get the value returns the plain text in `attributedText`.
 */
@property (nullable, nonatomic, copy) NSString *text;

/**
 The font of the text. Default is 17-point system font.
 Set a new value to this property also causes the new font to be applied to the entire `attributedText`.
 Get the value returns the font at the head of `attributedText`.
 */
@property (null_resettable, nonatomic, strong) UIFont *font;

/**
 The color of the text. Default is black.
 Set a new value to this property also causes the new color to be applied to the entire `attributedText`.
 Get the value returns the color at the head of `attributedText`.
 */
@property (null_resettable, nonatomic, strong) UIColor *textColor;

/**
 The shadow color of the text. Default is nil.
 Set a new value to this property also causes the shadow color to be applied to the entire `attributedText`.
 Get the value returns the shadow color at the head of `attributedText`.
 */
@property (nullable, nonatomic, strong) UIColor *shadowColor;

/**
 The shadow offset of the text. Default is CGSizeZero.
 Set a new value to this property also causes the shadow offset to be applied to the entire `attributedText`.
 Get the value returns the shadow offset at the head of `attributedText`.
 */
@property (nonatomic) CGSize shadowOffset;

/**
 The shadow blur of the text. Default is 0.
 Set a new value to this property also causes the shadow blur to be applied to the entire `attributedText`.
 Get the value returns the shadow blur at the head of `attributedText`.
 */
@property (nonatomic) CGFloat shadowBlurRadius;

/**
 The technique to use for aligning the text. Default is NSTextAlignmentNatural.
 Set a new value to this property also causes the new alignment to be applied to the entire `attributedText`.
 Get the value returns the alignment at the head of `attributedText`.
 */
@property (nonatomic) NSTextAlignment textAlignment;

/**
 The text vertical aligmnent in container. Default is CSTextVerticalAlignmentCenter.
 */
@property (nonatomic) CSTextVerticalAlignment textVerticalAlignment;

/**
 The styled text displayed by the label.
 Set a new value to this property also replaces the value of the `text`, `font`, `textColor`,
 `textAlignment` and other properties in label.
 
 @discussion It only support the attributes declared in CoreText and CSTextAttribute.
 See `NSAttributedString+CSText` for more convenience methods to set the attributes.
 */
@property (nullable, nonatomic, copy) NSAttributedString *attributedText;

/**
 The technique to use for wrapping and truncating the label's text.
 Default is NSLineBreakByTruncatingTail.
 */
@property (nonatomic) NSLineBreakMode lineBreakMode;

/**
 The truncation token string used when text is truncated. Default is nil.
 When the value is nil, the label use "…" as default truncation token.
 */
@property (nullable, nonatomic, copy) NSAttributedString *truncationToken;

/**
 The maximum number of lines to use for rendering text. Default value is 1.
 0 means no limit.
 */
@property (nonatomic) NSUInteger numberOfLines;

/**
 When `text` or `attributedText` is changed, the parser will be called to modify the text.
 It can be used to add code highlighting or emoticon replacement to text view.
 The default value is nil.
 
 See `CSTextParser` protocol for more information.
 */
@property (nullable, nonatomic, strong) id<CSTextParser> textParser;

/**
 The current text layout in text view. It can be used to query the text layout information.
 Set a new value to this property also replaces most properties in this label, such as `text`,
 `color`, `attributedText`, `lineBreakMode`, `textContainerPath`, `exclusionPaths` and so on.
 */
@property (nullable, nonatomic, strong) CSTextLayout *textLayout;


#pragma mark - Configuring the Text Container
///=============================================================================
/// @name Configuring the Text Container
///=============================================================================

/**
 A UIBezierPath object that specifies the shape of the text frame. Default value is nil.
 */
@property (nullable, nonatomic, copy) UIBezierPath *textContainerPath;

/**
 An array of UIBezierPath objects representing the exclusion paths inside the
 receiver's bounding rectangle. Default value is nil.
 */
@property (nullable, nonatomic, copy) NSArray<UIBezierPath *> *exclusionPaths;

/**
 The inset of the text container's layout area within the text view's content area.
 Default value is UIEdgeInsetsZero.
 */
@property (nonatomic) UIEdgeInsets textContainerInset;

/**
 Whether the receiver's layout orientation is vertical form. Default is NO.
 It may used to display CJK text.
 */
@property (nonatomic, getter=isVerticalForm) BOOL verticalForm;

/**
 The text line position modifier used to modify the lines' position in layout.
 Default value is nil.
 See `CSTextLinePositionModifier` protocol for more information.
 */
@property (nullable, nonatomic, copy) id<CSTextLinePositionModifier> linePositionModifier;

/**
 The debug option to display CoreText layout result.
 The default value is [CSTextDebugOption sharedDebugOption].
 */
@property (nullable, nonatomic, copy) CSTextDebugOption *debugOption;


#pragma mark - Getting the Layout Constraints
///=============================================================================
/// @name Getting the Layout Constraints
///=============================================================================

/**
 The preferred maximum width (in points) for a multiline label.
 
 @discussion This property affects the size of the label when layout constraints
 are applied to it. During layout, if the text extends beyond the width
 specified by this property, the additional text is flowed to one or more new
 lines, thereby increasing the height of the label. If the text is vertical
 form, this value will match to text height.
 */
@property (nonatomic) CGFloat preferredMaxLayoutWidth;


#pragma mark - Interacting with Text Data
///=============================================================================
/// @name Interacting with Text Data
///=============================================================================

/**
 When user tap the label, this action will be called (similar to tap gesture).
 The default value is nil.
 */
@property (nullable, nonatomic, copy) CSTextAction textTapAction;

/**
 When user long press the label, this action will be called (similar to long press gesture).
 The default value is nil.
 */
@property (nullable, nonatomic, copy) CSTextAction textLongPressAction;

/**
 When user tap the highlight range of text, this action will be called.
 The default value is nil.
 */
@property (nullable, nonatomic, copy) CSTextAction highlightTapAction;

/**
 When user long press the highlight range of text, this action will be called.
 The default value is nil.
 */
@property (nullable, nonatomic, copy) CSTextAction highlightLongPressAction;


#pragma mark - Configuring the Display Mode
///=============================================================================
/// @name Configuring the Display Mode
///=============================================================================

/**
 A Boolean value indicating whether the layout and rendering codes are running
 asynchronously on background threads.
 
 The default value is `NO`.
 */
@property (nonatomic) BOOL displaysAsynchronously;

/**
 If the value is YES, and the layer is rendered asynchronously, then it will
 set label.layer.contents to nil before display.
 
 The default value is `YES`.
 
 @discussion When the asynchronously display is enabled, the layer's content will
 be updated after the background render process finished. If the render process
 can not finished in a vsync time (1/60 second), the old content will be still kept
 for display. You may manually clear the content by set the layer.contents to nil
 after you update the label's properties, or you can just set this property to YES.
 */
@property (nonatomic) BOOL clearContentsBeforeAsynchronouslyDisplay;

/**
 If the value is YES, and the layer is rendered asynchronously, then it will add
 a fade animation on layer when the contents of layer changed.
 
 The default value is `YES`.
 */
@property (nonatomic) BOOL fadeOnAsynchronouslyDisplay;

/**
 If the value is YES, then it will add a fade animation on layer when some range
 of text become highlighted.
 
 The default value is `YES`.
 */
@property (nonatomic) BOOL fadeOnHighlight;

/**
 Ignore common properties (such as text, font, textColor, attributedText...) and
 only use "textLayout" to display content.
 
 The default value is `NO`.
 
 @discussion If you control the label content only through "textLayout", then
 you may set this value to YES for higher performance.
 */
@property (nonatomic) BOOL ignoreCommonProperties;

/*
 Tips:
 
 1. If you only need a UILabel alternative to display rich text and receive link touch event,
 you do not need to adjust the display mode properties.
 
 2. If you have performance issues, you may enable the asynchronous display mode
 by setting the `displaysAsynchronously` to YES.
 
 3. If you want to get the highest performance, you should do text layout with
 `CSTextLayout` class in background thread. Here's an example:
 
 CSLabel *label = [CSLabel new];
 label.displaysAsynchronously = YES;
 label.ignoreCommonProperties = YES;
 
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 
 // Create attributed string.
 NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"Some Text"];
 text.font = [UIFont systemFontOfSize:16];
 text.color = [UIColor grayColor];
 [text setColor:[UIColor redColor] range:NSMakeRange(0, 4)];
 
 // Create text container
 CSTextContainer *container = [CSTextContainer new];
 container.size = CGSizeMake(100, CGFLOAT_MAX);
 container.maximumNumberOfRows = 0;
 
 // Generate a text layout.
 CSTextLayout *layout = [CSTextLayout layoutWithContainer:container text:text];
 
 dispatch_async(dispatch_get_main_queue(), ^{
 label.size = layout.textBoundingSize;
 label.textLayout = layout;
 });
 });
 
 */



@end
















#else // TARGET_INTERFACE_BUILDER
IB_DESIGNABLE
//这个代码只能在IB中执行










@interface CSLabel : UIView

@property (nullable, nonatomic, copy) IBInspectable NSString *text;
@property (null_resettable, nonatomic, strong) IBInspectable UIColor *textColor;
@property (nullable, nonatomic, strong) IBInspectable NSString *fontName_;
@property (nonatomic) IBInspectable CGFloat fontSize_;
@property (nonatomic) IBInspectable BOOL fontIsBold_;
@property (nonatomic) IBInspectable NSUInteger numberOfLines;
@property (nonatomic) IBInspectable NSInteger lineBreakMode;
@property (nonatomic) IBInspectable CGFloat preferredMaxLayoutWidth;
@property (nonatomic, getter=isVerticalForm) IBInspectable BOOL verticalForm;
@property (nonatomic) IBInspectable NSInteger textAlignment;
@property (nonatomic) IBInspectable NSInteger textVerticalAlignment;
@property (nullable, nonatomic, strong) IBInspectable UIColor *shadowColor;
@property (nonatomic) IBInspectable CGPoint shadowOffset;
@property (nonatomic) IBInspectable CGFloat shadowBlurRadius;
@property (nullable, nonatomic, copy) IBInspectable NSAttributedString *attributedText;
@property (nonatomic) IBInspectable CGFloat insetTop_;
@property (nonatomic) IBInspectable CGFloat insetBottom_;
@property (nonatomic) IBInspectable CGFloat insetLeft_;
@property (nonatomic) IBInspectable CGFloat insetRight_;
@property (nonatomic) IBInspectable BOOL debugEnabled_;

@property (null_resettable, nonatomic, strong) UIFont *font;
@property (nullable, nonatomic, copy) NSAttributedString *truncationToken;
@property (nullable, nonatomic, strong) id<CSTextParser> textParser;
@property (nullable, nonatomic, strong) CSTextLayout *textLayout;
@property (nullable, nonatomic, copy) UIBezierPath *textContainerPath;
@property (nullable, nonatomic, copy) NSArray<UIBezierPath *> *exclusionPaths;
@property (nonatomic) UIEdgeInsets textContainerInset;
@property (nullable, nonatomic, copy) id<CSTextLinePositionModifier> linePositionModifier;
@property (nonnull, nonatomic, copy) CSTextDebugOption *debugOption;
@property (nullable, nonatomic, copy) CSTextAction textTapAction;
@property (nullable, nonatomic, copy) CSTextAction textLongPressAction;
@property (nullable, nonatomic, copy) CSTextAction highlightTapAction;
@property (nullable, nonatomic, copy) CSTextAction highlightLongPressAction;
@property (nonatomic) BOOL displaysAsynchronously;
@property (nonatomic) BOOL clearContentsBeforeAsynchronouslyDisplay;
@property (nonatomic) BOOL fadeOnAsynchronouslyDisplay;
@property (nonatomic) BOOL fadeOnHighlight;
@property (nonatomic) BOOL ignoreCommonProperties;

@end
#endif // !TARGET_INTERFACE_BUILDER


NS_ASSUME_NONNULL_END



