//
//  UINavigationItem+Extended.h
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double UINavigationItem_MarginVersionNumber;
FOUNDATION_EXPORT const unsigned char UINavigationItem_MarginVersionString[];

/**
 菊花位置枚举
 
 - CSNavBarLoaderPositionCenter: 居中
 - CSNavBarLoaderPositionLeft: 居左
 - CSNavBarLoaderPositionRight: 居右
 */
typedef NS_ENUM(NSUInteger, CSNavBarLoaderPosition) {
    CSNavBarLoaderPositionCenter = 0,
    CSNavBarLoaderPositionLeft,
    CSNavBarLoaderPositionRight
};

@interface UINavigationItem (Extended)

@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat rightMargin;

+ (CGFloat)systemMargin;



/**
 *  添加UIActivityIndicatorView查看层次结构，并立即启动动画
 *
 *  @param position Left, center or right
 */
- (void)startAnimatingAt:(CSNavBarLoaderPosition)position;

/**
 *  停止动画，从视图层次结构中删除UIActivityIndicatorView和恢复项目
 */
- (void)stopAnimating;



/**
 *  @brief  锁定RightItem
 *
 *  @param lock 是否锁定
 */
- (void)lockRightItem:(BOOL)lock;
/**
 *  @brief  锁定LeftItem
 *
 *  @param lock 是否锁定
 */
- (void)lockLeftItem:(BOOL)lock;

@end



