//
//  UIScreen+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScreen (Extended)

+ (CGSize)size;
+ (CGFloat)width;
+ (CGFloat)height;

+ (CGSize)orientationSize;
+ (CGFloat)orientationWidth;
+ (CGFloat)orientationHeight;
+ (CGSize)dpiSize;

/** 主屏幕尺寸 */
+ (CGFloat)screenScale;

/**
 返回当前设备方向的屏幕bounds.
 
 @return 根据当前屏幕方向返回的bounds.
 @see    boundsForOrientation:
 */
- (CGRect)currentBounds NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 返回给定设备方向的屏幕范围.'UIScreen'的'bounds'方法总是以纵向方向返回屏幕bounds.
 
 @param orientation  屏幕方向.
 @return 根据当前屏幕方向返回的bounds.
 @see  currentBounds
 */
- (CGRect)boundsForOrientation:(UIInterfaceOrientation)orientation;

/**
 屏幕的实际尺寸(宽度始终小于高度).该值在未知设备或模拟器中可能不是很准确.
 e.g. (768,1024)
 */
@property (nonatomic, readonly) CGSize sizeInPixel;

/**
 屏幕的PPI.该值在未知设备或模拟器中可能不是很准确.默认值为96。
 */
@property (nonatomic, readonly) CGFloat pixelsPerInch;

@end

NS_ASSUME_NONNULL_END
