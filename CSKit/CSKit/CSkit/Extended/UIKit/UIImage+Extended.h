//
//  UIImage+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 精确度枚举
 
 - CSAccuracyLow: 低
 - CSAccuracyHigh: 高
 */
typedef NS_ENUM(NSUInteger, CSAccuracy) {
    CSAccuracyLow = 0,
    CSAccuracyHigh,
};

typedef void (^CSUIImageSizeRequestCompleted) (NSURL* imgURL, CGSize size);

@interface UIImage (Extended)

#pragma mark - Create image
///=============================================================================
/// @name Create image
///=============================================================================

/**
 Create an animated image with GIF data. After created, you can access
 the images via property '.images'. If the data is not animated gif, this
 function is same as [UIImage imageWithData:data scale:scale];
 
 @discussion     It has a better display performance, but costs more memory
 (width * height * frames Bytes). It only suited to display small
 gif such as animated emoticon. If you want to display large gif,
 see `YYImage`.
 
 @param data     GIF data.
 
 @param scale    The scale factor
 
 @return A new image created from GIF, or nil when an error occurs.
 */
+ (nullable UIImage *)imageWithSmallGIFData:(NSData *)data scale:(CGFloat)scale;

/**
 Whether the data is animated GIF.
 
 @param data Image data
 
 @return Returns YES only if the data is gif and contains more than one frame,
 otherwise returns NO.
 */
+ (BOOL)isAnimatedGIFData:(NSData *)data;

/**
 Whether the file in the specified path is GIF.
 
 @param path An absolute file path.
 
 @return Returns YES if the file is gif, otherwise returns NO.
 */
+ (BOOL)isAnimatedGIFFile:(NSString *)path;

/**
 Create an image from a PDF file data or path.
 
 @discussion If the PDF has multiple page, is just return's the first page's
 content. Image's scale is equal to current screen's scale, size is same as
 PDF's origin size.
 
 @param dataOrPath PDF data in `NSData`, or PDF file path in `NSString`.
 
 @return A new image create from PDF, or nil when an error occurs.
 */
+ (nullable UIImage *)imageWithPDF:(id)dataOrPath;

/**
 Create an image from a PDF file data or path.
 
 @discussion If the PDF has multiple page, is just return's the first page's
 content. Image's scale is equal to current screen's scale.
 
 @param dataOrPath  PDF data in `NSData`, or PDF file path in `NSString`.
 
 @param size     The new image's size, PDF's content will be stretched as needed.
 
 @return A new image create from PDF, or nil when an error occurs.
 */
+ (nullable UIImage *)imageWithPDF:(id)dataOrPath size:(CGSize)size;

/**
 Create a square image from apple emoji.
 
 @discussion It creates a square image from apple emoji, image's scale is equal
 to current screen's scale. The original emoji image in `AppleColorEmoji` font
 is in size 160*160 px.
 
 @param emoji single emoji, such as @"😄".
 
 @param size  image's size.
 
 @return Image from emoji, or nil when an error occurs.
 */
+ (nullable UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size;

/**
 Create and return a 1x1 point size image with the given color.
 
 @param color  The color.
 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color;

/**
 Create and return a pure color image with the given color and size.
 
 @param color  The color.
 @param size   New image's type.
 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 Create and return an image with custom draw code.
 
 @param size      The image size.
 @param drawBlock The draw block.
 
 @return The new image.
 */
+ (nullable UIImage *)imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock;

#pragma mark - Image Info
///=============================================================================
/// @name Image Info
///=============================================================================

/**
 Whether this image has alpha channel.
 */
- (BOOL)hasAlphaChannel;


#pragma mark - Modify Image
///=============================================================================
/// @name Modify Image
///=============================================================================

/**
 Draws the entire image in the specified rectangle, content changed with
 the contentMode.
 
 @discussion This method draws the entire image in the current graphics context,
 respecting the image's orientation setting. In the default coordinate system,
 images are situated down and to the right of the origin of the specified
 rectangle. This method respects any transforms applied to the current graphics
 context, however.
 
 @param rect        The rectangle in which to draw the image.
 
 @param contentMode Draw content mode
 
 @param clips       A Boolean value that determines whether content are confined to the rect.
 */
- (void)drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;

/**
 Returns a new image which is scaled from this image.
 The image will be stretched as needed.
 
 @param size  The new size to be scaled, values should be positive.
 
 @return      The new image with the given size.
 */
- (nullable UIImage *)imageByResizeToSize:(CGSize)size;

/**
 Returns a new image which is scaled from this image.
 The image content will be changed with thencontentMode.
 
 @param size        The new size to be scaled, values should be positive.
 
 @param contentMode The content mode for image content.
 
 @return The new image with the given size.
 */
- (nullable UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

/**
 Returns a new image which is cropped from this image.
 
 @param rect  Image's inner rect.
 
 @return      The new image, or nil if an error occurs.
 */
- (nullable UIImage *)imageByCropToRect:(CGRect)rect;

/**
 Returns a new image which is edge inset from this image.
 
 @param insets  Inset (positive) for each of the edges, values can be negative to 'outset'.
 
 @param color   Extend edge's fill color, nil means clear color.
 
 @return        The new image, or nil if an error occurs.
 */
- (nullable UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(nullable UIColor *)color;

/**
 Rounds a new image with a given corner size.
 
 @param radius  The radius of each corner oval. Values larger than half the
 rectangle's width or height are clamped appropriately to half
 the width or height.
 */
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius;

/**
 Rounds a new image with a given corner size.
 
 @param radius       The radius of each corner oval. Values larger than half the
 rectangle's width or height are clamped appropriately to
 half the width or height.
 
 @param borderWidth  The inset border line width. Values larger than half the rectangle's
 width or height are clamped appropriately to half the width
 or height.
 
 @param borderColor  The border stroke color. nil means clear color.
 */
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(nullable UIColor *)borderColor;

/**
 Rounds a new image with a given corner size.
 
 @param radius       The radius of each corner oval. Values larger than half the
 rectangle's width or height are clamped appropriately to
 half the width or height.
 
 @param corners      A bitmask value that identifies the corners that you want
 rounded. You can use this parameter to round only a subset
 of the corners of the rectangle.
 
 @param borderWidth  The inset border line width. Values larger than half the rectangle's
 width or height are clamped appropriately to half the width
 or height.
 
 @param borderColor  The border stroke color. nil means clear color.
 
 @param borderLineJoin The border line join.
 */
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                       corners:(UIRectCorner)corners
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(nullable UIColor *)borderColor
                                borderLineJoin:(CGLineJoin)borderLineJoin;

/**
 Returns a new rotated image (relative to the center).
 
 @param radians   Rotated radians in counterclockwise.⟲
 
 @param fitSize   YES: new image's size is extend to fit all content.
 NO: image's size will not change, content may be clipped.
 */
- (nullable UIImage *)imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize;

/**
 Returns a new image rotated counterclockwise by a quarter‑turn (90°). ⤺
 The width and height will be exchanged.
 */
- (nullable UIImage *)imageByRotateLeft90;

/**
 Returns a new image rotated clockwise by a quarter‑turn (90°). ⤼
 The width and height will be exchanged.
 */
- (nullable UIImage *)imageByRotateRight90;

/**
 Returns a new image rotated 180° . ↻
 */
- (nullable UIImage *)imageByRotate180;

/**
 Returns a vertically flipped image. ⥯
 */
- (nullable UIImage *)imageByFlipVertical;

/**
 Returns a horizontally flipped image. ⇋
 */
- (nullable UIImage *)imageByFlipHorizontal;


#pragma mark - Image Effect
///=============================================================================
/// @name Image Effect
///=============================================================================

/**
 Tint the image in alpha channel with the given color.
 
 @param color  The color.
 */
- (nullable UIImage *)imageByTintColor:(UIColor *)color;

/**
 Returns a grayscaled image.
 */
- (nullable UIImage *)imageByGrayscale;

/**
 Applies a blur effect to this image. Suitable for blur any content.
 */
- (nullable UIImage *)imageByBlurSoft;

/**
 Applies a blur effect to this image. Suitable for blur any content except pure white.
 (same as iOS Control Panel)
 */
- (nullable UIImage *)imageByBlurLight;

/**
 Applies a blur effect to this image. Suitable for displaying black text.
 (same as iOS Navigation Bar White)
 */
- (nullable UIImage *)imageByBlurExtraLight;

/**
 Applies a blur effect to this image. Suitable for displaying white text.
 (same as iOS Notification Center)
 */
- (nullable UIImage *)imageByBlurDark;

/**
 Applies a blur and tint color to this image.
 
 @param tintColor  The tint color.
 */
- (nullable UIImage *)imageByBlurWithTint:(UIColor *)tintColor;

/**
 Applies a blur, tint color, and saturation adjustment to this image,
 optionally within the area specified by @a maskImage.
 
 @param blurRadius     The radius of the blur in points, 0 means no blur effect.
 
 @param tintColor      An optional UIColor object that is uniformly blended with
 the result of the blur and saturation operations. The
 alpha channel of this color determines how strong the
 tint is. nil means no tint.
 
 @param tintBlendMode  The @a tintColor blend mode. Default is kCGBlendModeNormal (0).
 
 @param saturation     A value of 1.0 produces no change in the resulting image.
 Values less than 1.0 will desaturation the resulting image
 while values greater than 1.0 will have the opposite effect.
 0 means gray scale.
 
 @param maskImage      If specified, @a inputImage is only modified in the area(s)
 defined by this mask.  This must be an image mask or it
 must meet the requirements of the mask parameter of
 CGContextClipToMask.
 
 @return               image with effect, or nil if an error occurs (e.g. no
 enough memory).
 */
- (nullable UIImage *)imageByBlurRadius:(CGFloat)blurRadius
                              tintColor:(nullable UIColor *)tintColor
                               tintMode:(CGBlendMode)tintBlendMode
                             saturation:(CGFloat)saturation
                              maskImage:(nullable UIImage *)maskImage;





///MARK:==========================================
///MARK:AnimatedGIF相关
///MARK:==========================================

+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)theData;
+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)theURL;
+ (UIImage *)animatedGIFNamed:(NSString *)name;
+ (UIImage *)animatedGIFWithData:(NSData *)data;
- (UIImage *)animatedImageByScalingAndCroppingToSize:(CGSize)size;

///MARK:==========================================
///MARK:AnimatedGIF相关
///MARK:==========================================


///MARK:==========================================
///MARK:人脸识别相关
///MARK:==========================================

- (UIImage *)betterFaceImageForSize:(CGSize)size accuracy:(CSAccuracy)accurary;

///MARK:==========================================
///MARK:人脸识别相关
///MARK:==========================================


///MARK:==========================================
///MARK:常用方法
///MARK:==========================================

/**
 根据字符串生成字体图标
 
 @param font 图标字体
 @param iconNamed 图标内容字符串
 @param tintColor 渲染颜色
 @param clipToBounds 裁剪多余
 @param fontSize 字体尺寸
 @return 生成的图标
 */
+ (UIImage *)iconWithFont:(UIFont *)font named:(NSString *)iconNamed
            withTintColor:(UIColor *)tintColor clipToBounds:(BOOL)clipToBounds forSize:(CGFloat)fontSize;




/**
 根据 PDF 文件生成图标
 
 @param pdfNamed  应用程序资源目录中的PDF文件的名称
 @param height 生成的图像的高度,宽度将基于PDF的宽高比
 @return 生成的图标
 */
+ (UIImage *)imageWithPDFNamed:(NSString *)pdfNamed forHeight:(CGFloat)height;



/**
 根据 PDF 文件生成图标
 
 @param pdfNamed 应用程序资源目录中的PDF文件的名称
 @param tintColor 用于图标的色调.如果没有色调将不会使用
 @param height 生成的图像的高度,宽度将基于PDF的宽高比
 @return 生成的图标
 */
+ (UIImage *)imageWithPDFNamed:(NSString *)pdfNamed withTintColor:(nullable UIColor *)tintColor forHeight:(CGFloat)height;



/**
 根据 PDF 文件生成图标
 
 @param pdfFile PDF文件的路径
 @param tintColor 用于图标的色调.如果没有色调将不会使用
 @param size 生成的图像的最大大小. 图像将保持其宽高比,并且可能不会包含全尺寸
 @return 生成的图像
 */
+ (UIImage *)imageWithPDFFile:(NSString *)pdfFile withTintColor:(nullable UIColor *)tintColor forSize:(CGSize)size;





/**
 *  压缩上传图片到指定字节
 *
 *  @param image     压缩的图片
 *  @param maxLength 压缩后最大字节大小
 *
 *  @return 压缩后图片的二进制
 */
+ (NSData *)compressImage:(UIImage *)image toMaxLength:(NSInteger) maxLength maxWidth:(NSInteger)maxWidth;

/**
 *  获得指定size的图片
 *
 *  @param image   原始图片
 *  @param newSize 指定的size
 *
 *  @return 调整后的图片
 */
+ (UIImage *)resizeImage:(UIImage *) image withNewSize:(CGSize) newSize;

// 图片可能会变形
- (UIImage *)resizeImageWithSize:(CGSize)size;


// 考虑到图片的比例来压缩，以宽？高？为准
- (UIImage *)resizeAspectImageWithSize:(CGSize)size;

/**
 *  通过指定图片最长边，获得等比例的图片size
 *
 *  @param image       原始图片
 *  @param imageLength 图片允许的最长宽度（高度）
 *
 *  @return 获得等比例的size
 */
+ (CGSize)scaleImage:(UIImage *) image withLength:(CGFloat) imageLength;


+ (UIImage*)resizableHalfImage:(NSString *)name;




/**
 *  @brief 获取远程图片的大小
 *
 *  @param imgURL     图片url
 *  @param completion 完成回调
 */
+ (void)requestSizeNoHeader:(NSURL*)imgURL completion:(CSUIImageSizeRequestCompleted)completion;
/**
 从header中获取远程图片的大小 (服务器必须支持)
 
 @param imgURL     图片url
 @param completion 完成回调
 */
//+ (void)requestSizeWithHeader:(NSURL*)imgURL completion:(CSUIImageSizeRequestCompleted)completion;





/**
 根据main bundle中的文件名读取图片
 
 @param name 图片名
 @return 无缓存的图片
 */
+ (UIImage *)imageWithFileName:(NSString *)name;
/**
 根据指定bundle中的文件名读取图片
 
 @param name   图片名
 @param bundle bundle
 @return 无缓存的图片
 */
+ (UIImage *)imageWithFileName:(NSString *)name inBundle:(NSBundle*)bundle;

///MARK:==========================================
///MARK:常用方法
///MARK:==========================================


@end

NS_ASSUME_NONNULL_END
