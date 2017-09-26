//
//  UIImageView+Extended.h
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Extended)


@property (nonatomic) BOOL needsBetterFace;
@property (nonatomic) BOOL fast;

void hack_uiimageview_bf(void);

- (void)setBetterFaceImage:(UIImage *)image;

/**
 根据bundle中的图片名创建imageview

 @param imageName bundle中的图片名
 @return UIImageView
 */
+ (id)imageViewWithImageNamed:(NSString*)imageName;
/**
 *  @brief  根据frame创建imageview
 *
 *  @param frame imageview frame
 *
 *  @return imageview
 */
+ (id)imageViewWithFrame:(CGRect)frame;

+ (id)imageViewWithStretchableImage:(NSString*)imageName Frame:(CGRect)frame;
/**
 *  @brief  创建imageview动画
 *
 *  @param imageArray 图片名称数组
 *  @param duration   动画时间
 *
 *  @return imageview
 */
+ (id)imageViewWithImageArray:(NSArray*)imageArray duration:(NSTimeInterval)duration;

- (void)setImageWithStretchableImage:(NSString*)imageName;


// 画水印
// 图片水印
- (void)setImage:(UIImage *)image withWaterMark:(UIImage *)mark inRect:(CGRect)rect;
// 文字水印
- (void)setImage:(UIImage *)image withStringWaterMark:(NSString *)markString inRect:(CGRect)rect color:(UIColor *)color font:(UIFont *)font;
- (void)setImage:(UIImage *)image withStringWaterMark:(NSString *)markString atPoint:(CGPoint)point color:(UIColor *)color font:(UIFont *)font;



- (CGPoint)convertPointFromImage:(CGPoint)imagePoint;
- (CGRect)convertRectFromImage:(CGRect)imageRect;

- (CGPoint)convertPointFromView:(CGPoint)viewPoint;
- (CGRect)convertRectFromView:(CGRect)viewRect;


/**
 设置基于初始文本视图的图像性能。随机背景色自动生成.
 
 @param string 字符串用来产生缩写的字符串。这应该是如果有一个用户的全名
 */
- (void)setImageWithString:(NSString *)string;

/**
 将根据视图的image属性初始文本和一个特定的背景颜色.
 
 @param string 字符串用来产生缩写的字符串。这应该是如果有一个用户的全名
 @param color 此可选参数设置图像的背景。如果没有提供，将产生一个随机颜色
 */
- (void)setImageWithString:(NSString *)string color:(UIColor *)color;


/**
 设置基于初始文本，特定的背景颜色，以及一个圆形剪裁视图的图像特性
 
 @param string 字符串用来产生缩写的字符串。这应该是如果有一个用户的全名
 @param color 此可选参数设置图像的背景。如果没有提供，将产生一个随机颜色
 @param isCircular 为圆这个布尔将决定图像显示将被剪切为圆形
 */
- (void)setImageWithString:(NSString *)string color:(UIColor *)color circular:(BOOL)isCircular;

/**
 设置基于初始文本，特定的背景颜色，自定义字体，和圆形剪裁视图的图像特性
 
 @param string 用来产生缩写的字符串。这应该是如果有一个用户的全名
 @param color (optional) 此可选参数设置图像的背景。如果没有提供，将产生一个随机颜色
 @param isCircular 这个布尔将决定图像显示将被剪切为圆形
 @param fontName 这将使用自定义字体属性。如果没有提供，则默认为系统字体
 */
- (void)setImageWithString:(NSString *)string color:(UIColor *)color circular:(BOOL)isCircular fontName:(NSString *)fontName;

/**
 设置基于初始文本，一个特定的背景颜色，自定义文本属性和一个圆形裁剪视图的image属性
 
 @param string 该字符串用于生成缩写。这应该是如果有一个用户的全名
 @param color (optional) 此可选参数设置图像的背景。如果没有提供，将产生一个随机颜色
 @param isCircular 这个布尔将决定图像显示将被剪切为圆形
 @param textAttributes 这本词典可以让你指定字体，文本颜色，阴影属性等，对于字母文字，使用NSAttributedString.h发现钥匙
 */
- (void)setImageWithString:(NSString *)string color:(UIColor *)color circular:(BOOL)isCircular textAttributes:(NSDictionary *)textAttributes;



/**
 *  @brief  倒影
 */
- (void)reflect;



//Ask the image to perform an "Aspect Fill" but centering the image to the detected faces
//Not the simple center of the image
- (void)faceAwareFill;




///MARK: GIF播放相关
/*******************************************************
 *  依赖:
 *      - QuartzCore.framework
 *      - ImageIO.framework
 *  参数:
 *      以下传参2选1：
 *      - gifData       GIF图片的NSData
 *      - gifPath       GIF图片的本地路径
 *  调用:
 *      - startGIF      开始播放
 *      - stopGIF       结束播放
 *      - isGIFPlaying  判断是否正在播放
 *******************************************************/

@property (nonatomic, strong) NSString          *gifPath;
@property (nonatomic, strong) NSData            *gifData;
@property (nonatomic, strong) NSNumber          *index,*frameCount,*timestamp;
@property (nonatomic, strong) NSDictionary      *indexDurations;
- (void)startGIF;
- (void)startGIFWithRunLoopMode:(NSString * const)runLoopMode;
- (void)stopGIF;
- (BOOL)isGIFPlaying;
- (CGSize) gifPixelSize;
- (CGImageRef) gifCreateImageForFrameAtIndex:(NSInteger)index;
- (float)gifFrameDurationAtIndex:(size_t)index;
- (NSArray*)frames;




@end


///MARK: GIF播放使用相关
/**
 
 UIImageView *gifView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 114, 81)];
 gifView.gifPath = [[NSBundle mainBundle] pathForResource:@"car.gif" ofType:nil];
 [gifView startGIF];
 
 */


