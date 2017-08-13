//
//  UIScrollView+OKRequestExtension.h
//  SendHttpDemo
//
//  Created by mao wangxin on 2017/4/17.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

typedef enum : NSUInteger {
    RequestNormalStatus,    //0 正常状态
    RequestEmptyDataStatus, //1 空数据
    RequestFailStatus,      //2 加载失败
    RequesErrorNoNetWork,   //3 网络连接失败
} TableVieTipStatus;


@interface UIScrollView (OKRequestExtension)

/** 空数据提示 */
@property (nonatomic, strong) NSString *emptyString;

/** 空数据提示图片 */
@property (nonatomic, strong) NSString *emptyImageName;

/** 网络连接失败提示 */
@property (nonatomic, strong) NSString *netErrorString;

/** 请求失败提示图片 */
@property (nonatomic, strong) NSString *errorImageName;


/**
 * 统一plain样式表格
 * 默认坐标(0,64,屏幕宽度，屏幕高度-64)
 * headerView高0.01，footerView=[UIView new]防止显示多余线条
 */
+ (UITableView *)plainTableView;

/**
 * 统一group样式表格
 * 默认坐标(0,64,屏幕宽度，屏幕高度-64)
 * headerView高12,footerView高0.01，sectionHeader高0.01，sectionFooter高12
 */
+ (UITableView *)groupedTableView;


#pragma mark - 给表格添加上下拉刷新事件

/**
 初始化表格的上下拉刷新控件
 
 @param headerBlock 下拉刷新需要调用的函数
 @param footerBlock 上啦刷新需要调用的函数
 */
- (void)addheaderRefresh:(MJRefreshComponentRefreshingBlock)headerBlock
             footerBlock:(MJRefreshComponentRefreshingBlock)footerBlock;


#pragma mark - 处理表格上下拉刷新,分页,添加空白页事件

/**
 调用此方法,会自动处理表格上下拉刷新,分页,添加空白页等操作
 
 @param responseData 网络请求回调数据
 */
- (void)showRequestTip:(id)responseData;

@end
