//
//  UITextView+Extended.m
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UITextView+Extended.h"
#import "objc/runtime.h"

static int minFontSizeKey;
static int maxFontSizeKey;
static int zoomEnabledKey;
static const char *_placeHolderTextView = "placeHolderTextView";

@implementation UITextView (Extended)

- (void)setMaxFontSize:(CGFloat)maxFontSize
{
    objc_setAssociatedObject(self, &maxFontSizeKey, [NSNumber numberWithFloat:maxFontSize],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)maxFontSize
{
    return [objc_getAssociatedObject(self, &maxFontSizeKey) floatValue];
}

- (void)setMinFontSize:(CGFloat)maxFontSize
{
    objc_setAssociatedObject(self, &minFontSizeKey, [NSNumber numberWithFloat:maxFontSize],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)minFontSize
{
    return [objc_getAssociatedObject(self, &minFontSizeKey) floatValue];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if (!self.isZoomEnabled) return;
    
    CGFloat pointSize = (gestureRecognizer.velocity > 0.0f ? 1.0f : -1.0f) + self.font.pointSize;
    
    pointSize = MAX(MIN(pointSize, self.maxFontSize), self.minFontSize);
    
    self.font = [UIFont fontWithName:self.font.fontName size:pointSize];
}


- (void)setZoomEnabled:(BOOL)zoomEnabled
{
    objc_setAssociatedObject(self, &zoomEnabledKey, [NSNumber numberWithBool:zoomEnabled],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (zoomEnabled) {
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers) // initialized already
            if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) return;
        
        self.minFontSize = self.minFontSize ?: 8.0f;
        self.maxFontSize = self.maxFontSize ?: 42.0f;
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(pinchGesture:)];
        [self addGestureRecognizer:pinchRecognizer];
#if !__has_feature(objc_arc)
        [pinchRecognizer release];
#endif
    }
}

- (BOOL)isZoomEnabled
{
    return [objc_getAssociatedObject(self, &zoomEnabledKey) boolValue];
}



- (UITextView *)placeHolderTextView {
    return objc_getAssociatedObject(self, _placeHolderTextView);
}
- (void)setPlaceHolderTextView:(UITextView *)placeHolderTextView {
    objc_setAssociatedObject(self, _placeHolderTextView, placeHolderTextView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)addPlaceHolder:(NSString *)placeHolder {
    if (![self placeHolderTextView]) {
        self.delegate = self;
        UITextView *textView = [[UITextView alloc] initWithFrame:self.bounds];
        textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        textView.font = self.font;
        textView.backgroundColor = [UIColor clearColor];
        textView.textColor = [UIColor grayColor];
        textView.userInteractionEnabled = NO;
        textView.text = placeHolder;
        [self addSubview:textView];
        [self setPlaceHolderTextView:textView];
    }
}
# pragma mark -
# pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.placeHolderTextView.hidden = YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text && [textView.text isEqualToString:@""]) {
        self.placeHolderTextView.hidden = NO;
    }
}






/**
 *  @brief  当前选中的字符串范围
 *
 *  @return NSRange
 */
- (NSRange)selectedRange
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}
/**
 *  @brief  选中所有文字
 */
- (void)selectAllText {
    UITextRange *range = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}
/**
 *  @brief  选中指定范围的文字
 *
 *  @param range NSRange范围
 */
- (void)setSelectedRange:(NSRange)range {
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}
//https://github.com/pclion/TextViewCalculateLength
// 用于计算textview输入情况下的字符数，解决实现限制字符数时，计算不准的问题

- (NSInteger)getInputLengthWithText:(NSString *)text{
    NSInteger textLength = 0;
    //获取高亮部分
    UITextRange *selectedRange = [self markedTextRange];
    if (selectedRange) {
        NSString *newText = [self textInRange:selectedRange];
        textLength = (newText.length + 1) / 2 + [self offsetFromPosition:self.beginningOfDocument toPosition:selectedRange.start] + text.length;
    } else {
        textLength = self.text.length + text.length;
    }
    return textLength;
}

@end


