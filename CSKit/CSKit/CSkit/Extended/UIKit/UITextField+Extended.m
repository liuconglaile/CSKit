//
//  UITextField+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UITextField+Extended.h"
#import <objc/runtime.h>
#import "CSKitMacro.h"

CSSYNTH_DUMMY_CLASS(UITextField_Extended)


#define history_X(view) (view.frame.origin.x)
#define history_Y(view) (view.frame.origin.y)
#define history_W(view) (view.frame.size.width)
#define history_H(view) (view.frame.size.height)

static char kTextFieldIdentifyKey;
static char kTextFieldHistoryviewIdentifyKey;

#define ANIMATION_DURATION 0.3f
#define ITEM_HEIGHT 40
#define CLEAR_BUTTON_HEIGHT 45
#define MAX_HEIGHT 300

typedef BOOL (^UITextFieldReturnBlock) (UITextField *textField);
typedef void (^UITextFieldVoidBlock) (UITextField *textField);
typedef BOOL (^UITextFieldCharacterChangeBlock) (UITextField *textField, NSRange range, NSString *replacementString);


@interface UITextField ()<UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) UITableView *historyTableView;

@end

@implementation UITextField (Extended)

- (NSString*)identify {
    return objc_getAssociatedObject(self, &kTextFieldIdentifyKey);
}

- (void)setIdentify:(NSString *)identify {
    objc_setAssociatedObject(self, &kTextFieldIdentifyKey, identify, OBJC_ASSOCIATION_RETAIN);
}

- (UITableView*)historyTableView {
    UITableView* table = objc_getAssociatedObject(self, &kTextFieldHistoryviewIdentifyKey);
    
    if (table == nil) {
        table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITextFieldHistoryCell"];
        table.layer.borderColor = [UIColor grayColor].CGColor;
        table.layer.borderWidth = 1;
        table.delegate = self;
        table.dataSource = self;
        objc_setAssociatedObject(self, &kTextFieldHistoryviewIdentifyKey, table, OBJC_ASSOCIATION_RETAIN);
    }
    
    return table;
}

- (NSArray*)loadHistroy {
    if (self.identify == nil) {
        return nil;
    }
    
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSDictionary* dic = [def objectForKey:@"UITextField+JKHistory"];
    
    if (dic != nil) {
        return [dic objectForKey:self.identify];
    }
    
    return nil;
}

- (void)synchronize {
    if (self.identify == nil || [self.text length] == 0) {
        return;
    }
    
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSDictionary* dic = [def objectForKey:@"UITextField+JKHistory"];
    NSArray* history = [dic objectForKey:self.identify];
    
    NSMutableArray* newHistory = [NSMutableArray arrayWithArray:history];
    
    __block BOOL haveSameRecord = false;
    __weak typeof(self) weakSelf = self;
    
    [newHistory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([(NSString*)obj isEqualToString:weakSelf.text]) {
            *stop = true;
            haveSameRecord = true;
        }
    }];
    
    if (haveSameRecord) {
        return;
    }
    
    [newHistory addObject:self.text];
    
    NSMutableDictionary* dic2 = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dic2 setObject:newHistory forKey:self.identify];
    
    [def setObject:dic2 forKey:@"UITextField+JKHistory"];
    
    [def synchronize];
}

- (void) showHistory; {
    NSArray* history = [self loadHistroy];
    
    if (self.historyTableView.superview != nil || history == nil || history.count == 0) {
        return;
    }
    
    CGRect frame1 = CGRectMake(history_X(self), history_Y(self) + history_H(self) + 1, history_W(self), 1);
    CGRect frame2 = CGRectMake(history_X(self), history_Y(self) + history_H(self) + 1, history_W(self), MIN(MAX_HEIGHT, ITEM_HEIGHT * history.count + CLEAR_BUTTON_HEIGHT));
    
    self.historyTableView.frame = frame1;
    
    [self.superview addSubview:self.historyTableView];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.historyTableView.frame = frame2;
    }];
}

- (void) clearHistoryButtonClick:(UIButton*) button {
    [self clearHistory];
    [self hideHistroy];
}

- (void)hideHistroy; {
    if (self.historyTableView.superview == nil) {
        return;
    }
    
    CGRect frame1 = CGRectMake(history_X(self), history_Y(self) + history_H(self) + 1, history_W(self), 1);
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.historyTableView.frame = frame1;
    } completion:^(BOOL finished) {
        [self.historyTableView removeFromSuperview];
    }];
}

- (void) clearHistory; {
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    
    [def setObject:nil forKey:@"UITextField+JKHistory"];
    [def synchronize];
}


#pragma mark tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; {
    return 1;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section; {
    return [self loadHistroy].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITextFieldHistoryCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITextFieldHistoryCell"];
    }
    
    cell.textLabel.text = [self loadHistroy][indexPath.row];
    
    return cell;
}
#pragma clang diagnostic pop

#pragma mark tableview delegate
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section; {
    UIButton* clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearHistoryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return clearButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    return ITEM_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section; {
    return CLEAR_BUTTON_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath; {
    self.text = [self loadHistroy][indexPath.row];
    [self hideHistroy];
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








//MARK:抖动
- (void)shake {
    [self shake:10 withDelta:5 completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta {
    [self shake:times withDelta:delta completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta completion:(ShakeCompletion)handler {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:0.03 shakeDirection:CSShakedDirectionHorizontal completion:handler];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval {
    [self shake:times withDelta:delta speed:interval completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(ShakeCompletion)handler {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval shakeDirection:CSShakedDirectionHorizontal completion:handler];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(CSShakedDirection)shakeDirection {
    [self shake:times withDelta:delta speed:interval shakeDirection:shakeDirection completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(CSShakedDirection)shakeDirection completion:(ShakeCompletion)handler {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval shakeDirection:shakeDirection completion:handler];
}

- (void)_shake:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(CSShakedDirection)shakeDirection completion:(ShakeCompletion)handler {
    [UIView animateWithDuration:interval animations:^{
        self.transform = (shakeDirection == CSShakedDirectionHorizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction);
    } completion:^(BOOL finished) {
        if(current >= times) {
            [UIView animateWithDuration:interval animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (handler) {
                    handler();
                }
            }];
            return;
        }
        [self _shake:(times - 1)
           direction:direction * -1
        currentTimes:current + 1
           withDelta:delta
               speed:interval
      shakeDirection:shakeDirection
          completion:handler];
    }];
}







///MARK: =============================================================
///MARK: 代理转回调
///MARK: =============================================================
static const void *UITextFieldDelegateKey                      = &UITextFieldDelegateKey;
static const void *UITextFieldShouldBeginEditingKey            = &UITextFieldShouldBeginEditingKey;
static const void *UITextFieldShouldEndEditingKey              = &UITextFieldShouldEndEditingKey;
static const void *UITextFieldDidBeginEditingKey               = &UITextFieldDidBeginEditingKey;
static const void *UITextFieldDidEndEditingKey                 = &UITextFieldDidEndEditingKey;
static const void *UITextFieldShouldChangeCharactersInRangeKey = &UITextFieldShouldChangeCharactersInRangeKey;
static const void *UITextFieldShouldClearKey                   = &UITextFieldShouldClearKey;
static const void *UITextFieldShouldReturnKey                  = &UITextFieldShouldReturnKey;
#pragma mark UITextField Delegate methods
+ (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UITextFieldReturnBlock block = textField.shouldBegindEditingBlock;
    if (block) {
        return block(textField);
    }
    id delegate = objc_getAssociatedObject(self, UITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [delegate textFieldShouldBeginEditing:textField];
    }
    // return default value just in case
    return YES;
}
+ (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    UITextFieldReturnBlock block = textField.shouldEndEditingBlock;
    if (block) {
        return block(textField);
    }
    id delegate = objc_getAssociatedObject(self, UITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [delegate textFieldShouldEndEditing:textField];
    }
    // return default value just in case
    return YES;
}
+ (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITextFieldVoidBlock block = textField.didBeginEditingBlock;
    if (block) {
        block(textField);
    }
    id delegate = objc_getAssociatedObject(self, UITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [delegate textFieldDidBeginEditing:textField];
    }
}
+ (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITextFieldVoidBlock block = textField.didEndEditingBlock;
    if (block) {
        block(textField);
    }
    id delegate = objc_getAssociatedObject(self, UITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [delegate textFieldDidBeginEditing:textField];
    }
}
+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextFieldCharacterChangeBlock block = textField.shouldChangeCharactersInRangeBlock;
    if (block) {
        return block(textField,range,string);
    }
    id delegate = objc_getAssociatedObject(self, UITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}
+ (BOOL)textFieldShouldClear:(UITextField *)textField
{
    UITextFieldReturnBlock block = textField.shouldClearBlock;
    if (block) {
        return block(textField);
    }
    id delegate = objc_getAssociatedObject(self, UITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [delegate textFieldShouldClear:textField];
    }
    return YES;
}
+ (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextFieldReturnBlock block = textField.shouldReturnBlock;
    if (block) {
        return block(textField);
    }
    id delegate = objc_getAssociatedObject(self, UITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [delegate textFieldShouldReturn:textField];
    }
    return YES;
}
#pragma mark Block setting/getting methods
- (BOOL (^)(UITextField *))shouldBegindEditingBlock
{
    return objc_getAssociatedObject(self, UITextFieldShouldBeginEditingKey);
}
- (void)setShouldBegindEditingBlock:(BOOL (^)(UITextField *))shouldBegindEditingBlock
{
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldShouldBeginEditingKey, shouldBegindEditingBlock, OBJC_ASSOCIATION_COPY);
}
- (BOOL (^)(UITextField *))shouldEndEditingBlock
{
    return objc_getAssociatedObject(self, UITextFieldShouldEndEditingKey);
}
- (void)setShouldEndEditingBlock:(BOOL (^)(UITextField *))shouldEndEditingBlock
{
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldShouldEndEditingKey, shouldEndEditingBlock, OBJC_ASSOCIATION_COPY);
}
- (void (^)(UITextField *))didBeginEditingBlock
{
    return objc_getAssociatedObject(self, UITextFieldDidBeginEditingKey);
}
- (void)setDidBeginEditingBlock:(void (^)(UITextField *))didBeginEditingBlock
{
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldDidBeginEditingKey, didBeginEditingBlock, OBJC_ASSOCIATION_COPY);
}
- (void (^)(UITextField *))didEndEditingBlock
{
    return objc_getAssociatedObject(self, UITextFieldDidEndEditingKey);
}
- (void)setDidEndEditingBlock:(void (^)(UITextField *))didEndEditingBlock
{
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldDidEndEditingKey, didEndEditingBlock, OBJC_ASSOCIATION_COPY);
}
- (BOOL (^)(UITextField *, NSRange, NSString *))shouldChangeCharactersInRangeBlock
{
    return objc_getAssociatedObject(self, UITextFieldShouldChangeCharactersInRangeKey);
}
- (void)setShouldChangeCharactersInRangeBlock:(BOOL (^)(UITextField *, NSRange, NSString *))shouldChangeCharactersInRangeBlock
{
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldShouldChangeCharactersInRangeKey, shouldChangeCharactersInRangeBlock, OBJC_ASSOCIATION_COPY);
}
- (BOOL (^)(UITextField *))shouldReturnBlock
{
    return objc_getAssociatedObject(self, UITextFieldShouldReturnKey);
}
- (void)setShouldReturnBlock:(BOOL (^)(UITextField *))shouldReturnBlock
{
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldShouldReturnKey, shouldReturnBlock, OBJC_ASSOCIATION_COPY);
}
- (BOOL (^)(UITextField *))shouldClearBlock
{
    return objc_getAssociatedObject(self, UITextFieldShouldClearKey);
}
- (void)setShouldClearBlock:(BOOL (^)(UITextField *textField))shouldClearBlock
{
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldShouldClearKey, shouldClearBlock, OBJC_ASSOCIATION_COPY);
}
#pragma mark control method
/*
 Setting itself as delegate if no other delegate has been set. This ensures the UITextField will use blocks if no delegate is set.
 */
- (void)setDelegateIfNoDelegateSet
{
    if (self.delegate != (id<UITextFieldDelegate>)[self class]) {
        objc_setAssociatedObject(self, UITextFieldDelegateKey, self.delegate, OBJC_ASSOCIATION_ASSIGN);
        self.delegate = (id<UITextFieldDelegate>)[self class];
    }
}


@end




