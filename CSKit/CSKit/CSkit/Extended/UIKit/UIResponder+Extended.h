//
//  UIResponder+Extended.h
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (Extended)

/** 响应者链 */
- (NSString *)responderChainDescription;

/** 当前第一响应者 */
+ (id)currentFirstResponder;

@end

