//
//  UIScrollView+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, CSScrollDirection) {
    CSScrollDirectionUp,
    CSScrollDirectionDown,
    CSScrollDirectionLeft,
    CSScrollDirectionRight,
    CSScrollDirectionWTF
};


@interface UIScrollView (Extended)

///MARK: 移动到边界
- (void)scrollToTop;
- (void)scrollToBottom;
- (void)scrollToLeft;
- (void)scrollToRight;
///MARK: 移动到边界(带动画)
- (void)scrollToTopAnimated:(BOOL)animated;
- (void)scrollToBottomAnimated:(BOOL)animated;
- (void)scrollToLeftAnimated:(BOOL)animated;
- (void)scrollToRightAnimated:(BOOL)animated;


@property(nonatomic) CGFloat contentWidth;
@property(nonatomic) CGFloat contentHeight;
@property(nonatomic) CGFloat contentOffsetX;
@property(nonatomic) CGFloat contentOffsetY;

// 顶部内容偏移
- (CGPoint)topContentOffset;
// 底部内容偏移
- (CGPoint)bottomContentOffset;
// 左边内容偏移
- (CGPoint)leftContentOffset;
// 右边内容偏移
- (CGPoint)rightContentOffset;
// 滚动方向
- (CSScrollDirection)ScrollDirection;
// 是否滚动到顶部
- (BOOL)isScrolledToTop;
- (BOOL)isScrolledToBottom;
- (BOOL)isScrolledToLeft;
- (BOOL)isScrolledToRight;

// 垂直页面索引
- (NSUInteger)verticalPageIndex;
- (NSUInteger)horizontalPageIndex;
// 根据索引垂直滚动页面
- (void)scrollToVerticalPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated;
- (void)scrollToHorizontalPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated;



- (NSInteger)pages;
- (NSInteger)currentPage;
- (CGFloat)scrollPercent;

- (CGFloat)pagesY;
- (CGFloat)pagesX;
- (CGFloat)currentPageY;
- (CGFloat)currentPageX;
- (void)setPageY:(CGFloat)page;
- (void)setPageX:(CGFloat)page;
- (void)setPageY:(CGFloat)page animated:(BOOL)animated;
- (void)setPageX:(CGFloat)page animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
