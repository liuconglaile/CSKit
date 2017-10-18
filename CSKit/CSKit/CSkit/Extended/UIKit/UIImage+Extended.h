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

#pragma mark - 创建图像


/**
 使用GIF数据创建动画图像
 
 创建后,您可以通过属性'.images'访问图像.
 如果数据不是动画gif,这个功能与[UIImage imageWithData：data scale：scale]相同;
  
 @discussion
 它具有更好的显示性能,但成本更高的内存(width*height*frames Bytes).
 它只适合显示小gif,如动画表情符号.
 如果你想显示大的gif,参见'CSImage'.
 
 @param data gif数据
 @param scale 比例
 @return 动态图
 */
+ (nullable UIImage *)imageWithSmallGIFData:(NSData *)data scale:(CGFloat)scale;

/** 数据是否为 gif 图像 */
+ (BOOL)isAnimatedGIFData:(NSData *)data;

/** 指定路径中的文件是否为GIF */
+ (BOOL)isAnimatedGIFFile:(NSString *)path;

/**
 从PDF文件数据或路径创建图像
 如果PDF有多个页面,只是返回第一页内容.
 图像的比例等于当前屏幕的尺度,大小与原来的PDF的尺寸相同.
 
 @param dataOrPath  pdf 文件路径
 @return 从 pdf 文件创建的图像,如果发生错误则返回 nil
 */
+ (nullable UIImage *)imageWithPDF:(id)dataOrPath;


/**
 从PDF文件数据或路径创建图像
 (基本属性同上)
 @param dataOrPath  pdf 文件路径
 @param size 图片尺寸(会导致拉伸)
 @return 从 pdf 创建的图像
 */
+ (nullable UIImage *)imageWithPDF:(id)dataOrPath size:(CGSize)size;


/**
 基于 Emoji 表情创建一个方形图像(Emoji 原始尺寸160*160)
 
 @param emoji 手动输入的表情
 @param size 图片大小
 @return 表情图片,发生错误是为 nil
 */
+ (nullable UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size;

/** 使用给定的颜色创建并返回1x1点大小的图像 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color;

/** 创建并返回具有给定颜色和大小的纯彩色图像 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 使用自定义绘图代码创建并返回图像
 
 @param size 图像大小
 @param drawBlock 绘制块
 @return 新图片
 */
+ (nullable UIImage *)imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock;

#pragma mark - 图像信息

/** 该图像是否具有Alpha通道 */
- (BOOL)hasAlphaChannel;


#pragma mark - 修改图像
/**
 在指定的矩形中绘制整个图像,内容随contentMode更改
 
 该方法在当前的图形上下文中绘制整个图像，并遵循图像的方向设置。
 在默认坐标系中，图像位于指定矩形原点的下方和右侧。
 然而，该方法遵循应用于当前图形上下文的任何变换。
 
 @param rect 绘制图像的矩形
 @param contentMode 内容显示模式
 @param clips 是否剪裁多余
 */
- (void)drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;


/**
 返回从该图像缩放的新图像. 图像内容将根据需要缩放
 
 @param size 新尺寸
 @return 新图像
 */
- (nullable UIImage *)imageByResizeToSize:(CGSize)size;


/**
 返回从该图像缩放的新图像. 图像内容将随着内容模式更改
 
 @param size 新尺寸
 @param contentMode 显示模式
 @return 新的图像
 */
- (nullable UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

/** 从图像内部裁剪出新的图像 */
- (nullable UIImage *)imageByCropToRect:(CGRect)rect;

/**
 设置圆角内间距
 
 @param insets 内间距
 @param color 间距底色, nil 为清晰色
 @return 新图像
 */
- (nullable UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(nullable UIColor *)color;

/** 图片设置圆角 */
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius;

/** 图片设置圆角&边框 */
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(nullable UIColor *)borderColor;


/**
 图片设置圆角&边框
 
 @param radius 圆角半径
 @param corners 指定圆角位置
 @param borderWidth 边框大小
 @param borderColor 边框颜色
 @param borderLineJoin 边框连接线样式(虚线)
 @return 新图片
 */
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                       corners:(UIRectCorner)corners
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(nullable UIColor *)borderColor
                                borderLineJoin:(CGLineJoin)borderLineJoin;

/**
 返回一个新的旋转图像(相对于中心).
 
 @param radians   逆时针旋转弧度.⟲
 @param fitSize   YES: 新的图像的尺寸被拉伸,以适应所有内容.
 NO: 图像的大小不会改变,内容可能会被剪辑.
 */
- (nullable UIImage *)imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize;

/**
 返回逆时针旋转四分之一圈的新图像 (90°). ⤺
 宽度和高度将被交换.
 */
- (nullable UIImage *)imageByRotateLeft90;

/**
 返回顺时针旋转四分之一圈的新图像 (90°). ⤼
 宽度和高度将被交换.
 */
- (nullable UIImage *)imageByRotateRight90;

/**
 返回一个旋转的新图像 180° . ↻
 */
- (nullable UIImage *)imageByRotate180;

/**
 返回垂直翻转的图像. ⥯
 */
- (nullable UIImage *)imageByFlipVertical;

/**
 返回一个水平翻转的图像. ⇋
 */
- (nullable UIImage *)imageByFlipHorizontal;

///=============================================================================
/// @name 图像效果
///=============================================================================

/**
 使用给定的颜色对Alpha通道中的图像进行着色.
 
 @param color  渲染颜色.
 */
- (nullable UIImage *)imageByTintColor:(UIColor *)color;

/**
 返回灰度图像.
 */
- (nullable UIImage *)imageByGrayscale;

/**
 对此图像应用模糊效果. 适合模糊任何内容.
 */
- (nullable UIImage *)imageByBlurSoft;

/**
 对此图像应用模糊效果. 适合于模糊任何除纯白色以外的内容. (与iOS控制面板相同)
 */
- (nullable UIImage *)imageByBlurLight;

/**
 对此图像应用模糊效果. 适合显示黑色文字.(与iOS导航栏白色相同)
 */
- (nullable UIImage *)imageByBlurExtraLight;

/**
 对此图像应用模糊效果. 适合显示白色文字. (与iOS通知中心相同)
 */
- (nullable UIImage *)imageByBlurDark;

/**
 对此图像应用模糊和色彩.
 
 @param tintColor  色调颜色.
 */
- (nullable UIImage *)imageByBlurWithTint:(UIColor *)tintColor;

/**
 对图片设置模糊&色彩&饱和度,可设置在指定的区域
 
 @param blurRadius 模糊半径,0为不设模糊
 @param tintColor  alpha 通道渲染色值
 @param tintBlendMode 混合模式,默认为 kCGBlendModeNormal (0)
 @param saturation 饱和度 1为不变, minValue < 1 < maxValue 均可设置不同效果饱和度
 @param maskImage 如果指定,@a inputImage仅在此掩码定义的区域中进行修改.这必须是一个图像掩码,或者它必须满足CGContextClipToMask的mask参数的要求.
 @return 有效图像,如果发生错误,则返回 nil(例如内存不足).
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
 压缩上传图片到指定字节
 
 @param image     压缩的图片
 @param maxLength 压缩后最大字节大小
 @return 压缩后图片的二进制
 */
+ (NSData *)compressImage:(UIImage *)image toMaxLength:(NSInteger) maxLength maxWidth:(NSInteger)maxWidth;

/**
 获得指定size的图片
 
 @param image   原始图片
 @param newSize 指定的size
 @return 调整后的图片
 */
+ (UIImage *)resizeImage:(UIImage *) image withNewSize:(CGSize) newSize;

// 图片可能会变形
- (UIImage *)resizeImageWithSize:(CGSize)size;


// 考虑到图片的比例来压缩,以宽？高？为准
- (UIImage *)resizeAspectImageWithSize:(CGSize)size;

/**
 通过指定图片最长边,获得等比例的图片size
 
 @param image       原始图片
 @param imageLength 图片允许的最长宽度（高度）
 @return 获得等比例的size
 */
+ (CGSize)scaleImage:(UIImage *) image withLength:(CGFloat) imageLength;


+ (UIImage*)resizableHalfImage:(NSString *)name;




/**
 获取远程图片的大小
 
 @param imgURL     图片url
 @param completion 完成回调
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
