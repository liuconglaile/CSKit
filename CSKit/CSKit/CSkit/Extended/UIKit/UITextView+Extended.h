//
//  UITextView+Extended.h
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Extended)<UITextViewDelegate>
/** 最大最小字体 (使用示例1-1) */
@property (nonatomic) CGFloat maxFontSize, minFontSize;
@property (nonatomic, getter = isZoomEnabled) BOOL zoomEnabled;
@property (nonatomic, strong) UITextView *placeHolderTextView;


// 添加占位符
- (void)addPlaceHolder:(NSString *)placeHolder;


/** 当前选中的字符串范围 */
- (NSRange)selectedRange;
/** 选中所有文字 */
- (void)selectAllText;
/** 选中指定范围的文字 */
- (void)setSelectedRange:(NSRange)range;



//https://github.com/pclion/TextViewCalculateLength
// 用于计算textview输入情况下的字符数,解决实现限制字符数时,计算不准的问题

/**
 计算textview输入情况下的字符数 (使用示例1-2)
 解决实现限制字符数时,计算不准的问题
 参考:https://github.com/pclion/TextViewCalculateLength
 
 @param text 需要计算的内容
 @return 字符数
 */
- (NSInteger)getInputLengthWithText:(NSString *)text;


@end


///MARK: 使用示例 1-1
/**
 
 UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame];
 [self.view addSubview:textView];
 textView.zoomEnabled = YES;
 textView.minFontSize = 10;
 textView.maxFontSize = 40;
 
 */


///MARK: 使用示例 1-2
/**
 
 - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
 
    NSInteger textLength = [textView getInputLengthWithText:text];
     if (textLength > 20) {
         //超过20个字可以删除
         if ([text isEqualToString:@""]) {
             return YES;
         }
        return NO;
     }
    return YES;
 }
 
 - (void)textViewDidChange:(UITextView *)textView {
     if ([textView getInputLengthWithText:nil] > 20) {
         textView.text = [textView.text substringToIndex:20];
     }
 }
 
 */

