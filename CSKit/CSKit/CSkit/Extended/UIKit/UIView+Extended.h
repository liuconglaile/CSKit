//
//  UIView+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Layout.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, CSDirectionCorner) {
    CSDirectionCornerLeft        = 1 << 0,
    CSDirectionCornerRight       = 1 << 1,
    CSDirectionCornerTop         = 1 << 2,
    CSDirectionCornerBottom      = 1 << 3,
    CSDirectionCornerAllCorners  = ~0UL
};

typedef NS_OPTIONS(NSUInteger, CSExcludePoint) {
    CSExcludePointStart = 1 << 0,
    CSExcludePointEnd = 1 << 1,
    CSExcludePointAll = ~0UL
};


//一个像素的实际大小
#define CSSizeFromPixel(value) value/[UIScreen mainScreen].scale
float radiansForDegrees(int degrees);
typedef void (^CSGestureActionBlock)(UIGestureRecognizer *gestureRecoginzer);
typedef void (^CSSubviewBlock) (UIView* view);
typedef void (^CSSuperviewBlock) (UIView* superview);

@interface UIView (Extended)

/** 返回视图的视图控制器(可能为 nil). */
@property (nullable, nonatomic, readonly) UIViewController *viewController;
/** 返回屏幕上的可见alpha,考虑到父视图和窗口 */
@property (nonatomic, readonly) CGFloat visibleAlpha;

/** 创建完整视图层次结构的快照映像 */
- (nullable UIImage *)snapshotImage;
/** 创建完整视图层次结构的快照映像 */
- (nullable UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;
/** 创建完整视图层次结构的快照PDF */
- (nullable NSData *)snapshotPDF;
/** 快捷方式设置view.layer 阴影 */
- (void)setLayerShadow:(nullable UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;
/** 删除所有子视图 */
- (void)removeAllSubviews;




///MARK: ===================================================
///MARK: 渲染相关
///MARK: ===================================================

@property(nonatomic,strong) IBInspectable NSString *bgColor;
@property(nonatomic,assign) IBInspectable CGFloat borderWidth;
@property(nonatomic,strong) IBInspectable UIColor *borderColor;
@property(nonatomic,assign) IBInspectable CGFloat cornerRadius;
@property(nonatomic,assign) IBInspectable CGFloat blurRadius;

/** 设置某几个角的圆角 */
- (void)roundingCorners:(UIRectCorner)corners cornerRadius:(CGFloat)cornerRadius;
/** 设置圆角&边框&边框颜色 */
- (void)cornerRadius:(CGFloat)radius strokeSize:(CGFloat)size color:(UIColor *)color;
/** 根据图层路径设置圆角 */
-(void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius;
/** 快速设置阴影 颜色&偏移&透明度&半径 */
-(void)shadowWithColor:(UIColor *)color offset:(CGSize)offset opacity:(CGFloat)opacity radius:(CGFloat)radius;

/** CAGradientLayer 方式添加内阴影 */
- (void)makeInsetShadow;
- (void)makeInsetShadowWithRadius:(float)radius Alpha:(float)alpha;
- (void)makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(CSDirectionCorner)directions;


// 添加顶部边框颜色用 &宽度
- (void)addTopBorderWithColor:(UIColor *)color width:(CGFloat) borderWidth;
- (void)addLeftBorderWithColor: (UIColor *) color width:(CGFloat) borderWidth;
- (void)addBottomBorderWithColor:(UIColor *)color width:(CGFloat) borderWidth;
- (void)addRightBorderWithColor:(UIColor *)color width:(CGFloat) borderWidth;
// 删除边框
- (void)removeTopBorder;
- (void)removeLeftBorder;
- (void)removeBottomBorder;
- (void)removeRightBorder;

// 根据颜色&起点&模式 添加边框颜色
- (void)addTopBorderWithColor:(UIColor *)color width:(CGFloat) borderWidth excludePoint:(CGFloat)point edgeType:(CSExcludePoint)edge;
- (void)addLeftBorderWithColor: (UIColor *) color width:(CGFloat) borderWidth excludePoint:(CGFloat)point edgeType:(CSExcludePoint)edge;
- (void)addBottomBorderWithColor:(UIColor *)color width:(CGFloat) borderWidth excludePoint:(CGFloat)point edgeType:(CSExcludePoint)edge;
- (void)addRightBorderWithColor:(UIColor *)color width:(CGFloat) borderWidth excludePoint:(CGFloat)point edgeType:(CSExcludePoint)edge;


/**
 增加一个像素的线
 */
- (CAGradientLayer *)addPixLineToBottom;
- (CAGradientLayer *)addPixLineToCenter;
- (CAGradientLayer *)addPixLineWithRect:(CGRect)rect;
- (CAGradientLayer *)addPixLineWithRect:(CGRect)rect lineColor:(nullable UIColor *)color;


///MARK: ===================================================
///MARK: 渲染相关 end
///MARK: ===================================================








///MARK: ===================================================
///MARK: Animation相关
///MARK: ===================================================


/** 改手势负责处理视图的拖拽 */
@property (nonatomic) UIPanGestureRecognizer *panGesture;
/** 这个 frame 是代表视图的可拖拽范围. (属性设置为 CGRectZero 拖拽效果将不执行) */
@property (nonatomic) CGRect cagingArea;
/** 设置视图拖拽开始生效的 frame. 默认为 self.view的 frame. */
@property (nonatomic) CGRect handle;
/** 制约沿X轴的移动 */
@property (nonatomic) BOOL shouldMoveAlongX;
/** 制约沿Y轴的移动 */
@property (nonatomic) BOOL shouldMoveAlongY;
/** 拖拽开始时候的回调 */
@property (nonatomic, copy) void (^draggingStartedBlock)(void);
/** 拖拽结束时候的回调 */
@property (nonatomic, copy) void (^draggingEndedBlock)(void);
/** 启用拖动 */
- (void)enableDragging;
/** 禁用或启用视图拖动 */
- (void)setDraggable:(BOOL)draggable;





// 移动
- (void)moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option;
- (void)moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option delegate:(nullable id)delegate callback:(nullable SEL)method;
- (void)raceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapBack;
- (void)raceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapBack delegate:(nullable id)delegate callback:(nullable SEL)method;

// 变换Transforms
- (void)rotate:(int)degrees secs:(float)secs delegate:(id)delegate callback:(SEL)method;
- (void)scale:(float)secs x:(float)scaleX y:(float)scaleY delegate:(id)delegate callback:(SEL)method;
- (void)spinClockwise:(float)secs;
- (void)spinCounterClockwise:(float)secs;

// 过渡
- (void)curlDown:(float)secs;
- (void)curlUpAndAway:(float)secs;
- (void)drainAway:(float)secs;

// 特效Effects
- (void)changeAlpha:(float)newAlpha secs:(float)secs;
- (void)pulse:(float)secs continuously:(BOOL)continuously;

//添加子视图特效
- (void)addSubviewWithFadeAnimation:(UIView *)subview;



/** 以淡入淡出形式从父视图中 remove */
-(void)removeFromSuperviewWithFadeDuration:(NSTimeInterval)duration;

/** 根据过渡效果添加子视图 */
-(void)addSubview:(UIView *)view withTransition:(UIViewAnimationTransition)transition duration:(NSTimeInterval)duration;

/** 根据过渡效果释放子视图 */
-(void)removeFromSuperviewWithTransition: (UIViewAnimationTransition)transition duration:(NSTimeInterval)duration;

/** 旋转视图按给定的角度。定时功能可以为空，默认为 kCAMediaTimingFunctionEaseInEaseOut */
-(void)rotateByAngle:(CGFloat)angle
            duration:(NSTimeInterval)duration
         autoreverse:(BOOL)autoreverse
         repeatCount:(CGFloat)repeatCount
      timingFunction:(CAMediaTimingFunction *)timingFunction;

/** 移动视图,以点,定时功能可以为空，默认为kCAMediaTimingFunctionEaseInEaseOut. */
- (void)moveToPoint:(CGPoint)newPoint
           duration:(NSTimeInterval)duration
        autoreverse:(BOOL)autoreverse
        repeatCount:(CGFloat)repeatCount
     timingFunction:(CAMediaTimingFunction *)timingFunction;


///MARK: ===================================================
///MARK: Animation相关 end
///MARK: ===================================================








///MARK: ===================================================
///MARK: 其他相关
///MARK: ===================================================

/** 添加tap手势 */
- (void)addTapActionWithBlock:(CSGestureActionBlock)block;
/** 添加长按手势 */
- (void)addLongPressActionWithBlock:(CSGestureActionBlock)block;

/** 递归查找子视图 */
- (UIView*)findViewRecursively:(BOOL(^)(UIView* subview, BOOL* stop))recurse;

/** 遍历返回所有的子(父)视图 */
- (void)runBlockOnAllSubviews:(CSSubviewBlock)block;
- (void)runBlockOnAllSuperviews:(CSSuperviewBlock)block;

/** 找到指定类名的SubVie对象 */
- (id)findSubViewWithSubViewClass:(Class)clazz;
/** 找到指定类名的SuperView对象 */
- (id)findSuperViewWithSuperViewClass:(Class)clazz;
/** 找到并且resign第一响应者 */
- (BOOL)findAndResignFirstResponder;
/** 找到第一响应者 */
- (UIView *)findFirstResponder;



/** 开启或禁用 层次结构控件的Enabled */
- (void)enableAllControlsInViewHierarchy;
- (void)disableAllControlsInViewHierarchy;


/** view截图 */
- (UIImage *)screenshot;
/** 截图一个view中所有视图 包括旋转缩放效果 */
- (UIImage *)screenshot:(CGFloat)maxWidth;




+ (UINib *)loadNib;
+ (UINib *)loadNibNamed:(NSString*)nibName;
+ (UINib *)loadNibNamed:(NSString*)nibName bundle:(NSBundle *)bundle;

+ (instancetype)loadInstanceFromNib;
+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName;
+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName owner:(nullable id)owner;
+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName owner:(nullable id)owner bundle:(NSBundle *)bundle;


///MARK: ===================================================
///MARK: 其他相关
///MARK: ===================================================


///MARK: ===================================================
///MARK: Toast相关
///MARK: ===================================================

//MARK: 每个makeToast方法创建一个视图，并显示为toast
- (void)showToast:(NSString *)message;
- (void)showToast:(NSString *)message duration:(NSTimeInterval)interval position:(nullable id)position;
- (void)showToast:(NSString *)message duration:(NSTimeInterval)interval position:(nullable id)position image:(UIImage *)image;
- (void)showToast:(NSString *)message duration:(NSTimeInterval)interval position:(nullable id)position title:(NSString *)title;
- (void)showToast:(NSString *)message duration:(NSTimeInterval)interval position:(nullable id)position title:(NSString *)title image:(UIImage *)image;



// displays toast with an activity spinner
- (void)showToastActivity;
- (void)showToastActivity:(id)position;
- (void)hideToastActivity;

//MARK: 展示自定义 View
- (void)showToastView:(UIView *)toast;
- (void)showToastView:(UIView *)toast duration:(NSTimeInterval)interval position:(nullable id)point;
- (void)showToastView:(UIView *)toast duration:(NSTimeInterval)interval position:(nullable id)point
          tapCallback:(nullable void(^)(void))tapCallback;

///MARK: ===================================================
///MARK: Toast相关
///MARK: ===================================================


@end

NS_ASSUME_NONNULL_END
