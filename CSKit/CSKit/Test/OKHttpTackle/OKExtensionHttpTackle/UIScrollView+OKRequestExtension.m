//
//  UIScrollView+OKRequestExtension.m
//  SendHttpDemo
//
//  Created by mao wangxin on 2017/4/17.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import "UIScrollView+OKRequestExtension.h"
#import "OKHttpRequestModel.h"
#import "OKRequestTipBgView.h"
#import "AFNetworkReachabilityManager.h"

//状态栏高度 (状态栏)
#define KStatusBarHeight         20
//系统导航高度(没有包含电池栏)
#define KSystemNavBarHeight      44
//所有表格顶部空出10的间隙
#define kTableViewTopSpace       10
//默认cell高度
#define kDefaultCellHeight       48
//获取屏幕宽度
#define Screen_Width            ([UIScreen  mainScreen].bounds.size.width)
//获取屏幕高度
#define Screen_Height           ([UIScreen mainScreen].bounds.size.height)


#define kTotalPageKey                       @"totalPage"
#define kCurrentPageKey                     @"currentPage"


static char const * const kEmptyStrKey    = "kEmptyStrKey";
static char const * const kEmptyImgKey    = "kEmptyImgKey";
static char const * const kErrorImgKey    = "kErrorImgKey";
static char const * const kNetErrorStrKey = "kNetErrorStrKey";

@implementation UIScrollView (OKRequestExtension)

+ (UITableView *)plainTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KSystemNavBarHeight+20, Screen_Width, Screen_Height-KSystemNavBarHeight-20) style:UITableViewStylePlain];
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.rowHeight = kDefaultCellHeight;
//    tableView.backgroundColor = RGB(238, 241, 245);
//    tableView.separatorColor = RGB(229,229,229);
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 0.01)];
    tableView.tableFooterView = [UIView new];
    return tableView;
}

+ (UITableView *)groupedTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KSystemNavBarHeight+20, Screen_Width, Screen_Height-KSystemNavBarHeight-20) style:UITableViewStyleGrouped];
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, kTableViewTopSpace)];
    tableView.rowHeight = kDefaultCellHeight;
//    tableView.backgroundColor = RGB(238, 241, 245);
//    tableView.separatorColor = RGB(229,229,229);
    tableView.sectionHeaderHeight = 0.01;
    tableView.sectionFooterHeight = kTableViewTopSpace;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 0.01)];
    return tableView;
}

#pragma mark - ========== 请求失败提示view相关 ==========

- (void)setEmptyString:(NSString *)emptyString
{
    objc_setAssociatedObject(self, kEmptyStrKey, emptyString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)emptyString
{
    return objc_getAssociatedObject(self, kEmptyStrKey);
}

#pragma mark - ========== 提示图片名字 ==========

- (void)setEmptyImageName:(NSString *)emptyImageName
{
    objc_setAssociatedObject(self, kEmptyImgKey, emptyImageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)emptyImageName
{
    return objc_getAssociatedObject(self, kEmptyImgKey);
}

#pragma mark - ========== 请求失败文字 ==========

- (void)setNetErrorString:(NSString *)netErrorString
{
    objc_setAssociatedObject(self, kNetErrorStrKey, netErrorString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)netErrorString
{
    return objc_getAssociatedObject(self, kNetErrorStrKey);
}

#pragma mark - ========== 请求失败提示图片 ==========

- (void)setErrorImageName:(NSString *)errorImageName
{
    objc_setAssociatedObject(self, kErrorImgKey, errorImageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)errorImageName
{
    return objc_getAssociatedObject(self, kErrorImgKey);
}

#pragma mark - 给表格添加上下拉刷新事件

/**
 初始化表格的上下拉刷新控件
 
 @param headerBlock 下拉刷新需要调用的函数
 @param footerBlock 上啦刷新需要调用的函数
 */
- (void)addheaderRefresh:(MJRefreshComponentRefreshingBlock)headerBlock
             footerBlock:(MJRefreshComponentRefreshingBlock)footerBlock
{
    if (headerBlock) {
//        CSWeakSelf(self);
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            CSStrongSelf(self);
            //1.先移除页面上已有的提示视图
            [self removeOldTipBgView];
            
            //2.每次下拉刷新时先结束上啦
            [self.mj_footer endRefreshing];
            
            headerBlock();
        }];
        [self.mj_header beginRefreshing];
    }
    
    if (footerBlock) {
        self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            footerBlock();
        }];
        //这里需要先隐藏,否则已进入页面没有数据也会显示上拉view
        self.mj_footer.hidden = YES;
    }
}

#pragma mark - 给表格添加上请求失败提示事件

/**
 调用此方法,会自动处理表格上下拉刷新,分页,添加空白页等操作
 
 @param responseData 网络请求回调数据
 */
- (void)showRequestTip:(id)responseData
{
    //请求回调后收起上下拉控件
    if (self.mj_header) {
        [self.mj_header endRefreshing];
    }
    
    if (self.mj_footer) {
        [self.mj_footer endRefreshing];
    }
    
    //如果请求成功处理
    if ([responseData isKindOfClass:[NSDictionary class]]) {
        if ([self contentViewIsEmptyData]) { //页面没有数据
            
            //根据状态,显示背景提示Viwe
            if (![AFNetworkReachabilityManager sharedManager].reachable) {//没有网络
//                CSWeakSelf(self);
                [self showTipBotton:YES TipStatus:RequesErrorNoNetWork tipString:nil clickBlock:^{
//                    CSStrongSelf(self);
                    //移除提示视图,重新请求
                    [self removeTipViewAndRefresh];
                }];
                
            } else {
                [self showTipBotton:YES TipStatus:RequestEmptyDataStatus tipString:nil clickBlock:nil];
            }
            
        } else { //页面有数据
            //隐藏背景提示Viwe
            [self showTipBotton:NO TipStatus:RequestNormalStatus tipString:nil clickBlock:nil];
            
            if (!self.mj_footer) return;
            
            //控制上啦控件显示的分页逻辑
            if ([((NSDictionary *)responseData).allKeys containsObject:kTotalPageKey] &&
                [((NSDictionary *)responseData).allKeys containsObject:kCurrentPageKey] ) {
                NSInteger totalPage = [responseData[kTotalPageKey] integerValue];
                NSInteger currentPage = [responseData[kCurrentPageKey] integerValue];
                
                if (totalPage > currentPage) {
                    self.mj_footer.hidden = NO;
                } else {
                    [self.mj_footer endRefreshingWithNoMoreData];
                    self.mj_footer.hidden = YES;
                }
            } else if([((NSDictionary *)responseData).allKeys containsObject:kRequestListkey]){
                NSArray *dataArr = responseData[kRequestListkey];
                if (dataArr.count>0) {
                    self.mj_footer.hidden = NO;
                } else {
                    [self.mj_footer endRefreshingWithNoMoreData];
                    self.mj_footer.hidden = YES;
                }
            } else {
                self.mj_footer.hidden = NO;
            }
        }
        
    } else if([responseData isKindOfClass:[NSError class]]){ //请求失败处理
        NSError *error = (NSError *)responseData;        
        if ([self contentViewIsEmptyData]) { //页面没有数据
            
            //根据状态,显示背景提示Viwe
//            CSWeakSelf(self);
            //没有网络
            if (![AFNetworkReachabilityManager sharedManager].reachable) {
                [self showTipBotton:YES TipStatus:RequesErrorNoNetWork tipString:NetworkConnectFailTip clickBlock:^{
//                    CSStrongSelf(self);
                    //移除提示视图,重新请求
                    [self removeTipViewAndRefresh];
                }];
            } else {
                [self showTipBotton:YES TipStatus:RequestFailStatus tipString:error.domain clickBlock:^{
//                    CSStrongSelf(self);
                    //移除提示视图,重新请求
                    [self removeTipViewAndRefresh];
                }];
            }
        } else { //页面有数据
            //隐藏背景提示Viwe
            [self showTipBotton:NO TipStatus:RequestFailStatus tipString:error.domain clickBlock:nil];
        }
    }
}

/**
 * 移除提示视图,重新请求
 */
- (void)removeTipViewAndRefresh
{
    if (self.mj_header) {
        //1.先移除页面上已有的提示视图
        [self removeOldTipBgView];
        
        //2.开始走下拉请求
        [self.mj_header beginRefreshing];
    }
}

#pragma mark - 如果请求失败,无网络则展示空白提示view

/**
 * 设置提示图片和文字
 */
- (void)showTipBotton:(BOOL)show
            TipStatus:(TableVieTipStatus)state
            tipString:(NSString *)tipString
           clickBlock:(void(^)())blk
{
    //先移除页面上已有的提示CCParkingRequestTipView视图
    [self removeOldTipBgView];
    
    if (!show) return;
    
    NSString *tipText = nil;
    NSString *imageName = nil;
    NSString *actionTitle = nil;
    
    if (state == RequestNormalStatus) { //正常状态
        //不需要处理, 留给后面扩展
        
    } else if (state == RequestEmptyDataStatus) { //请求空数据
        tipText = self.emptyString ? : @"暂无数据 ";
        imageName = self.emptyImageName ? : @"ok_empty_data_icon";
        
    } else if (state == RequesErrorNoNetWork) { //网络连接失败
        tipText = @"网络开小差, 请稍后再试哦!";
        actionTitle = @"重新加载";
        imageName = self.errorImageName ? : @"ok_networkfail_icon";
        
    } else if (state == RequestFailStatus) { //请求失败
        tipText = @"加载失败了哦!";
        actionTitle = @"重新加载";
        imageName = self.errorImageName ? : @"ok_loading_fail_icon";
    }
    
    //这里防止表格有偏移量，一定要设置y的起始位置为0
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    UIView *tipBgView = [OKRequestTipBgView tipViewByFrame:rect
                                              tipImageName:imageName
                                                   tipText:tipText
                                               actionTitle:actionTitle
                                               actionBlock:blk];
    tipBgView.backgroundColor = self.backgroundColor;
    [self addSubview:tipBgView];
}

/**
 先移除页面上已有的提示CCParkingRequestTipView视图
 */
- (void)removeOldTipBgView
{
    for (UIView *tempView in self.subviews) {
        if ([tempView isKindOfClass:[OKRequestTipBgView class]] ||
            tempView.tag == kRequestTipViewTag) {
            [tempView removeFromSuperview];
            break;
        }
    }
}

/**
 * 判断页面是否有数据
 */
- (BOOL)contentViewIsEmptyData
{
    BOOL isEmpty = NO;
    
    //如果是UITableView
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        if (tableView.numberOfSections==0 ||
            (tableView.numberOfSections==1 && [tableView numberOfRowsInSection:0] == 0)) {
            isEmpty = YES;
        }
        
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        if (collectionView.numberOfSections==0 ||
            (collectionView.numberOfSections==1 && [collectionView numberOfItemsInSection:0] == 0)) {
            isEmpty = YES;
        }
    } else {
        NSInteger emptyCount = 0;
        for (UIView *subview in self.subviews) {
            if (subview.hidden || subview.alpha == 0) {
                emptyCount ++;
            }
        }
        if (self.subviews.count==0 || self.subviews.count == emptyCount) {
            isEmpty = YES;
        }
    }
    return isEmpty;
}


@end
