//
//  UIImage+Blur.h
//  CSCategory
//
//  Created by mac on 17/5/16.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double ImageEffectsVersionNumber;
FOUNDATION_EXPORT const unsigned char ImageEffectsVersionString[];

@interface UIImage (Blur)


/** 灯光 */
- (UIImage *)lightImage;
/** 额外的光图像 */
- (UIImage *)extraLightImage;
/** 暗图像 */
- (UIImage *)darkImage;
/** 图像着色 */
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;
/** 图像模糊，半径 */
- (UIImage *)blurredImageWithRadius:(CGFloat)blurRadius;
/** 模糊图像根据尺寸 */
- (UIImage *)blurredImageWithSize:(CGSize)blurSize;
/** 图像模糊 根据尺寸&颜色&饱和度&蒙版图像 */
- (UIImage *)blurredImageWithSize:(CGSize)blurSize tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
/** 截图指定view成图片 */
+ (UIImage *)captureWithView:(UIView *)view;
/** <#内容#> */
+ (UIImage *)getImageWithSize:(CGRect)myImageRect FromImage:(UIImage *)bigImage;
/** 截图一个view中所有视图 包括旋转缩放效果 */
+ (UIImage *)screenshotWithView:(UIView *)aView limitWidth:(CGFloat)maxWidth;
/** 根据颜色生成纯色图片 */
+ (UIImage *)imageWithColor:(UIColor *)color;
/** 取图片某一点的颜色 */
- (UIColor *)colorAtPoint:(CGPoint )point;
/** 取某一像素的颜色 */
- (UIColor *)colorAtPixel:(CGPoint)point;
/** 该图片是否有透明度通道 */
- (BOOL)hasAlphaChannel;
/** 获得灰度图 */
+ (UIImage*)covertToGrayImageFromImage:(UIImage*)sourceImage;
/** 图像裁剪到矩形 */
- (UIImage *)imageCroppedToRect:(CGRect)rect;
/** 图像缩放到大小 */
- (UIImage *)imageScaledToSize:(CGSize)size;
/** 图像缩放到适合尺寸 */
- (UIImage *)imageScaledToFitSize:(CGSize)size;
/** 图像缩放到全尺寸 */
- (UIImage *)imageScaledToFillSize:(CGSize)size;
/** 图像裁剪和缩放到大小 &显示方式&是否自适应 */
- (UIImage *)imageCroppedAndScaledToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode padToFit:(BOOL)padToFit;
/** 映射图像的缩放 */
- (UIImage *)reflectedImageWithScale:(CGFloat)scale;
/** 反射图片 */
- (UIImage *)imageWithReflectionWithScale:(CGFloat)scale gap:(CGFloat)gap alpha:(CGFloat)alpha;
/** 设置图片阴影 */
- (UIImage *)imageWithShadowColor:(UIColor *)color offset:(CGSize)offset blur:(CGFloat)blur;
/** 圆角图像 & 半径 */
- (UIImage *)imageWithCornerRadius:(CGFloat)radius;
/** 图像透明 */
- (UIImage *)imageWithAlpha:(CGFloat)alpha;
/** 图像添加蒙版 */
- (UIImage *)imageWithMask:(UIImage *)maskImage;
/** 带蒙版的透明图像 */
- (UIImage *)maskImageFromImageAlpha;
/** 合并两个图片 */
+ (UIImage*)mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage;

//CGFloat DegreesToRadiansForOrientation(CGFloat degrees) {return degrees * M_PI / 180;};
//CGFloat RadiansToDegreesForOrientation(CGFloat radians) {return radians * 180/M_PI;};
/** 修正图片的方向 */
+ (UIImage *)fixOrientation:(UIImage *)srcImg;
/** 旋转图片 */
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
/** 旋转图片 */
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
/** 垂直翻转 */
- (UIImage *)flipVertical;
/** 水平翻转 */
- (UIImage *)flipHorizontal;
/** 角度转弧度 */
+(CGFloat)degreesToRadians:(CGFloat)degrees;
/** 弧度转角度 */
+(CGFloat)radiansToDegrees:(CGFloat)radians;

//圆角图片&边框大小
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;


- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
- (UIImage *)trimmedBetterSize;
- (UIImage *)croppedImage:(CGRect)bounds;

- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
             transparentBorder:(NSUInteger)borderSize
                  cornerRadius:(NSUInteger)cornerRadius
          interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize
        interpolationQuality:(CGInterpolationQuality)quality;

//调整图像的内容模式
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                     bounds:(CGSize)bounds
                       interpolationQuality:(CGInterpolationQuality)quality;



- (UIImage *)LOMOFilterOutput;      //LOMO
- (UIImage *)grayFilterOutput;      //黑白
- (UIImage *)vintageFilterOutput;   //复古
- (UIImage *)geteFilterOutput;      //哥特
- (UIImage *)sharpFilterOutput;     //锐化
- (UIImage *)elegantFilterOutput;   //淡雅
- (UIImage *)redWineFilterOutput;   //酒红
- (UIImage *)quietFilterOutput;     //清宁
- (UIImage *)romanticFilterOutput;  //浪漫
- (UIImage *)shineFilterOutput;     //光晕
- (UIImage *)blueFilterOutput;      //蓝调
- (UIImage *)dreamFilterOutput;     //梦幻
- (UIImage *)darkFilterOutput;      //夜色
- (UIImage *)gaussBlurFilterWithLevel:(CGFloat)blurLevel; //高斯模糊X
- (UIImage *)blurWithLevel:(CGFloat)blurLevel;            //水平模糊



@end
