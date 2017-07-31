//
//  NSObject+CGUtilities.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#if __has_include(<AsyncDisplayKit/CSAsyncDisplayKit.h>)
#import <AsyncDisplayKit/CSKitMacro.h>
#else
#import "CSKitMacro.h"
#endif

CS_EXTERN_C_BEGIN
NS_ASSUME_NONNULL_BEGIN


/// Create an `ARGB` Bitmap context. Returns NULL if an error occurs.
///
/// @discussion The function is same as UIGraphicsBeginImageContextWithOptions(),
/// but it doesn't push the context to UIGraphic, so you can retain the context for reuse.
CGContextRef _Nullable CSCGContextCreateARGBBitmapContext(CGSize size, BOOL opaque, CGFloat scale);

/// Create a `DeviceGray` Bitmap context. Returns NULL if an error occurs.
CGContextRef _Nullable CSCGContextCreateGrayBitmapContext(CGSize size, CGFloat scale);



/// Get main screen's scale.
CGFloat CSScreenScale();

/// Get main screen's size. Height is always larger than width.
CGSize CSScreenSize();



/// Convert degrees to radians.
static inline CGFloat DegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

/// Convert radians to degrees.
static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}



/// Get the transform rotation.
/// @return the rotation in radians [-PI,PI] ([-180°,180°])
static inline CGFloat CGAffineTransformGetRotation(CGAffineTransform transform) {
    return atan2(transform.b, transform.a);
}

/// Get the transform's scale.x
static inline CGFloat CGAffineTransformGetScaleX(CGAffineTransform transform) {
    return  sqrt(transform.a * transform.a + transform.c * transform.c);
}

/// Get the transform's scale.y
static inline CGFloat CGAffineTransformGetScaleY(CGAffineTransform transform) {
    return sqrt(transform.b * transform.b + transform.d * transform.d);
}

/// Get the transform's translate.x
static inline CGFloat CGAffineTransformGetTranslateX(CGAffineTransform transform) {
    return transform.tx;
}

/// Get the transform's translate.y
static inline CGFloat CGAffineTransformGetTranslateY(CGAffineTransform transform) {
    return transform.ty;
}

/**
 If you have 3 pair of points transformed by a same CGAffineTransform:
 p1 (transform->) q1
 p2 (transform->) q2
 p3 (transform->) q3
 This method returns the original transform matrix from these 3 pair of points.
 
 @see http://stackoverflow.com/questions/13291796/calculate-values-for-a-cgaffinetransform-from-three-points-in-each-of-two-uiview
 */
CGAffineTransform CSCGAffineTransformGetFromPoints(CGPoint before[_Nullable 3], CGPoint after[_Nullable 3]);

/// Get the transform which can converts a point from the coordinate system of a given view to another.
CGAffineTransform CSCGAffineTransformGetFromViews(UIView *from, UIView *to);

/// Create a skew transform.
static inline CGAffineTransform CGAffineTransformMakeSkew(CGFloat x, CGFloat y){
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform.c = -x;
    transform.b = y;
    return transform;
}

/// Negates/inverts a UIEdgeInsets.
static inline UIEdgeInsets UIEdgeInsetsInvert(UIEdgeInsets insets) {
    return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}

/// Convert CALayer's gravity string to UIViewContentMode.
UIViewContentMode CSCAGravityToUIViewContentMode(NSString *gravity);

/// Convert UIViewContentMode to CALayer's gravity string.
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

/// Returns the center for the rectangle.
static inline CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

/// Returns the area of the rectangle.
static inline CGFloat CGRectGetArea(CGRect rect) {
    if (CGRectIsNull(rect)) return 0;
    rect = CGRectStandardize(rect);
    return rect.size.width * rect.size.height;
}

/// Returns the distance between two points.
static inline CGFloat CGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

/// Returns the minmium distance between a point to a rectangle.
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



/// Convert point to pixel.
static inline CGFloat CGFloatToPixel(CGFloat value) {
    return value * CSScreenScale();
}

/// Convert pixel to point.
static inline CGFloat CGFloatFromPixel(CGFloat value) {
    return value / CSScreenScale();
}



/// floor point value for pixel-aligned
static inline CGFloat CGFloatPixelFloor(CGFloat value) {
    CGFloat scale = CSScreenScale();
    return floor(value * scale) / scale;
}

/// round point value for pixel-aligned
static inline CGFloat CGFloatPixelRound(CGFloat value) {
    CGFloat scale = CSScreenScale();
    return round(value * scale) / scale;
}

/// ceil point value for pixel-aligned
static inline CGFloat CGFloatPixelCeil(CGFloat value) {
    CGFloat scale = CSScreenScale();
    return ceil(value * scale) / scale;
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGFloat CGFloatPixelHalf(CGFloat value) {
    CGFloat scale = CSScreenScale();
    return (floor(value * scale) + 0.5) / scale;
}



/// floor point value for pixel-aligned
static inline CGPoint CGPointPixelFloor(CGPoint point) {
    CGFloat scale = CSScreenScale();
    return CGPointMake(floor(point.x * scale) / scale,
                       floor(point.y * scale) / scale);
}

/// round point value for pixel-aligned
static inline CGPoint CGPointPixelRound(CGPoint point) {
    CGFloat scale = CSScreenScale();
    return CGPointMake(round(point.x * scale) / scale,
                       round(point.y * scale) / scale);
}

/// ceil point value for pixel-aligned
static inline CGPoint CGPointPixelCeil(CGPoint point) {
    CGFloat scale = CSScreenScale();
    return CGPointMake(ceil(point.x * scale) / scale,
                       ceil(point.y * scale) / scale);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
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



/// floor UIEdgeInset for pixel-aligned
static inline UIEdgeInsets UIEdgeInsetPixelFloor(UIEdgeInsets insets) {
    insets.top = CGFloatPixelFloor(insets.top);
    insets.left = CGFloatPixelFloor(insets.left);
    insets.bottom = CGFloatPixelFloor(insets.bottom);
    insets.right = CGFloatPixelFloor(insets.right);
    return insets;
}

/// ceil UIEdgeInset for pixel-aligned
static inline UIEdgeInsets UIEdgeInsetPixelCeil(UIEdgeInsets insets) {
    insets.top = CGFloatPixelCeil(insets.top);
    insets.left = CGFloatPixelCeil(insets.left);
    insets.bottom = CGFloatPixelCeil(insets.bottom);
    insets.right = CGFloatPixelCeil(insets.right);
    return insets;
}

// main screen's scale
#ifndef kScreenScale
#define kScreenScale CSScreenScale()
#endif

// main screen's size (portrait)
#ifndef kScreenSize
#define kScreenSize CSScreenSize()
#endif

// main screen's width (portrait)
#ifndef kScreenWidth
#define kScreenWidth CSScreenSize().width
#endif

// main screen's height (portrait)
#ifndef kScreenHeight
#define kScreenHeight CSScreenSize().height
#endif




@interface NSObject (CGUtilities)

@end



NS_ASSUME_NONNULL_END
CS_EXTERN_C_END
