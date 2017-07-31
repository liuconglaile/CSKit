//
//  CSTextParser.h
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



/**
 CSTextParser协议声明CSTextView和CSLabel在编辑期间修改文本所需的方法
 
 您可以实现此协议,为CSTextView和CSLabel添加代码突出显示或表情符号替换.
 请参见'CSTextSimpleMarkdownParser'和'CSTextSimpleEmoticonParser'.
 */
@protocol CSTextParser <NSObject>
@required

/**
 当在CSTextView或CSLabel中更改文本时,将调用此方法

 @param text 原始富文本字符串.此方法可以解析文本并更改文本属性或内容
 @param selectedRange 文本中当前所选范围.如果更改文本内容,此方法应该更正范围.如果没有选定范围(如CSLabel),则该值为NULL
 @return 如果在此方法中修改了'text',返回'YES',否则返回'NO'
 */
- (BOOL)parseText:(nullable NSMutableAttributedString *)text selectedRange:(nullable NSRangePointer)selectedRange;
@end








/**
 一个简单的markdown解析器.
 这是一个非常简单的markdown解析器,您可以使用此解析器突出显示一些小块的markdown文本.
  
 这个markdown解析器使用正则表达式来解析文本,慢和弱.如果你想写一个更好的解析器,尝试这些项目:
 https://github.com/NimbusKit/markdown
 https://github.com/dreamwieber/AttributedMarkdown
 https://github.com/indragiek/CocoaMarkdown
  
 或者您可以使用lex/yacc来生成自定义解析器.
 */
@interface CSTextSimpleMarkdownParser : NSObject <CSTextParser>
@property (nonatomic) CGFloat fontSize;         ///< default is 14
@property (nonatomic) CGFloat headerFontSize;   ///< default is 20

@property (nullable, nonatomic, strong) UIColor *textColor;
@property (nullable, nonatomic, strong) UIColor *controlTextColor;
@property (nullable, nonatomic, strong) UIColor *headerTextColor;
@property (nullable, nonatomic, strong) UIColor *inlineTextColor;
@property (nullable, nonatomic, strong) UIColor *codeTextColor;
@property (nullable, nonatomic, strong) UIColor *linkTextColor;

- (void)setColorWithBrightTheme; ///< 将颜色属性重置为预定义的值.
- (void)setColorWithDarkTheme;   ///< 将颜色属性重置为预定义的值.
@end










/**
 一个简单的表情符号解析器.
 
 使用此解析器将一些指定的字符串映射到图像表情符号.
 示例: "Hello :smile:"  ->  "Hello 😀"
 
 它也可以用来扩展"unicode表情符号".
 */
@interface CSTextSimpleEmoticonParser : NSObject <CSTextParser>

/**
 自定义表情符映射器。
 键是指定的简单字符串,例如@":smile:"。
 值是一个UIImage,它将替换文本中指定的纯字符串.
 */
@property (nullable, copy) NSDictionary<NSString *, __kindof UIImage *> *emoticonMapper;
@end







NS_ASSUME_NONNULL_END




