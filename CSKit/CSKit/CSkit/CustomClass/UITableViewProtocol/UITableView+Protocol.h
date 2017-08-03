//
//  UITableView+Protocol.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSTableViewDelegate.h"



@interface UITableView (Protocol)

@property(retain,nonatomic,setter=setData:,getter=getData) id data;

//注册cell
- (void)registerClass:(NSString *)className identifier:(NSString *)identifier;
- (void)registerNib:(NSString *)NibName identifier:(NSString *)identifier;


/**
 设置数据
 @param data 数据
 */
- (void)setData:(id)data;
/** 返回数据 */
- (id)getData;

/** 设置数据源&代理 */
- (void)setUpTableView;
- (void)removeDelegate;

/** 设置分区数 */
- (void)setNumberOfSections:(CSSecionNumBlock)block;
/** 设置分区中的行数 */
- (void)setNumberOfRows:(CSRowNumForSecionBlock)block;
/** 设置分区头部高度 */
- (void)setHeightForHeader:(CSHeaderFooterHeightBlock)block;
/** 设置分区头部视图 */
- (void)setViewForHeader:(CSHeaderFooterViewBlock)block;
/** 设置分区底部高度 */
- (void)setHeightForFooter:(CSHeaderFooterHeightBlock)block;
/** 设置分区底部视图 */
- (void)setViewForFooter:(CSHeaderFooterViewBlock)block;
/** 设置行高 */
- (void)setHeightForRow:(CSRowHeightBlock)block;
/** 设置将要显示行的回调 */
- (void)setWillDisplayCell:(CSWillDisplayCellBlock)block;
/** 设置行 */
- (void)setCellForRow:(CSCellForRowBlock)block;
/** 设置行点击事件 */
- (void)addSelectRowAction:(CSTableViewAction)action;
/** 设置行内部点击事件 比如 按钮&开关&分段 */
-(void)addCellClickAction:(CSTableViewAction)action;


@end



