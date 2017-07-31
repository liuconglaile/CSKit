//
//  UIBarButtonItem+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^BarButtonClickCallback)(id sender);

@interface UIBarButtonItem (Extended)

/**
 点击 item 时调用的块,ButtonItem将保留代码块捕获的对象.
 
 @discussion 这个参数与'target'和'action'属性冲突.设置这将为一些内部对象设置'target'和'action'属性.
 */
@property (nullable, nonatomic, copy) BarButtonClickCallback actionBlock;


@end

NS_ASSUME_NONNULL_END
