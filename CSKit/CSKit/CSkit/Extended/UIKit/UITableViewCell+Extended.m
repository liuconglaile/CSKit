//
//  UITableViewCell+Extended.m
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UITableViewCell+Extended.h"

@implementation UITableViewCell (Extended)

- (UIScrollView*)scrollView
{
    id sv = self.contentView.superview;
    while ( ![sv isKindOfClass: [UIScrollView class]] && sv != self )
    {
        sv = [sv superview];
    }
    
    return sv == self ? nil : sv;
}

- (void) setDelaysContentTouches:(BOOL)delaysContentTouches
{
    [self willChangeValueForKey: @"delaysContentTouches"];
    
    [[self scrollView] setDelaysContentTouches: delaysContentTouches];
    
    [self didChangeValueForKey: @"delaysContentTouches"];
}

- (BOOL)delaysContentTouches
{
    return [[self scrollView] delaysContentTouches];
}


/** 加载同类名的 nib */
+ (UINib*)nib{
    return  [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

@end


