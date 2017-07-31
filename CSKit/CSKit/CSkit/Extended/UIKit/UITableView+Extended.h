//
//  UITableView+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (Extended)

/**
 执行插入,删除或选择接收器的行和部分的一系列方法调用.
 
 @discussion   执行一系列方法调用,插入,删除或选择表的行和部分.如果要进行后续插入,删除和选择操作
               (例如,cellForRowAtIndexPath: 和 indexPathsForVisibleRows)并且执行动画.
 @discussion   如果您不在此块内进行插入,删除和选择调用,则表属性(如行数)可能会变为无效.你不应该在块内调用reloadData;
               如果您在组内调用此方法,您将需要自己执行动画.
 @param block  代码块,组合了一系列方法调用.
 */
- (void)updateWithBlock:(void (^)(UITableView *tableView))block;

/**
 将接收器滚动到屏幕上的行或部分位置.
 
 @discussion            调用此方法不会导致委托人收到scrollViewDidScroll:消息,正如编程调用的用户界面操作一样.
 @param row             行索.NSNotFound是滚动到具有行的部分的有效值.
 @param section         表中的分组索引.
 @param scrollPosition  一个常量,用于标识滚动结束时接收表视图(顶部,中间,底部)行中的相对位置.
 @param animated        YES,如果你想要动画变化的位置,否如果它应该是即时的.
 */
- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

/**
 在接收器中插入一行,并具有动画插入的选项.
 
 @param row        行索引在分组.
 @param section    分组索引.
 @param animation  动画枚举,指定插入单元格时要执行的动画的种类或不要求动画.
 */
- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 使用某种动画效果重新加载指定的行.
 
 @param row        行索引在分组.
 @param section    分组索引.
 @param animation  动画枚举,指定插入单元格时要执行的动画的种类或不要求动画.
 */
- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 动画形式删除某分区某行.
 
 @param row        行索引在分组.
 @param section    分组索引.
 @param animation  动画枚举,指定插入单元格时要执行的动画的种类或不要求动画.
 */
- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 根据indexPath插入指定的行,并具有动画删除的选项.
 
 @param indexPath  NSIndexPath对象,表示一行在表视图中标识一行的行索引和段索引.
 @param animation  动画枚举,指定插入单元格时要执行的动画的种类或不要求动画.
 */
- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 根据indexPath加载指定的行,并具有动画删除的选项.
 
 @param indexPath  NSIndexPath对象,表示一行在表视图中标识一行的行索引和段索引.
 @param animation  动画枚举,指定插入单元格时要执行的动画的种类或不要求动画.
 */
- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 根据indexPath删除指定的行,并具有动画删除的选项.
 
 @param indexPath  NSIndexPath对象,表示一行在表视图中标识一行的行索引和段索引.
 @param animation  动画枚举,指定插入单元格时要执行的动画的种类或不要求动画.
 */
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 根据section插入分组,可设置动画.
 
 @param section    分组索引.
 @param animation  动画枚举,指定插入单元格时要执行的动画的种类或不要求动画.
 */
- (void)insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 根据section删除分组,可设置动画.
 
 @param section    分组索引.
 @param animation  动画枚举,指定插入单元格时要执行的动画的种类或不要求动画.
 */
- (void)deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 根据section重载分组,可设置动画.
 
 @param section    分组索引.
 @param animation  动画枚举,指定插入单元格时要执行的动画的种类或不要求动画.
 */
- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 取消选择tableView中的所有行。
  
 @param animated YES动画转换,NO使立即转换.
 */
- (void)clearSelectedRowsAnimated:(BOOL)animated;

/**
 滑动到最底部
 
 @param animated 是否动画
 */
- (void)scrollTableToFoot:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
