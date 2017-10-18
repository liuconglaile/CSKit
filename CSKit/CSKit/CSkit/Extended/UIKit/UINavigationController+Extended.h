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
 显示下拉菜单(自定义 view)

 @param menu  自定义 View
 @param animated  动画
 */
-(void)showDropMenu:(UIView *)menu animated:(BOOL)animated;

-(void)hideDroppedMenuAnimated:(BOOL)animated;

- (void)dropShadowWithOffset:(CGSize)offset radius:(CGFloat)radius color:(UIColor *)color opacity:(CGFloat)opacity;

@end
