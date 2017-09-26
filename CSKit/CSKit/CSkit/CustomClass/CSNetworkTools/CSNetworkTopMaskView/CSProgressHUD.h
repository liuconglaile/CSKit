//
//  CSProgressHUD.h
//  CSCategory
//
//  Created by mac on 2017/7/31.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@class CSBackgroundView;
@protocol CSProgressHUDDelegate;



/** 进度最大偏移值 */
extern CGFloat const CSProgressMaxOffset;


/**
 进度模型枚举
 
 - CSProgressHUDModeIndeterminate: 菊花
 - CSProgressHUDModeDeterminate: 一个圆形的饼图,进度视图
 - CSProgressHUDModeDeterminateHorizontalBar: 水平进度条
 - CSProgressHUDModeAnnularDeterminate: 环形进度视图
 - CSProgressHUDModeCustomView: 显示自定义视图
 - CSProgressHUDModeText: 仅显示标签
 */
typedef NS_ENUM(NSInteger, CSProgressHUDMode) {
    CSProgressHUDModeIndeterminate,
    CSProgressHUDModeDeterminate,
    CSProgressHUDModeDeterminateHorizontalBar,
    CSProgressHUDModeAnnularDeterminate,
    CSProgressHUDModeCustomView,
    CSProgressHUDModeText
};


/**
 动画模型枚举
 
 - CSProgressHUDAnimationFade: 不透明度动画
 - CSProgressHUDAnimationZoom: 不透明度+缩放动画(消失时缩小时放大)
 - CSProgressHUDAnimationZoomOut: 不透明度+缩放动画(缩小风格)
 - CSProgressHUDAnimationZoomIn: 不透明度+缩放动画(放大风格)
 */
typedef NS_ENUM(NSInteger, CSProgressHUDAnimation) {
    CSProgressHUDAnimationFade,
    CSProgressHUDAnimationZoom,
    CSProgressHUDAnimationZoomOut,
    CSProgressHUDAnimationZoomIn
};


/**
 背景枚举
 
 - CSProgressHUDBackgroundStyleSolidColor: 纯色背景
 - CSProgressHUDBackgroundStyleBlur: UIVisualEffectView或UIToolbar.layer背景视图(黑色或者白色高斯模糊)
 */
typedef NS_ENUM(NSInteger, CSProgressHUDBackgroundStyle) {
    CSProgressHUDBackgroundStyleSolidColor,
    CSProgressHUDBackgroundStyleBlur
};

typedef void (^CSProgressHUDCompletionBlock)(void);


NS_ASSUME_NONNULL_BEGIN





/**
 显示一个简单的HUD窗口,其中包含进度指示器和两个可选的短消息标签
 这是一个简单的下拉列,用于显示类似于Apple的私人UIProgressHUD类的进度HUD视图
 CSProgressHUD窗口遍历'initWithFrame:'构造函数赋予它的整个Frame,并捕获该区域上的所有用户输入,从而阻止用户对视图下的控件进行操作
 要允许触摸穿透HUD,可以设置hud.userInteractionEnabled = NO
 CSProgressHUD是一个UI类,因此只能在主线程上访问
 */
@interface CSProgressHUD : UIView


/**
 创建一个新的HUD,将其添加到提供的视图并显示
 此方法设置removeFromSuperViewOnHide.该HUD隐藏时自动从视图层次结构中移除
 
 @param view 对照控件
 @param animated 是否小时动画
 @return CSProgressHUD
 */
+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated;

/// @name 显示和隐藏
/**
 查找最顶尖的HUD子视图并隐藏它,这个方法的对应是showHUDAddedTo:animated:
 
 @param view 要查找的视图
 @param animated 是否动画
 @return 成功隐藏则 YES, 否则 NO
 */
+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated;

/**
 查找最顶端的HUD子视图并返回
 
 @param view 查找的 view
 @return HUD
 */
+ (nullable CSProgressHUD *)HUDForView:(UIView *)view;

/**
 一个方便的构造函数,以视图的边界初始化HUD.
 使用view.bounds作为参数调用指定的构造函数
 
 @param view 将提供HUD边界的视图实例.应该是与HUD的超级视图相同的实例(即HUD的添加视图)
 @return HUD
 */
- (instancetype)initWithView:(UIView *)view;


/**
 显示HUD
 您需要确保主线程在此方法调用后很快完成其运行循环,以便可以更新用户界面.
 当您的任务已经设置为在新线程中执行时(例如,当使用类似NSOperation或像NSURLRequest之类的异步调用)时,调用此方法
 
 @param animated 是否动画
 */
- (void)showAnimated:(BOOL)animated;


/**
 隐藏HUD.
 这仍然称为hudWasHidden:delegate.
 这是show的对应方法.
 当您的任务完成时,使用它来隐藏HUD
 
 @param animated 是否动画
 */
- (void)hideAnimated:(BOOL)animated;


/**
 延迟隐藏 HUD
 
 动画参数如果设置为YES,HUD将使用当前的animationType消失.
 如果设置为NO,HUD将不会在消失时使用动画
 @param animated  是否动画
 @param delay 延迟秒数
 */
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;


/**
 HUD委托对象.接收HUD状态通知
 */
@property (weak, nonatomic) id<CSProgressHUDDelegate> delegate;

/**
 HUD隐藏后调用代码块.
 */
@property (copy, nullable) CSProgressHUDCompletionBlock completionBlock;


/**
 宽限期是调用方法可以在不显示HUD的情况下运行的时间(以秒为单位).
 如果宽限时间耗尽之前的任务完成时,HUD将根本不会被显示
 这可以用于防止HUD显示非常短的任务,默认为0(无宽限期)
 */
@property (assign, nonatomic) NSTimeInterval graceTime;

/**
 显示HUD的最小时间(以秒为单位).
 这避免了显示HUD的问题,而不是立即隐藏.
 默认为0(无最小显示时间)
 */
@property (assign, nonatomic) NSTimeInterval minShowTime;


/**
 隐藏时,从父视图中删除HUD
 Defaults to NO
 */
@property (assign, nonatomic) BOOL removeFromSuperViewOnHide;

/// @name 出现

/**
 CSProgressHUD操作模式.
 默认值为CSProgressHUDModeIndeterminate.
 */
@property (assign, nonatomic) CSProgressHUDMode mode;

/**
 这被转发到所有的标签和支持指标的颜色.
 还可以在iOS 7+上为自定义视图设置tintColor.设置为nil以单独管理颜色.
 iOS7及更高版本默认为半透明黑色,较早版本的iOS版本为白色.
 */
@property (strong, nonatomic, nullable) UIColor *contentColor UI_APPEARANCE_SELECTOR;

/**
 显示和隐藏HUD时应使用的动画类型.
 */
@property (assign, nonatomic) CSProgressHUDAnimation animationType UI_APPEARANCE_SELECTOR;

/**
 相对于视图中心的挡板偏移.
 您可以使用CSProgressMaxOffset和-CSProgressMaxOffset将HUD一直移动到每个方向的屏幕边缘.
 例如,CGPointMake(0.f,CSProgressMaxOffset)将使位于底部边缘的HUD
 */
@property (assign, nonatomic) CGPoint offset UI_APPEARANCE_SELECTOR;

/**
 HUD边缘和HUD元素(标签,指示器或自定义视图)之间的空间量.
 这也表示到HUD视图边缘的最小边框距离.默认为20.f
 */
@property (assign, nonatomic) CGFloat margin UI_APPEARANCE_SELECTOR;

/**
 HUD挡板的最小尺寸.
 默认为CGSizeZero(无最小大小)
 */
@property (assign, nonatomic) CGSize minSize UI_APPEARANCE_SELECTOR;

/**
 如果可能,强制HUD尺寸相等.
 */
@property (assign, nonatomic, getter = isSquare) BOOL square UI_APPEARANCE_SELECTOR;

/**
 启用后,面板中心会受到设备加速度计数据的轻微影响.
 对iOS<7.0没有影响.默认为YES
 */
@property (assign, nonatomic, getter=areDefaultMotionEffectsEnabled) BOOL defaultMotionEffectsEnabled UI_APPEARANCE_SELECTOR;

/// @name 进度


/**
 进度指标的进度,从0.0到1.0.
 默认为0.0
 */
@property (assign, nonatomic) float progress;

/// @name 进度对象


/**
 NSProgress对象将进度信息提供给进度指示器
 */
@property (strong, nonatomic, nullable) NSProgress *progressObject;

/// @name Views
/**
 包含标签和指示器(或customView)的视图
 */
@property (strong, nonatomic, readonly) CSBackgroundView *bezelView;

/**
 View覆盖整个HUD区域,放在bezelView后面
 */
@property (strong, nonatomic, readonly) CSBackgroundView *backgroundView;


/**
 当HUD位于CSProgressHUDModeCustomView中时,将显示UIView(例如,UIImageView).
 该视图应实现intrinsicContentSize以进行适当的大小调整.
 为了获得最佳效果,请使用大约37x37像素
 */
@property (strong, nonatomic, nullable) UIView *customView;


/**
 要显示的活动的指标下面保持一个可选的短消息的标签.
 HUD自动调整大小以适应整个文本
 */
@property (strong, nonatomic, readonly) UILabel *label;

/**
 在labelText消息下方显示一个包含可选详细信息的标签.
 细节文字可以跨多行.
 */
@property (strong, nonatomic, readonly) UILabel *detailsLabel;

/**
 放在标签下方的按钮.
 仅当添加了目标/动作时才可见.
 */
@property (strong, nonatomic, readonly) UIButton *button;

@end









@protocol CSProgressHUDDelegate <NSObject>

@optional

/**
 在HUD完全从屏幕上隐藏后调用
 */
- (void)hudWasHidden:(CSProgressHUD *)hud;

@end









///MARK: ===================================================
///MARK: 通过填充圆圈显示确定进度的进度视图(饼图)
///MARK: ===================================================
@interface CSRoundProgressView : UIView

/**
 进度 (0.0 to 1.0)
 */
@property (nonatomic, assign) float progress;

/**
 进度指标器颜色.默认为[UIColor whiteColor]
 */
@property (nonatomic, strong) UIColor *progressTintColor;


/**
 指示器背景(无进度的)颜色
 仅适用于iOS 7以前的iOS版本
 默认为半透明白(alpha 0.1)
 */
@property (nonatomic, strong) UIColor *backgroundTintColor;


/**
 显示模式
 NO:圆形
 YES:环形
 默认:圆形
 */
@property (nonatomic, assign, getter = isAnnular) BOOL annular;

@end










///MARK: ===================================================
///MARK: 扁平风格进度器视图
///MARK: ===================================================
@interface CSBarProgressView : UIView

/**
 进度 (0.0 to 1.0)
 */
@property (nonatomic, assign) float progress;

/**
 进度指标器边框颜色.默认为[UIColor whiteColor]
 */
@property (nonatomic, strong) UIColor *lineColor;

/**
 进度指标器背景颜色.默认为[UIColor whiteColor]
 */
@property (nonatomic, strong) UIColor *progressRemainingColor;


/**
 进度指标器颜色.默认为[UIColor whiteColor]
 */
@property (nonatomic, strong) UIColor *progressColor;

@end











@interface CSBackgroundView : UIView

/**
 背景风格
 iOS7或更高版本上默认为CSProgressHUDBackgroundStyleBlur,否则为CSProgressHUDBackgroundStyleSolidColor
 由于iOS7不支持UIVisualEffectView,模糊效果在iOS7和更高版本之间略有不同
 */
@property (nonatomic) CSProgressHUDBackgroundStyle style;


/**
 背景颜色或模糊色调
 由于iOS7不支持UIVisualEffectView,模糊效果在iOS7和更高版本之间略有不同
 */
@property (nonatomic, strong) UIColor *color;

@end

NS_ASSUME_NONNULL_END













