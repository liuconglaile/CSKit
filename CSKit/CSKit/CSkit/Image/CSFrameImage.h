//
//  CSFrameImage.h
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSAnimatedImageView.h"


NS_ASSUME_NONNULL_BEGIN

/**
 基于帧动画的图像视图
 
 @discussion
 它是一个完全兼容的'UIImage'子类.
 它只支持像png和jpeg这样的系统映像格式.
 动画可以由CSAnimatedImageView播放.
 
 示例代码:
 
 NSArray *paths = @[@"/ani/frame1.png", @"/ani/frame2.png", @"/ani/frame3.png"];
 NSArray *times = @[@0.1, @0.2, @0.1];
 CSFrameImage *image = [CSFrameImage alloc] initWithImagePaths:paths frameDurations:times repeats:YES];
 CSAnimatedImageView *imageView = [CSAnimatedImageView alloc] initWithImage:image];
 [view addSubView:imageView];
 
 */
@interface CSFrameImage : UIImage<CSAnimatedImage>

/**
 从文件创建一个帧动画图像

 图片路径数组示例: @[@"/ani/1.png",@"/ani/2.png",@"/ani/3.png"]
 
 @param paths 图片路径数组
 @param oneFrameDuration 每帧过渡时间(单位秒)
 @param loopCount 动画循环次数,0代表无穷大
 @return CSFrameImage对象,发生错误则返回 nil
 */
- (nullable instancetype)initWithImagePaths:(NSArray<NSString *> *)paths
                           oneFrameDuration:(NSTimeInterval)oneFrameDuration
                                  loopCount:(NSUInteger)loopCount;

/**
 从文件创建一个帧动画图像

 @param paths 图片路径数组
 @param frameDurations 对象的数组包含每帧的持续时间(以秒为单位) @[@0.1, @0.2, @0.3]
 @param loopCount 动画循环次数,0代表无穷大
 @return CSFrameImage对象,发生错误则返回 nil
 */
- (nullable instancetype)initWithImagePaths:(NSArray<NSString *> *)paths
                             frameDurations:(NSArray<NSNumber *> *)frameDurations
                                  loopCount:(NSUInteger)loopCount;

/**
 从一组图片data数据创建一个帧动画图像

 @param dataArray 图片 data 数组
 @param oneFrameDuration 每帧过渡时间(单位秒)
 @param loopCount 动画循环次数,0代表无穷大
 @return CSFrameImage对象,发生错误则返回 nil
 */
- (nullable instancetype)initWithImageDataArray:(NSArray<NSData *> *)dataArray
                               oneFrameDuration:(NSTimeInterval)oneFrameDuration
                                      loopCount:(NSUInteger)loopCount;

/**
 从一组图片data数据创建一个帧动画图像
 
 @param dataArray 图片 data 数组
 @param frameDurations 对象的数组包含每帧的持续时间(以秒为单位) @[@0.1, @0.2, @0.3]
 @param loopCount 动画循环次数,0代表无穷大
 @return CSFrameImage对象,发生错误则返回 nil
 */
- (nullable instancetype)initWithImageDataArray:(NSArray<NSData *> *)dataArray
                                 frameDurations:(NSArray *)frameDurations
                                      loopCount:(NSUInteger)loopCount;


@end
NS_ASSUME_NONNULL_END
