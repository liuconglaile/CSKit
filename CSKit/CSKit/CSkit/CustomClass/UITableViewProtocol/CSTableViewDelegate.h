//
//  CSTableViewDelegate.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 自定义协议
 与UITableViewDelegate&UITableViewDataSource一一对应
 通常你不应该直接使用
 */
@protocol CSTableViewProtocol <NSObject>

///MARK: ===================================================
///MARK: 自定义回调
///MARK: ===================================================
/**
 返回分区
 
 @param data <#data description#>
 @return <#return value description#>
 */
typedef NSInteger(^CSSecionNumBlock)(id data);


/**
 返回行数
 
 @param data <#data description#>
 @param secion <#secion description#>
 @return <#return value description#>
 */
typedef NSInteger(^CSRowNumForSecionBlock)(id data, NSInteger secion);


/**
 行高
 
 @param data 数据
 @param indexPath indexPath
 @return 行高
 */
typedef CGFloat(^CSRowHeightBlock)(id data, NSIndexPath *indexPath);

/**
 header footer 高度
 
 @param data <#data description#>
 @param seion <#seion description#>
 @return <#return value description#>
 */
typedef CGFloat(^CSHeaderFooterHeightBlock)(id data,NSInteger seion);


/**
 点击事件
 
 @param tableView <#tableView description#>
 @param data <#data description#>
 @param indexPath <#indexPath description#>
 @param action <#action description#>
 */
typedef void(^CSTableViewAction)(UITableView *tableView,id data,NSIndexPath *indexPath,id action);


/**
 显示行
 
 @param tableView <#tableView description#>
 @param data <#data description#>
 @param indexPath <#indexPath description#>
 @return <#return value description#>
 */
typedef UITableViewCell*(^CSCellForRowBlock)(UITableView *tableView,id data,NSIndexPath *indexPath);


/**
 将要显示行
 
 @param data <#data description#>
 @param cell <#cell description#>
 @param indexPath <#indexPath description#>
 @return <#return value description#>
 */
typedef UITableViewCell*(^CSWillDisplayCellBlock)(id data,UITableViewCell *cell,NSIndexPath *indexPath);


/**
 header footer view
 
 @param data <#data description#>
 @param secion <#secion description#>
 @return <#return value description#>
 */
typedef UIView *(^CSHeaderFooterViewBlock)(id data,NSInteger secion);

@end

@interface CSTableViewDelegate : NSObject<UITableViewDelegate,UITableViewDataSource>


/**
 设置数据
 @param data  dic或者arr
 */
- (void)setData:(id)data;

/**
 返回数据
 
 @return 数据
 */
- (id)getData;

/**
 初始化
 
 @param tableView 需要实现委托代理的tableView
 @return 代理对象
 */
- (id)initWithTableView:(UITableView *)tableView;
/**
 设置分区数
 */
-(void)setNumberOfSections:(CSSecionNumBlock)block;
/**
 设置分区中的行数
 */
-(void)setNumberOfRows:(CSRowNumForSecionBlock)block;

/**
 设置分区头部高度
 */
-(void)setHeightForHeader:(CSHeaderFooterHeightBlock)block;
/**
 设置分区头部视图
 */
-(void)setViewForHeader:(CSHeaderFooterViewBlock)block;
/**
 设置分区底部高度
 */
-(void)setHeightForFooter:(CSHeaderFooterHeightBlock)block;
/**
 设置分区底部视图
 */
-(void)setViewForFooter:(CSHeaderFooterViewBlock)block;
/**
 设置行高
 */
-(void)setHeightForRow:(CSRowHeightBlock)block;
/**
 设置将要显示行的回调
 */
-(void)setWillDisplayCell:(CSWillDisplayCellBlock)block;
/**
 设置行
 */
-(void)setCellForRow:(CSCellForRowBlock)block;
/**
 设置行点击事件
 */
-(void)addSelectRowAction:(CSTableViewAction)action;
/**
 设置行内部点击事件 比如 按钮 开关  分段
 */
-(void)addCellClickAction:(CSTableViewAction)action;



@end




