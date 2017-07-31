//
//  CSTransaction_Utility.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN


/**
 CSTransaction_Utility可以让您在当前的runloop休眠之前执行一次选择器
 */
@interface CSTransaction_Utility : NSObject

/**
 创建并返回具有指定目标和选择器的事务

 @param target 目标
 @param selector 选择器
 @return 新的事务,如果发生错误,则为nil
 */
+ (CSTransaction_Utility *)transactionWithTarget:(id)target selector:(SEL)selector;

/**
 提交 trancaction 到主 runloop.
 
 @discussion 在主运行循环的当前循环休眠之前,它将在目标上执行选择器一次.
 如果相同的事务(相同的目标和相同的选择器)已经在此循环中承诺运行循环,则此方法不执行任何操作.
 */
- (void)commit;

@end
NS_ASSUME_NONNULL_END
