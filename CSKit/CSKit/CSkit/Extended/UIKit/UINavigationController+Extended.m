//
//  UINavigationController+Extended.m
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UINavigationController+Extended.h"
#import <objc/runtime.h>

static char tlNavigationControllerDroppedMenu;

@implementation UINavigationController (Extended)

// 这解决的问题与键盘不解雇iPad的登录屏幕上.
// http://stackoverflow.com/questions/3372333/ipad-keyboard-will-not-dismiss-if-modal-view-controller-presentation-style-is-ui/3386768#3386768
// http://developer.apple.com/library/ios/#documentation/uikit/reference/UIViewController_Class/Reference/Reference.html
// 禁用自动键盘解雇
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}


/**
 *  @brief  寻找Navigation中的某个viewcontroler对象
 *
 *  @param className viewcontroler名称
 *
 *  @return viewcontroler对象
 */
- (id)findViewController:(NSString*)className
{
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isKindOfClass:NSClassFromString(className)]) {
            return viewController;
        }
    }
    
    return nil;
}
/**
 *  @brief  判断是否只有一个RootViewController
 *
 *  @return 是否只有一个RootViewController
 */
- (BOOL)isOnlyContainRootViewController
{
    if (self.viewControllers &&
        self.viewControllers.count == 1) {
        return YES;
    }
    return NO;
}
/**
 *  @brief  RootViewController
 *
 *  @return RootViewController
 */
//- (UIViewController *)rootViewController
//{
//    if (self.viewControllers && [self.viewControllers count] >0) {
//        return [self.viewControllers firstObject];
//    }
//    return nil;
//}
/**
 *  @brief  返回指定的viewcontroler
 *
 *  @param className 指定viewcontroler类名
 *  @param animated  是否动画
 *
 *  @return pop之后的viewcontrolers
 */
- (NSArray *)popToViewControllerWithClassName:(NSString*)className animated:(BOOL)animated;
{
    return [self popToViewController:[self findViewController:className] animated:YES];
}
///**
// *  @brief  pop n层
// *
// *  @param level  n层
// *  @param animated  是否动画
// *
// *  @return pop之后的viewcontrolers
// */
//- (NSArray *)popToViewControllerWithLevel:(NSInteger)level animated:(BOOL)animated
//{
//    NSInteger viewControllersCount = self.viewControllers.count;
//    if (viewControllersCount > level) {
//        NSInteger idx = viewControllersCount - level - 1;
//        UIViewController *viewController = self.viewControllers[idx];
//        return [self popToViewController:viewController animated:animated];
//    } else {
//        return [self popToRootViewControllerAnimated:animated];
//    }
//}

//- (void)pushViewController:(UIViewController *)controller withTransition:(UIViewAnimationTransition)transition {
////    [UIView beginAnimations:nil context:NULL];
////    [self pushViewController:controller animated:NO];
////    [UIView setAnimationDuration:0.5];
////    [UIView setAnimationBeginsFromCurrentState:YES];
////    [UIView setAnimationTransition:transition forView:self.view cache:YES];
////    [UIView commitAnimations];
//}

//- (UIViewController *)popViewControllerWithTransition:(UIViewAnimationTransition)transition {
////    if (transition == UIViewAnimationTransitionFlipFromRight) {
//        return [self popViewControllerAnimated:NO];
////    }else{
////        [UIView beginAnimations:nil context:NULL];
////        UIViewController *controller = [self popViewControllerAnimated:NO];
////        [UIView setAnimationDuration:0.5];
////        [UIView setAnimationBeginsFromCurrentState:YES];
////        [UIView setAnimationTransition:transition forView:self.view cache:YES];
////        [UIView commitAnimations];
////        return controller;
////    }
//}


- (void)showDropMenu:(UIView *)menu
            animated:(BOOL)animated
{
    [self hideDroppedMenuAnimated:NO];
    
    __block CGRect frame;
    CGRect frame1 = self.topViewController.view.frame;
    
    frame1.origin.y = 10;
    UIView *droppedMenu = [[UIView alloc] initWithFrame:frame1];
    droppedMenu.tag = 999999;
    objc_setAssociatedObject( self, &tlNavigationControllerDroppedMenu, droppedMenu, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
    //UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeDroppedMenu)];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    tapGR.delegate=self;
    tapGR.numberOfTapsRequired=1;
    [droppedMenu addGestureRecognizer:tapGR];
    droppedMenu.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    [droppedMenu addSubview:menu];
    [menu setExclusiveTouch:YES];
    [self.topViewController.view addSubview:droppedMenu];
    
    frame = menu.frame;
    
    void (^animations) ( void ) = ^
    {
        droppedMenu.alpha = 1.0;
        frame.origin.y = 0;
        menu.frame = frame;
    };
    
    if ( animated )
    {
        droppedMenu.alpha = 0.0;
        
        frame.origin.y = -frame.size.height;
        menu.frame = frame;
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:animations completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        animations();
    }
}
-(void)removeDroppedMenu
{
    
}
- ( void ) hideDroppedMenuAnimated:(BOOL)animated
{
    UIView *droppedMenu = objc_getAssociatedObject( self, &tlNavigationControllerDroppedMenu );
    UIView *content = droppedMenu.subviews[0];
    
    void (^animations) ( void ) = ^
    {
        CGRect frame = content.frame;
        droppedMenu.alpha = 0.0;
        frame.origin.y = -frame.size.height;
        content.frame = frame;
    };
    
    void (^completion) ( BOOL ) = ^( BOOL completed )
    {
        for (UIView *droppedMenu in self.topViewController.view.subviews)
        {
            if (droppedMenu.tag == 999999)
            {
                [UIView animateWithDuration:0.2
                                 animations:^{droppedMenu.alpha = 0.0;}
                                 completion:^(BOOL finished){  [droppedMenu removeFromSuperview];;
                                     [[droppedMenu subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                     [droppedMenu removeFromSuperview];
                                     objc_setAssociatedObject( self, &tlNavigationControllerDroppedMenu, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
                                     
                                 }];
                
            }
        }
    };
    
    
    
    if ( animated )
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:animations completion:completion];
    }
    else
    {
        animations();
        completion( YES );
    }
    
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != [self.topViewController.view viewWithTag:999999])
    {
        // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}
-(void)tapGestureHandler:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];
    UIView *viewTouched = [sender.view hitTest:point withEvent:nil];
    if (viewTouched.tag ==999999)
    {
        [self hideDroppedMenuAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"clickedMainMenu" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"clickedHomeMenu" object:nil];
    }
    else
    {
        
    }
}

- (void)dropShadowWithOffset:(CGSize)offset
                      radius:(CGFloat)radius
                       color:(UIColor *)color
                     opacity:(CGFloat)opacity {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.navigationBar.bounds);
    self.navigationBar.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.navigationBar.layer.shadowColor = color.CGColor;
    self.navigationBar.layer.shadowOffset = offset;
    self.navigationBar.layer.shadowRadius = radius;
    self.navigationBar.layer.shadowOpacity = opacity;
    
    self.navigationBar.clipsToBounds = NO;
    
}

@end
