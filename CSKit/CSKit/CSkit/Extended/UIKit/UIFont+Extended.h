//
//  UIFont+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (Extended)<NSCoding>

#pragma mark - 字体特征
///=============================================================================
/// @name 字体特征
///=============================================================================

@property (nonatomic, readonly) BOOL isBold NS_AVAILABLE_IOS(7_0); ///< 字体是否为粗体.
@property (nonatomic, readonly) BOOL isItalic NS_AVAILABLE_IOS(7_0); ///< 字体是否是斜体.
@property (nonatomic, readonly) BOOL isMonoSpace NS_AVAILABLE_IOS(7_0); ///< 字体是否等距.
@property (nonatomic, readonly) BOOL isColorGlyphs NS_AVAILABLE_IOS(7_0); ///< 字体是否是彩色字形(如表情符号).
@property (nonatomic, readonly) CGFloat fontWeight NS_AVAILABLE_IOS(7_0); ///< 字体重量从-1.0到1.0.常规重量为0.0.

/**
 从接收器创建一个粗体字体.
 @return 粗体字体,如果失败则为nil.
 */
- (nullable UIFont *)fontWithBold NS_AVAILABLE_IOS(7_0);

/**
 从接收器创建斜体字体.
 @return 斜体字体,如果失败则为nil.
 */
- (nullable UIFont *)fontWithItalic NS_AVAILABLE_IOS(7_0);

/**
 从接收器创建一个粗体和斜体字体.
 @return 粗体和斜体字体,如果失败,则为nil.
 */
- (nullable UIFont *)fontWithBoldItalic NS_AVAILABLE_IOS(7_0);

/**
 从接收器创建一个普通(不加粗/斜体/...)字体.
 @return 正常字体,如果失败,则为nil.
 */
- (nullable UIFont *)fontWithNormal NS_AVAILABLE_IOS(7_0);

#pragma mark - 创建字体
///=============================================================================
/// @name 创建字体
///=============================================================================


+ (instancetype)navFont;
+ (instancetype)nameFont;
+ (instancetype)font:(NSUInteger)size;
+ (instancetype)fontMedium:(NSUInteger)size;
+ (instancetype)fontLight:(NSUInteger)size;

+ (instancetype)boldFont:(UIFont *)font;

/**
 创建并返回指定的CTFontRef的字体对象.
 
 @param CTFont CoreText字体.
 */
+ (nullable UIFont *)fontWithCTFont:(CTFontRef)CTFont;

/**
 创建并返回指定的CGFontRef和大小的字体对象.
 
 @param CGFont  CoreGraphic字体.
 @param size    字体大小.
 */
+ (nullable UIFont *)fontWithCGFont:(CGFontRef)CGFont size:(CGFloat)size;

/**
 创建并返回CTFontRef对象.(使用后需要调用CFRelease())
 */
- (nullable CTFontRef)CTFontRef CF_RETURNS_RETAINED;

/**
 创建并返回CGFontRef对象.(使用后需要调用CFRelease())
 */
- (nullable CGFontRef)CGFontRef CF_RETURNS_RETAINED;


#pragma mark - 加载和卸载字体
///=============================================================================
/// @name 加载和卸载字体
///=============================================================================

/**
 从文件路径加载字体.支持格式:TTF,OTF.
 如果返回YES,字体可以加载使用它PostScript名称:[UIFont fontWithName:...]
 
 @param path   字体文件的完整路径
 */
+ (BOOL)loadFontFromPath:(NSString *)path;

/**
 从文件路径卸载字体.
 
 @param path    字体文件的完整路径
 */
+ (void)unloadFontFromPath:(NSString *)path;

/**
 从NSData 中加载字体.支持格式:TTF,OTF.
 
 @param data  字体文件数据.
 @return 如果加载成功返回UIFont对象,否则为 nil.
 */
+ (nullable UIFont *)loadFontFromData:(NSData *)data;

/**
 卸载由loadFontFromData加载的字体:function.
 
 @param font 由loadFontFromData加载的字体:function
 @return YES 如果成功,否则 NO.
 */
+ (BOOL)unloadFontFromData:(UIFont *)font;


#pragma mark - 转储字体数据
///=============================================================================
/// @name 转储字体数据
///=============================================================================


/**
 序列化并返回字体数据

 @param font 字体
 @return 在TTF中,如果发生错误则为nil
 */
+ (nullable NSData *)dataFromFont:(UIFont *)font;

/**
 序列化并返回字体数据.
 
 @param cgFont 字体.
 
 @return TTF中的数据,如果发生错误,则为nil.
 */
+ (nullable NSData *)dataFromCGFont:(CGFontRef)cgFont;

@end


NS_ASSUME_NONNULL_END



