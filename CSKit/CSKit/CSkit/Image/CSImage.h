//
//  CSImage.h
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_include(<CSKit/CSKit.h>)
#import <CSKit/CSAnimatedImageView.h>
#import <CSKit/CSImageDecoder.h>
#else
#import "CSAnimatedImageView.h"
#import "CSImageDecoder.h"
#endif

NS_ASSUME_NONNULL_BEGIN




/**
 CSImage对象是一个高层次的方式来显示动画图像数据
 
 它是一个完全兼容的'UIImage'子类.
 它扩展了UIImage,支持动画WebP,APNG和GIF格式的图像数据解码.
 它还支持NSCoding协议来归档和解压缩多帧图像数
 
 如果图像是从多帧图像数据创建的,并且要播放动画,请尝试用'CSAnimatedImageView'替换UIImageView
 
 示例代码:
 
 // animation@3x.webp
 CSImage *image = [CSImage imageNamed:@"animation.webp"];
 CSAnimatedImageView *imageView = [CSAnimatedImageView alloc] initWithImage:image];
 [view addSubView:imageView];
 
 */
@interface CSImage : UIImage<CSAnimatedImage>

+ (nullable CSImage *)imageNamed:(NSString *)name; // no cache!
+ (nullable CSImage *)imageWithContentsOfFile:(NSString *)path;
+ (nullable CSImage *)imageWithData:(NSData *)data;
+ (nullable CSImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;

/** 如果图像是从数据或文件创建的,则该值指的是数据类型 */
@property (nonatomic, readonly) CSImageType animatedImageType;

/**
 如果图像是从动画图像数据(multi-frame GIF/APNG/WebP)创建的,则该属性存储原始图像数据.
 */
@property (nullable, nonatomic, readonly) NSData *animatedImageData;

/**
 如果所有帧图像被加载到内存中,总内存使用量(以字节为单位). 如果图像不是从多帧图像数据创建的,则值为0.
 */
@property (nonatomic, readonly) NSUInteger animatedImageMemorySize;

/**
 将所有帧图像预加载到内存
 
 将此属性设置为'YES'将阻止调用线程将所有动画帧图像解码为内存,设置为'NO'将释放预加载的帧.
 如果图像由许多图像视图共享(如表情符号),则预加载所有帧将降低CPU成本.
 
 有关内存成本,请参见'animatedImageMemorySize'.
 */
@property (nonatomic) BOOL preloadAllAnimatedImageFrames;




@end
NS_ASSUME_NONNULL_END
