//
//  CSAnimatedImageView.h
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN



/**
 用于显示动画图像的图像视图
 
 @discussion
 它是一个完全兼容的'UIImageView'子类。
 如果'image'或'highlightImage'属性采用'CSAnimatedImage'协议,那么它可以用来播放多帧动画.
 动画也可以用UIImageView方法'-startAnimating','-stopAnimating'和'-isAnimating'控制.
 
 CSAnimatedImageView正好及时请求帧数据.
 当设备有足够的可用内存时,CSAnimatedImageView可以将内部缓冲器中的一些或所有将来的帧缓存以降低CPU成本.
 缓冲区大小根据设备内存的当前状态进行动态调整.
 
 示例代码:
 // ani@3x.gif
 CSImage *image = [CSImage imageNamed:@"ani"];
 CSAnimatedImageView *imageView = [CSAnimatedImageView alloc] initWithImage:image];
 [view addSubView:imageView];
 
 
 */
@interface CSAnimatedImageView : UIImageView

/**
 如果图像有多个帧,则将该值设置为'YES',当视图变为(visible/invisible)时，将自动(play/stop)动画
 The default value is 'YES'
 */
@property (nonatomic) BOOL autoPlayAnimatedImage;

/**
 当前显示帧的索引(索引从0开始)
  
 为此属性设置一个新值将导致立即显示新的框架.如果新值无效,则此方法无效.
 您可以向此属性添加观察者来观察播放状态。
 */
@property (nonatomic) NSUInteger currentAnimatedImageIndex;

/**
 图像视图是否正在播放动画.您可以向此属性添加观察者来观察播放状态
 */
@property (nonatomic, readonly) BOOL currentIsPlayingAnimation;

/**
 动画定时器的runloop模式,默认为NSRunLoopCommonModes
 将此属性设置为'NSDefaultRunLoopMode'将使动画暂停UIScrollView滚动
 */
@property (nonatomic, copy) NSString *runloopMode;

/**
 内部帧缓冲区大小的最大大小 (以bytes字节为单位),默认值为 0 (dynamically).
 
 当设备具有足够的可用内存时,此视图将请求并解码一些或所有将来的帧图像到内部缓冲区.
 如果此属性的值为0,则最大缓冲区大小将根据设备空闲内存的当前状态进行动态调整.
 否则,缓冲区大小将受此值的限制.
  
 当接收内存警告或应用程序输入后台时,缓冲区将立即释放,并可能会在正确的时间增长
 
 */
@property (nonatomic) NSUInteger maxBufferSize;

@end




/**
 CSAnimatedImage协议声明了使用CSAnimatedImageView的动画图像显示所需的方法.
  
 将UIImage子类化并实现此协议,使该类的实例可以设置为
 CSAnimatedImageView.image或
 CSAnimatedImageView.highlightedImage以显示动画.
  
 请参见CSImage和CSFrameImage
 */
@protocol CSAnimatedImage <NSObject>
@required
/**
 总动画帧数,如果帧数小于1,那么以下方法将被忽略

 @return 总动画帧数
 */
- (NSUInteger)animatedImageFrameCount;

/** 动画循环计数,0表示无限循环 */
- (NSUInteger)animatedImageLoopCount;

/** 每帧字节(在存储器中).它可用于优化存储器缓冲区大小 */
- (NSUInteger)animatedImageBytesPerFrame;

/**
 从指定的索引返回帧图像(此方法可在后台线程调用)

 @param index 帧索引(基于0启动)
 */
- (nullable UIImage *)animatedImageFrameAtIndex:(NSUInteger)index;

/**
 从指定的索引返回帧的持续时间

 @param index 帧索引(基于0启动)
 */
- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index;

@optional
/**
 定义要显示的图像的子矩形的图像坐标中的矩形.
 矩形不应该在图像的边界之外.它可能用于使用单个图像(精灵图)显示精灵动画。
 */
- (CGRect)animatedImageContentsRectAtIndex:(NSUInteger)index;



@end
NS_ASSUME_NONNULL_END




