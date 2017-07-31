//
//  UIScrollView+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIScrollView+Extended.h"
#import "CSKitMacro.h"

CSSYNTH_DUMMY_CLASS(UIScrollView_Extended)

@implementation UIScrollView (Extended)

- (void)scrollToTop {
    [self scrollToTopAnimated:YES];
}

- (void)scrollToBottom {
    [self scrollToBottomAnimated:YES];
}

- (void)scrollToLeft {
    [self scrollToLeftAnimated:YES];
}

- (void)scrollToRight {
    [self scrollToRightAnimated:YES];
}

- (void)scrollToTopAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = 0 - self.contentInset.top;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToLeftAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = 0 - self.contentInset.left;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToRightAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
    [self setContentOffset:off animated:animated];
}

//frame
- (CGFloat)contentWidth {
    return self.contentSize.width;
}
- (void)setContentWidth:(CGFloat)width {
    self.contentSize = CGSizeMake(width, self.frame.size.height);
}
- (CGFloat)contentHeight {
    return self.contentSize.height;
}
- (void)setContentHeight:(CGFloat)height {
    self.contentSize = CGSizeMake(self.frame.size.width, height);
}
- (CGFloat)contentOffsetX {
    return self.contentOffset.x;
}
- (void)setContentOffsetX:(CGFloat)x {
    self.contentOffset = CGPointMake(x, self.contentOffset.y);
}
- (CGFloat)contentOffsetY {
    return self.contentOffset.y;
}
- (void)setContentOffsetY:(CGFloat)y {
    self.contentOffset = CGPointMake(self.contentOffset.x, y);
}
//


- (CGPoint)topContentOffset
{
    return CGPointMake(0.0f, -self.contentInset.top);
}
- (CGPoint)bottomContentOffset
{
    return CGPointMake(0.0f, self.contentSize.height + self.contentInset.bottom - self.bounds.size.height);
}
- (CGPoint)leftContentOffset
{
    return CGPointMake(-self.contentInset.left, 0.0f);
}
- (CGPoint)rightContentOffset
{
    return CGPointMake(self.contentSize.width + self.contentInset.right - self.bounds.size.width, 0.0f);
}
- (CSScrollDirection)ScrollDirection
{
    CSScrollDirection direction;
    
    if ([self.panGestureRecognizer translationInView:self.superview].y > 0.0f)
    {
        direction = CSScrollDirectionUp;
    }
    else if ([self.panGestureRecognizer translationInView:self.superview].y < 0.0f)
    {
        direction = CSScrollDirectionDown;
    }
    else if ([self.panGestureRecognizer translationInView:self].x < 0.0f)
    {
        direction = CSScrollDirectionLeft;
    }
    else if ([self.panGestureRecognizer translationInView:self].x > 0.0f)
    {
        direction = CSScrollDirectionRight;
    }
    else
    {
        direction = CSScrollDirectionWTF;
    }
    
    return direction;
}
- (BOOL)isScrolledToTop
{
    return self.contentOffset.y <= [self topContentOffset].y;
}
- (BOOL)isScrolledToBottom
{
    return self.contentOffset.y >= [self bottomContentOffset].y;
}
- (BOOL)isScrolledToLeft
{
    return self.contentOffset.x <= [self leftContentOffset].x;
}
- (BOOL)isScrolledToRight
{
    return self.contentOffset.x >= [self rightContentOffset].x;
}


- (NSUInteger)verticalPageIndex
{
    return (self.contentOffset.y + (self.frame.size.height * 0.5f)) / self.frame.size.height;
}
- (NSUInteger)horizontalPageIndex
{
    return (self.contentOffset.x + (self.frame.size.width * 0.5f)) / self.frame.size.width;
}
- (void)scrollToVerticalPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated
{
    [self setContentOffset:CGPointMake(0.0f, self.frame.size.height * pageIndex) animated:animated];
}
- (void)scrollToHorizontalPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated
{
    [self setContentOffset:CGPointMake(self.frame.size.width * pageIndex, 0.0f) animated:animated];
}


- (NSInteger)pages{
    NSInteger pages = self.contentSize.width/self.frame.size.width;
    return pages;
}
- (NSInteger)currentPage{
    NSInteger pages = self.contentSize.width/self.frame.size.width;
    CGFloat scrollPercent = [self scrollPercent];
    NSInteger currentPage = (NSInteger)roundf((pages-1)*scrollPercent);
    return currentPage;
}
- (CGFloat)scrollPercent{
    CGFloat width = self.contentSize.width-self.frame.size.width;
    CGFloat scrollPercent = self.contentOffset.x/width;
    return scrollPercent;
}

- (CGFloat)pagesY {
    CGFloat pageHeight = self.frame.size.height;
    CGFloat contentHeight = self.contentSize.height;
    return contentHeight/pageHeight;
}
- (CGFloat)pagesX{
    CGFloat pageWidth = self.frame.size.width;
    CGFloat contentWidth = self.contentSize.width;
    return contentWidth/pageWidth;
}
- (CGFloat)currentPageY{
    CGFloat pageHeight = self.frame.size.height;
    CGFloat offsetY = self.contentOffset.y;
    return offsetY / pageHeight;
}
- (CGFloat)currentPageX{
    CGFloat pageWidth = self.frame.size.width;
    CGFloat offsetX = self.contentOffset.x;
    return offsetX / pageWidth;
}
- (void)setPageY:(CGFloat)page{
    [self setPageY:page animated:NO];
}
- (void) setPageX:(CGFloat)page{
    [self setPageX:page animated:NO];
}
- (void)setPageY:(CGFloat)page animated:(BOOL)animated {
    CGFloat pageHeight = self.frame.size.height;
    CGFloat offsetY = page * pageHeight;
    CGFloat offsetX = self.contentOffset.x;
    CGPoint offset = CGPointMake(offsetX,offsetY);
    [self setContentOffset:offset];
}
- (void)setPageX:(CGFloat)page animated:(BOOL)animated{
    CGFloat pageWidth = self.frame.size.width;
    CGFloat offsetY = self.contentOffset.y;
    CGFloat offsetX = page * pageWidth;
    CGPoint offset = CGPointMake(offsetX,offsetY);
    [self setContentOffset:offset animated:animated];
}


@end
