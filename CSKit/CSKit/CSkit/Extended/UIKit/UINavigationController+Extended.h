//
//  UINavigationController+Extended.h
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Extended)
<UIGestureRecognizerDelegate>

/**
 *  @brief  寻找Navigation中的某个viewcontroler对象
 *
 *  @param className viewcontroler名称
 *
 *  @return viewcontroler对象
 */
- (id)findViewController:(NSString*)className;
/**
 *  @brief  判断是否只有一个RootViewController
 *
 *  @return 是否只有一个RootViewController
 */
- (BOOL)isOnlyContainRootViewController;
/**
 *  @brief  RootViewController
 *
 *  @return RootViewController
 */
//- (UIViewController *)rootViewController;
/**
 *  @brief  返回指定的viewcontroler
 *
 *  @param className 指定viewcontroler类名
 *  @param animated  是否动画
 *
 *  @return pop之后的viewcontrolers
 */
//- (NSArray *)popToViewControllerWithClassName:(NSString*)className animated:(BOOL)animated;
/**
 *  @brief  pop n层
 *
 *  @param level  n层
 *  @param animated  是否动画
 *
 *  @return pop之后的viewcontrolers
 */
//- (NSArray *)popToViewControllerWithLevel:(NSInteger)level animated:(BOOL)animated;


// 带模态的 push
//- (void)pushViewController:(UIViewController *)controller withTransition:(UIViewAnimationTransition)transition;
// 带模态的 pop
//- (UIViewController *)popViewControllerWithTransition:(UIViewAnimationTransition)transition;

-(void)showDropMenu:(UIView *)menu animated:(BOOL)animated;

-(void)hideDroppedMenuAnimated:(BOOL)animated;

- (void)dropShadowWithOffset:(CGSize)offset radius:(CGFloat)radius color:(UIColor *)color opacity:(CGFloat)opacity;

@end
