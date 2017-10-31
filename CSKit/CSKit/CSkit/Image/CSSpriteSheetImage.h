//
//  CSSpriteSheetImage.h
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSAnimatedImageView.h"


NS_ASSUME_NONNULL_BEGIN


/**
 显示精灵片动画的图像
 
 它是一个完全兼容的'UIImage'子类. 动画可以由CSAnimatedImageView播放
 使用详情参考1-1
 */
@interface CSSpriteSheetImage : UIImage


/**
 创建并返回图像对象

 @param image 精灵图片图像(包含所有Frames)
 @param contentRects 图像坐标中的sprite sheet图像框架.矩形不应该在图像的边界之外.这个数组中的对象应该使用[NSValue valueWithCGRect:]创建
 @param frameDurations 精灵图片框架的持续时间(以秒为单位).该数组中的对象应该是NSNumber
 @param loopCount 动画循环计数,0表示无限循环
 @return 图像对象,如果发生错误,则为nil
 */
- (nullable instancetype)initWithSpriteSheetImage:(UIImage *)image
                                     contentRects:(NSArray<NSValue *> *)contentRects
                                   frameDurations:(NSArray<NSNumber *> *)frameDurations
                                        loopCount:(NSUInteger)loopCount;

@property (nonatomic, readonly) NSArray<NSValue *> *contentRects;
@property (nonatomic, readonly) NSArray<NSValue *> *frameDurations;
@property (nonatomic, readonly) NSUInteger loopCount;


/**
 获取CALayer的内容
 有关详细信息,请参阅CALayer中的'contentsRect'属性

 @param index 帧索引
 @return 内容矩形
 */
- (CGRect)contentsRectForCALayerAtIndex:(NSUInteger)index;

@end
NS_ASSUME_NONNULL_END


///MARK: 示例代码1-1
/** 
 示例代码1-1:
 
 // 8 * 12个精灵在单张图像中
 UIImage *spriteSheet = [UIImage imageNamed:@"sprite-sheet"];
 NSMutableArray *contentRects = [NSMutableArray new];
 NSMutableArray *durations = [NSMutableArray new];
 
 for (int j = 0; j < 12; j++) {
     for (int i = 0; i < 8; i++) {
         CGRect rect;
         rect.size = CGSizeMake(img.size.width / 8, img.size.height / 12);
         rect.origin.x = img.size.width / 8 * i;
         rect.origin.y = img.size.height / 12 * j;
         [contentRects addObject:[NSValue valueWithCGRect:rect]];
         [durations addObject:@(1 / 60.0)];
     }
 }
 
 YYSpriteSheetImage *sprite;
 sprite = [[YYSpriteSheetImage alloc] initWithSpriteSheetImage:img
                                                  contentRects:contentRects
                                                frameDurations:durations
                                                     loopCount:0];
 
 YYAnimatedImageView *imgView = [YYAnimatedImageView new];
 imgView.size = CGSizeMake(img.size.width / 8, img.size.height / 12);
 imgView.image = sprite;
 
 
 
 @discussion 它也可以用于在sprite sheet图像中显示单帧.
 示例代码:
 
 YYSpriteSheetImage *sheet = ...;
 UIImageView *imageView = ...;
 imageView.image = sheet;
 imageView.layer.contentsRect = [sheet contentsRectForCALayerAtIndex:6];
 
 */


