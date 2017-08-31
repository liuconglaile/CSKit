//
//  UIScrollView+CSNetworkExtension.m
//  CSKit
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "UIScrollView+CSNetworkExtension.h"



#if __has_include(<CSkit/CSkit.h>)
#import <AFNetworkReachabilityManager.h>
#import <CSkit/CSNetworkTopMaskView.h>
#import <CSkit/CSNetworkModel.h>
#import <CSkit/CSKitHeader.h>
#else
#import "AFNetworkReachabilityManager.h"
#import "CSNetworkTopMaskView.h"
#import "CSNetworkModel.h"


#import "CSKitHeader.h"
#endif



NSInteger const KStatusBarHeight          = 20;//状态栏高度 (状态栏)
NSInteger const KSystemNavBarHeight       = 44;//系统导航高度(没有包含电池栏)
NSInteger const kTableViewTopSpace        = 10;//所有表格顶部空出10的间隙
NSInteger const kDefaultCellHeight        = 48;//默认cell高度
NSString *const kTotalPageKey             = @"totalPage";
NSString *const kCurrentPageKey           = @"currentPage";
static char const * const kEmptyStrKey    = "kEmptyStrKey";
static char const * const kEmptyImgKey    = "kEmptyImgKey";
static char const * const kErrorImgKey    = "kErrorImgKey";
static char const * const kNetErrorStrKey = "kNetErrorStrKey";



@implementation UIScrollView (CSNetworkExtension)

///MARK: ===================================================
///MARK: 初始化配置
///MARK: ===================================================
+ (UITableView *)plainTableView{
    
    UITableView *tableView = [self getTableWithStyle:UITableViewStylePlain];
    tableView.tableHeaderView = [self getHeaderFooterViewWithHeight:0.01f];
    tableView.tableFooterView = [UIView new];
    return tableView;
}

+ (UITableView *)groupedTableView{
    
    UITableView *tableView = [self getTableWithStyle:UITableViewStyleGrouped];
    tableView.tableHeaderView = [self getHeaderFooterViewWithHeight:kTableViewTopSpace];
    tableView.sectionHeaderHeight = 0.01;
    tableView.sectionFooterHeight = kTableViewTopSpace;
    tableView.tableFooterView = [self getHeaderFooterViewWithHeight:0.01f];
    
    return tableView;
}

+ (UITableView *)getTableWithStyle:(UITableViewStyle)style{
    
    CGRect frame = [self defaultFrame];
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:style];
    
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.rowHeight = kDefaultCellHeight;
    tableView.backgroundColor = [self defaultBackgroundColor];
    tableView.separatorColor = [self defaultSeparatorColor];
    
    return tableView;
    
}

+ (CGRect)defaultFrame{
    return CGRectMake(0, KSystemNavBarHeight+20, kScreenWidth, kScreenHeight-KSystemNavBarHeight-20);
}
+ (UIColor *)defaultBackgroundColor{
    return [UIColor colorWithHue:238 saturation:241 lightness:245 alpha:1];
}
+ (UIColor *)defaultSeparatorColor{
    return [UIColor colorWithHue:229 saturation:229 lightness:229 alpha:1];
}

+ (UIView *)getHeaderFooterViewWithHeight:(CGFloat)aHeight{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, aHeight)];
}





///MARK: ===================================================
///MARK: 请求失败提示view相关
///MARK: ===================================================
- (void)setEmptyString:(NSString *)emptyString{
    objc_setAssociatedObject(self, kEmptyStrKey, emptyString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)emptyString{
    return objc_getAssociatedObject(self, kEmptyStrKey);
}


///MARK: ===================================================
///MARK: 提示图片名字
///MARK: ===================================================
- (void)setEmptyImageName:(NSString *)emptyImageName{
    objc_setAssociatedObject(self, kEmptyImgKey, emptyImageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)emptyImageName{
    return objc_getAssociatedObject(self, kEmptyImgKey);
}


///MARK: ===================================================
///MARK: 请求失败文字
///MARK: ===================================================
- (void)setNetErrorString:(NSString *)netErrorString{
    objc_setAssociatedObject(self, kNetErrorStrKey, netErrorString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)netErrorString{
    return objc_getAssociatedObject(self, kNetErrorStrKey);
}


///MARK: ===================================================
///MARK: 请求失败提示图片
///MARK: ===================================================
- (void)setErrorImageName:(NSString *)errorImageName{
    objc_setAssociatedObject(self, kErrorImgKey, errorImageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)errorImageName{
    return objc_getAssociatedObject(self, kErrorImgKey);
}



///MARK: ===================================================
///MARK: 给表格添加上下拉刷新事件
///MARK: ===================================================
/**
 初始化表格的上下拉刷新控件
 
 @param headerBlock 下拉刷新需要调用的函数
 @param footerBlock 上啦刷新需要调用的函数
 */
- (void)addheaderRefresh:(MJRefreshComponentRefreshingBlock)headerBlock
             footerBlock:(MJRefreshComponentRefreshingBlock)footerBlock{
    if (headerBlock) {
        @weakify(self)
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self)
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




///MARK: ===================================================
///MARK: 给表格添加上请求失败提示事件
///MARK: ===================================================
/**
 调用此方法,会自动处理表格上下拉刷新,分页,添加空白页等操作
 
 @param responseData 网络请求回调数据
 */
- (void)showRequestTip:(id)responseData{
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
                @weakify(self)
                [self showTipBotton:YES TipStatus:CSTableVieTipStatusNoNetwork tipString:nil clickBlock:^{
                    @strongify(self)
                    //移除提示视图,重新请求
                    [self removeTipViewAndRefresh];
                }];
                
            } else {
                [self showTipBotton:YES TipStatus:CSTableVieTipStatusEmptyData tipString:nil clickBlock:nil];
            }
            
        } else { //页面有数据
            //隐藏背景提示Viwe
            [self showTipBotton:NO TipStatus:CSTableVieTipStatusNormal tipString:nil clickBlock:nil];
            
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
            } else if([((NSDictionary *)responseData).allKeys containsObject:kNetworkListkey]){
                NSArray *dataArr = responseData[kNetworkListkey];
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
            @weakify(self)
            //没有网络
            if (![AFNetworkReachabilityManager sharedManager].reachable) {
                [self showTipBotton:YES TipStatus:CSTableVieTipStatusNoNetwork tipString:kNetworkConnectFailTip clickBlock:^{
                    @strongify(self)
                    //移除提示视图,重新请求
                    [self removeTipViewAndRefresh];
                }];
            } else {
                [self showTipBotton:YES TipStatus:CSTableVieTipStatusFail tipString:error.domain clickBlock:^{
                    @strongify(self)
                    //移除提示视图,重新请求
                    [self removeTipViewAndRefresh];
                }];
            }
        } else { //页面有数据
            //隐藏背景提示Viwe
            [self showTipBotton:NO TipStatus:CSTableVieTipStatusFail tipString:error.domain clickBlock:nil];
        }
    }
}

/**
 * 移除提示视图,重新请求
 */
- (void)removeTipViewAndRefresh{
    if (self.mj_header) {
        //1.先移除页面上已有的提示视图
        [self removeOldTipBgView];
        
        //2.开始走下拉请求
        [self.mj_header beginRefreshing];
    }
}


///MARK: ===================================================
///MARK: 如果请求失败,无网络则展示空白提示view
///MARK: ===================================================
/**
 * 设置提示图片和文字
 */
- (void)showTipBotton:(BOOL)show
            TipStatus:(CSTableVieTipStatus)state
            tipString:(NSString *)tipString
           clickBlock:(void(^)())blk{
    //先移除页面上已有的提示CCParkingRequestTipView视图
    [self removeOldTipBgView];
    
    if (!show) return;
    
    NSString *tipText = nil;
    NSString *imageName = nil;
    NSString *actionTitle = nil;
    
    if (state == CSTableVieTipStatusNormal) { //正常状态
        //不需要处理, 留给后面扩展
        
    } else if (state == CSTableVieTipStatusEmptyData) { //请求空数据
        tipText = self.emptyString ? : @"暂无数据 ";
        imageName = self.emptyImageName ? : @"noData";
        
    } else if (state == CSTableVieTipStatusNoNetwork) { //网络连接失败
        tipText = @"网络开小差, 请稍后再试哦!";
        actionTitle = @"重新加载";
        imageName = self.errorImageName ? : @"loadingFail";
        
    } else if (state == CSTableVieTipStatusFail) { //请求失败
        tipText = @"加载失败了哦!";
        actionTitle = @"重新加载";
        imageName = self.errorImageName ? : @"loadingFail";
    }
    
    //这里防止表格有偏移量，一定要设置y的起始位置为0
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    UIView *tipBgView = [CSNetworkTopMaskView tipViewByFrame:rect
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
- (void)removeOldTipBgView{
    for (UIView *tempView in self.subviews) {
        if ([tempView isKindOfClass:[CSNetworkTopMaskView class]] ||
            tempView.tag == kRequestTipViewTag) {
            [tempView removeFromSuperview];
            break;
        }
    }
}

/**
 判断页面是否有数据
 */
- (BOOL)contentViewIsEmptyData{
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

















