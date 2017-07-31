//
//  UITabBarController+Extended.m
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UITabBarController+Extended.h"

#define TABBAR_HEIGHT (49)
@implementation UITabBarController (Extended)

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if ( [self.view.subviews count] < 1 )
        return;
    
    UIView *contentView = [self.view.subviews objectAtIndex:0];
    
    
    if(hidden)
    {
        if (animated) {
            [UIView beginAnimations:@"com.between.tabbar.hidden" context:nil];
            [UIView setAnimationDuration:0.35];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
        }
        
        contentView.frame = self.view.bounds;
        self.tabBar.frame = CGRectMake(self.view.bounds.origin.x,
                                       self.view.bounds.size.height,
                                       self.view.bounds.size.width,
                                       TABBAR_HEIGHT);
        
        if (animated) {
            [UIView commitAnimations];
        }
        
    }else{//show
        
        if (!animated) {
            contentView.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height - TABBAR_HEIGHT);
            self.tabBar.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.size.height - TABBAR_HEIGHT,
                                           self.view.bounds.size.width,
                                           TABBAR_HEIGHT);
            return;
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            self.tabBar.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.size.height - TABBAR_HEIGHT,
                                           self.view.bounds.size.width,
                                           TABBAR_HEIGHT);
        } completion:^(BOOL finished) {
            //这个不能放到动画块中，不然动画时会看到tabbarVC后面View的内容(或颜色)
            contentView.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height - TABBAR_HEIGHT);
        }];
        
    }
}

@end
