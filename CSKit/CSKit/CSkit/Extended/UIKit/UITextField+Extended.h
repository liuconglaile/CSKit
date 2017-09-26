//
//  UITextField+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ShakeCompletion)(void);

typedef NS_ENUM(NSUInteger, CSShakedDirection) {
    CSShakedDirectionHorizontal,
    CSShakedDirectionVertical
};

@interface UITextField (Extended)

/**
 加载 textfiled 输入历史
 
 @return 该文本字段的标识
 */
- (NSArray*)loadHistroy;

/**
 *  保存当前输入文本
 */
- (void)synchronize;

- (void)showHistory;
- (void)hideHistroy;

- (void)clearHistory;


/**
 当前选中的字符串范围
 
 @return NSRange
 */
- (NSRange)selectedRange;
/**
 选中所有文字
 */
- (void)selectAllText;
/**
 选中指定范围的文字
 
 @param range NSRange范围
 */
- (void)setSelectedRange:(NSRange)range;


//MARK:抖动
- (void)shake;
- (void)shake:(int)times withDelta:(CGFloat)delta;
- (void)shake:(int)times withDelta:(CGFloat)delta completion:(nullable ShakeCompletion)handler;
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval;
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(nullable ShakeCompletion)handler;
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(CSShakedDirection)shakeDirection;
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(CSShakedDirection)shakeDirection completion:(nullable ShakeCompletion)handler;



///MARK: =============================================================
///MARK: 代理转回调
///MARK: =============================================================
@property (copy, nonatomic) BOOL (^shouldBegindEditingBlock)(UITextField *textField);
@property (copy, nonatomic) BOOL (^shouldEndEditingBlock)(UITextField *textField);
@property (copy, nonatomic) void (^didBeginEditingBlock)(UITextField *textField);
@property (copy, nonatomic) void (^didEndEditingBlock)(UITextField *textField);
@property (copy, nonatomic) BOOL (^shouldChangeCharactersInRangeBlock)(UITextField *textField, NSRange range, NSString *replacementString);
@property (copy, nonatomic) BOOL (^shouldReturnBlock)(UITextField *textField);
@property (copy, nonatomic) BOOL (^shouldClearBlock)(UITextField *textField);

- (void)setShouldBegindEditingBlock:(BOOL (^)(UITextField *textField))shouldBegindEditingBlock;
- (void)setShouldEndEditingBlock:(BOOL (^)(UITextField *textField))shouldEndEditingBlock;
- (void)setDidBeginEditingBlock:(void (^)(UITextField *textField))didBeginEditingBlock;
- (void)setDidEndEditingBlock:(void (^)(UITextField *textField))didEndEditingBlock;
- (void)setShouldChangeCharactersInRangeBlock:(BOOL (^)(UITextField *textField, NSRange range, NSString *string))shouldChangeCharactersInRangeBlock;
- (void)setShouldClearBlock:(BOOL (^)(UITextField *textField))shouldClearBlock;
- (void)setShouldReturnBlock:(BOOL (^)(UITextField *textField))shouldReturnBlock;



@end

NS_ASSUME_NONNULL_END
