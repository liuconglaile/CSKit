//
//  NSObject+CGUtilities.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSMacrosHeader.h>

#else
#import "CSMacrosHeader.h"

#endif

CS_EXTERN_C_BEGIN
NS_ASSUME_NONNULL_BEGIN


/**
 创建一个'ARGB'位图上下文. 如果发生错误,则返回NULL
 该函数与UIGraphicsBeginImageContextWithOptions()相同,但是它不会将上下文推送到UIGraphic,因此您可以保留上下文以供重用
 
 @param size 尺寸
 @param opaque 是否透明,通道值
 @param scale 比例
 @return 位图上下文
 */
CGContextRef _Nullable CSCGContextCreateARGBBitmapContext(CGSize size, BOOL opaque, CGFloat scale);

/// Create a `DeviceGray` Bitmap context. Returns NULL if an error occurs.

/**
 创建一个'DeviceGray'位图上下文. 如果发生错误,则返回NULL.
 */
CGContextRef _Nullable CSCGContextCreateGrayBitmapContext(CGSize size, CGFloat scale);




/**
 获取主屏幕的尺寸

 @return 返回英寸数值
 */
CGFloat CSScreenScale(void);


/**
 获取主屏幕的大小. 高度总是大于宽度

 @return 正屏的尺寸,像素单位
 */
CGSize CSScreenSize(void);


/**
 将度数转换为弧度

 @param degrees 度数
 @return 弧度
 */
static inline CGFloat DegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}


/**
 将弧度转换为度数

 @param radians 弧度
 @return 度数
 */
static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}


/**
 获取旋转角度

 @param transform 形变参数(2维)
 @return 旋转角度 [-PI,PI] ([-180°,180°])
 */
static inline CGFloat CGAffineTransformGetRotation(CGAffineTransform transform) {
    return atan2(transform.b, transform.a);
}

/// 获取形变 transform's scale.x
static inline CGFloat CGAffineTransformGetScaleX(CGAffineTransform transform) {
    return  sqrt(transform.a * transform.a + transform.c * transform.c);
}

/// 获取形变 transform's scale.y
static inline CGFloat CGAffineTransformGetScaleY(CGAffineTransform transform) {
    return sqrt(transform.b * transform.b + transform.d * transform.d);
}

/// 获取形变 transform's translate.x
static inline CGFloat CGAffineTransformGetTranslateX(CGAffineTransform transform) {
    return transform.tx;
}

/// 获取形变 transform's translate.y
static inline CGFloat CGAffineTransformGetTranslateY(CGAffineTransform transform) {
    return transform.ty;
}


/**
 如果您有3对点由相同的CGAffineTransform转换:

 p1 (transform->) q1
 p2 (transform->) q2
 p3 (transform->) q3
 该方法从这3对点返回原始变换矩阵
 @see http://stackoverflow.com/questions/13291796/calculate-values-for-a-cgaffinetransform-from-three-points-in-each-of-two-uiview
 */
CGAffineTransform CSCGAffineTransformGetFromPoints(CGPoint before[_Nullable 3], CGPoint after[_Nullable 3]);

/// 获取可以将点从给定视图的坐标系转换到另一个的变换.
CGAffineTransform CSCGAffineTransformGetFromViews(UIView *from, UIView *to);

/// 创建一个偏斜变换.
static inline CGAffineTransform CGAffineTransformMakeSkew(CGFloat x, CGFloat y){
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform.c = -x;
    transform.b = y;
    return transform;
}

/// 取消/反转UIEdgeInsets.
static inline UIEdgeInsets UIEdgeInsetsInvert(UIEdgeInsets insets) {
    return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}

/// 将CALayer的重力字符串转换为UIViewContentMode.
UIViewContentMode CSCAGravityToUIViewContentMode(NSString *gravity);

/// 将UIViewContentMode转换为CALayer的重力字符串.
NSString *CSUIViewContentModeToCAGravity(UIViewContentMode contentMode);



/**
 返回一个矩形以适应
 (UIViewContentModeRedraw与UIViewContentModeScaleToFill相同)

 @param rect 位置
 @param size 尺寸
 @param mode 显示模式
 @return 给定内容模式的矩形
 */
CGRect CSCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode);

/// 返回Frame的中心.
static inline CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

/// 返回Frame的区域.
static inline CGFloat CGRectGetArea(CGRect rect) {
    if (CGRectIsNull(rect)) return 0;
    rect = CGRectStandardize(rect);
    return rect.size.width * rect.size.height;
}

/// 返回两点之间的距离.
static inline CGFloat CGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

/// 返回点到矩形之间的最小距离.
static inline CGFloat CGPointGetDistanceToRect(CGPoint p, CGRect r) {
    r = CGRectStandardize(r);
    if (CGRectContainsPoint(r, p)) return 0;
    CGFloat distV, distH;
    if (CGRectGetMinY(r) <= p.y && p.y <= CGRectGetMaxY(r)) {
        distV = 0;
    } else {
        distV = p.y < CGRectGetMinY(r) ? CGRectGetMinY(r) - p.y : p.y - CGRectGetMaxY(r);
    }
    if (CGRectGetMinX(r) <= p.x && p.x <= CGRectGetMaxX(r)) {
        distH = 0;
    } else {
        distH = p.x < CGRectGetMinX(r) ? CGRectGetMinX(r) - p.x : p.x - CGRectGetMaxX(r);
    }
    return MAX(distV, distH);
}



/// 将点转换为像素.
static inline CGFloat CGFloatToPixel(CGFloat value) {
    return value * CSScreenScale();
}

/// 将像素转换为点.
static inline CGFloat CGFloatFromPixel(CGFloat value) {
    return value / CSScreenScale();
}



/// 像素对齐的底部点值
static inline CGFloat CGFloatPixelFloor(CGFloat value) {
    CGFloat scale = CSScreenScale();
    return floor(value * scale) / scale;
}

/// 像素对齐的圆点值
static inline CGFloat CGFloatPixelRound(CGFloat value) {
    CGFloat scale = CSScreenScale();
    return round(value * scale) / scale;
}

/// 像素对齐的细节点值
static inline CGFloat CGFloatPixelCeil(CGFloat value) {
    CGFloat scale = CSScreenScale();
    return ceil(value * scale) / scale;
}

/// 圆点值到.5像素的路径笔画(奇数像素线宽像素对齐)
static inline CGFloat CGFloatPixelHalf(CGFloat value) {
    CGFloat scale = CSScreenScale();
    return (floor(value * scale) + 0.5) / scale;
}



/// 像素对齐的地面点值
static inline CGPoint CGPointPixelFloor(CGPoint point) {
    CGFloat scale = CSScreenScale();
    return CGPointMake(floor(point.x * scale) / scale,
                       floor(point.y * scale) / scale);
}

/// 像素对齐的圆点值
static inline CGPoint CGPointPixelRound(CGPoint point) {
    CGFloat scale = CSScreenScale();
    return CGPointMake(round(point.x * scale) / scale,
                       round(point.y * scale) / scale);
}

/// 像素对齐的细节点值
static inline CGPoint CGPointPixelCeil(CGPoint point) {
    CGFloat scale = CSScreenScale();
    return CGPointMake(ceil(point.x * scale) / scale,
                       ceil(point.y * scale) / scale);
}

/// 圆点值到.5像素的路径笔画(奇数像素线宽像素对齐)
static inline CGPoint CGPointPixelHalf(CGPoint point) {
    CGFloat scale = CSScreenScale();
    return CGPointMake((floor(point.x * scale) + 0.5) / scale,
                       (floor(point.y * scale) + 0.5) / scale);
}



/// floor point value for pixel-aligned
static inline CGSize CGSizePixelFloor(CGSize size) {
    CGFloat scale = CSScreenScale();
    return CGSizeMake(floor(size.width * scale) / scale,
                      floor(size.height * scale) / scale);
}

/// round point value for pixel-aligned
static inline CGSize CGSizePixelRound(CGSize size) {
    CGFloat scale = CSScreenScale();
    return CGSizeMake(round(size.width * scale) / scale,
                      round(size.height * scale) / scale);
}

/// ceil point value for pixel-aligned
static inline CGSize CGSizePixelCeil(CGSize size) {
    CGFloat scale = CSScreenScale();
    return CGSizeMake(ceil(size.width * scale) / scale,
                      ceil(size.height * scale) / scale);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGSize CGSizePixelHalf(CGSize size) {
    CGFloat scale = CSScreenScale();
    return CGSizeMake((floor(size.width * scale) + 0.5) / scale,
                      (floor(size.height * scale) + 0.5) / scale);
}



/// floor point value for pixel-aligned
static inline CGRect CGRectPixelFloor(CGRect rect) {
    CGPoint origin = CGPointPixelCeil(rect.origin);
    CGPoint corner = CGPointPixelFloor(CGPointMake(rect.origin.x + rect.size.width,
                                                   rect.origin.y + rect.size.height));
    CGRect ret = CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
    if (ret.size.width < 0) ret.size.width = 0;
    if (ret.size.height < 0) ret.size.height = 0;
    return ret;
}

/// round point value for pixel-aligned
static inline CGRect CGRectPixelRound(CGRect rect) {
    CGPoint origin = CGPointPixelRound(rect.origin);
    CGPoint corner = CGPointPixelRound(CGPointMake(rect.origin.x + rect.size.width,
                                                   rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// ceil point value for pixel-aligned
static inline CGRect CGRectPixelCeil(CGRect rect) {
    CGPoint origin = CGPointPixelFloor(rect.origin);
    CGPoint corner = CGPointPixelCeil(CGPointMake(rect.origin.x + rect.size.width,
                                                  rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGRect CGRectPixelHalf(CGRect rect) {
    CGPoint origin = CGPointPixelHalf(rect.origin);
    CGPoint corner = CGPointPixelHalf(CGPointMake(rect.origin.x + rect.size.width,
                                                  rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}



/// floor UIEdgeInset用于像素对齐
static inline UIEdgeInsets UIEdgeInsetPixelFloor(UIEdgeInsets insets) {
    insets.top = CGFloatPixelFloor(insets.top);
    insets.left = CGFloatPixelFloor(insets.left);
    insets.bottom = CGFloatPixelFloor(insets.bottom);
    insets.right = CGFloatPixelFloor(insets.right);
    return insets;
}

/// ceil UIEdgeInset 用于像素对齐
static inline UIEdgeInsets UIEdgeInsetPixelCeil(UIEdgeInsets insets) {
    insets.top = CGFloatPixelCeil(insets.top);
    insets.left = CGFloatPixelCeil(insets.left);
    insets.bottom = CGFloatPixelCeil(insets.bottom);
    insets.right = CGFloatPixelCeil(insets.right);
    return insets;
}

// main screen's scale

/**
 主屏尺度
 */
#ifndef kScreenScale
#define kScreenScale CSScreenScale()
#endif


/**
 主屏尺寸(纵向)
 */
#ifndef kScreenSize
#define kScreenSize CSScreenSize()
#endif


/**
 主屏幕宽度(纵向)
 */
#ifndef kScreenWidth
#define kScreenWidth CSScreenSize().width
#endif

/**
 主屏幕高度(纵向)
 */
#ifndef kScreenHeight
#define kScreenHeight CSScreenSize().height
#endif




@interface NSObject (CGUtilities)

@end



NS_ASSUME_NONNULL_END
CS_EXTERN_C_END
