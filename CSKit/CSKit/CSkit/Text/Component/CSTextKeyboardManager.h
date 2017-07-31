//
//  CSTextKeyboardManager.h
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/**
 系统键盘转换信息.
 Use -[CSTextKeyboardManager convertRect:toView:] 到帧转换到指定的视图.
 */
typedef struct {
    BOOL fromVisible; ///< 键盘在转换前可见.
    BOOL toVisible;   ///< 键盘在转换后可见.
    CGRect fromFrame; ///< 转换前的键盘Frame.
    CGRect toFrame;   ///< 转换后的键盘Frame.
    NSTimeInterval animationDuration;       ///< 键盘转换动画持续时间.
    UIViewAnimationCurve animationCurve;    ///< 键盘转换动画曲线.
    UIViewAnimationOptions animationOption; ///< 键盘过渡动画选项.
} CSTextKeyboardTransition;






/**
 CSTextKeyboardObserver协议定义了可用于接收系统键盘更改信息的方法
 */
@protocol CSTextKeyboardObserver <NSObject>
@optional
- (void)keyboardChangedWithTransition:(CSTextKeyboardTransition)transition;
@end




/**
 CSTextKeyboardManager对象可以让您获得系统键盘信息，并跟踪键盘的 visible/frame/transition
 
 @discussion你应该在主线程中访问这个类.
 兼容:iPhone/iPad&iOS6/7/8/9
 */
@interface CSTextKeyboardManager : NSObject


- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/// 获取默认管理器(返回nil在应用程序扩展).
+ (nullable instancetype)defaultManager;

/// 获取键盘窗口.如果没有键盘窗口,则为nil.
@property (nullable, nonatomic, readonly) UIWindow *keyboardWindow;

/// 获取键盘视图.如果没有键盘视图,则为nil.
@property (nullable, nonatomic, readonly) UIView *keyboardView;

/// 键盘是否可见.
@property (nonatomic, readonly, getter=isKeyboardVisible) BOOL keyboardVisible;


///获取键盘frame. 如果没有键盘视图则返回CGRectNull。
///使用convertRect:toView:将frame转换为指定视图的frame.
@property (nonatomic, readonly) CGRect keyboardFrame;


/**
 向管理器添加观察者以获取键盘更改信息.
 这种方法使得对观察者的引用很弱.
 
 @param observer 观察者.
 如果观察者为零或已经添加,此方法将不起作用.
 */
- (void)addObserver:(id<CSTextKeyboardObserver>)observer;

/**
 从管理器中删除观察者.
 
 @param observer 观察者.
 如果观察者为零,或者不在管理者中,则此方法将不起作用.
 */
- (void)removeObserver:(id<CSTextKeyboardObserver>)observer;

/**
 将rect转换为指定视图或窗口的rect.
 就是获取指定视图的相对位置 Frame
 
 @param rect 原有Frame.
 @param view 视图指定的视图或window(转换为mainWindow传递nil).
 @return 在指定的视图转换的Frame.
 */
- (CGRect)convertRect:(CGRect)rect toView:(nullable UIView *)view;


@end
NS_ASSUME_NONNULL_END



