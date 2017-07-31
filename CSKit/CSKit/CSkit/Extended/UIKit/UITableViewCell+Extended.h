//
//  UITableViewCell+Extended.h
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Extended)

@property (nonatomic, assign) BOOL delaysContentTouches;

/** 加载同类名的 nib */
+ (UINib*)nib;

@end
