//
//  CSProgressHUD.m
//  CSCategory
//
//  Created by mac on 2017/7/31.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSProgressHUD.h"
#import <tgmath.h>


#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.20
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1129.15
#endif

#define CSMainThreadAssert() NSAssert([NSThread isMainThread], @"需要在主线程上访问CSProgressHUD.");

CGFloat const CSProgressMaxOffset = 1000000.f;

static const CGFloat CSDefaultPadding = 4.f;
static const CGFloat CSDefaultLabelFontSize = 16.f;
static const CGFloat CSDefaultDetailsLabelFontSize = 12.f;






@interface CSProgressHUD () {
    // 弃用
    UIColor *_activityIndicatorColor;
    CGFloat _opacity;
}

@property (nonatomic, assign) BOOL useAnimation;
@property (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, strong) UIView *indicator;
@property (nonatomic, strong) NSDate *showStarted;
@property (nonatomic, strong) NSArray *paddingConstraints;
@property (nonatomic, strong) NSArray *bezelConstraints;
@property (nonatomic, strong) UIView *topSpacer;
@property (nonatomic, strong) UIView *bottomSpacer;
@property (nonatomic, weak) NSTimer *graceTimer;
@property (nonatomic, weak) NSTimer *minShowTimer;
@property (nonatomic, weak) NSTimer *hideDelayTimer;
@property (nonatomic, weak) CADisplayLink *progressObjectDisplayLink;

// 弃用
@property (assign) BOOL taskInProgress;

@end






@interface CSProgressHUDRoundedButton : UIButton
@end






@implementation CSProgressHUD

#pragma mark - Class methods

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    CSProgressHUD *hud = [[self alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    [view addSubview:hud];
    [hud showAnimated:animated];
    return hud;
}

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated {
    CSProgressHUD *hud = [self HUDForView:view];
    if (hud != nil) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:animated];
        return YES;
    }
    return NO;
}

+ (CSProgressHUD *)HUDForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (CSProgressHUD *)subview;
        }
    }
    return nil;
}

#pragma mark - Lifecycle

- (void)commonInit {
    // 设置属性的默认值
    _animationType = CSProgressHUDAnimationFade;
    _mode = CSProgressHUDModeIndeterminate;
    _margin = 20.0f;
    _opacity = 1.f;
    _defaultMotionEffectsEnabled = YES;
    
    // 默认颜色,具体取决于当前的iOS版本
    BOOL isLegacy = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0;
    _contentColor = isLegacy ? [UIColor whiteColor] : [UIColor colorWithWhite:0.f alpha:0.7f];
    // 透明背景
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    // 现在让它看不见
    self.alpha = 0.0f;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.layer.allowsGroupOpacity = NO;
    
    [self setupViews];
    [self updateIndicators];
    [self registerForNotifications];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    NSAssert(view, @"view不能为nil.");
    return [self initWithFrame:view.bounds];
}

- (void)dealloc {
    [self unregisterFromNotifications];
}

#pragma mark - Show & hide

- (void)showAnimated:(BOOL)animated {
    CSMainThreadAssert();
    [self.minShowTimer invalidate];
    self.useAnimation = animated;
    self.finished = NO;
    // 如果设置了宽限期,则推迟HUD显示
    if (self.graceTime > 0.0) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.graceTime target:self selector:@selector(handleGraceTimer:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.graceTimer = timer;
    }
    // ... 否则立即显示HUD
    else {
        [self showUsingAnimation:self.useAnimation];
    }
}

- (void)hideAnimated:(BOOL)animated {
    CSMainThreadAssert();
    [self.graceTimer invalidate];
    self.useAnimation = animated;
    self.finished = YES;
    // 如果设置了MinShow时间,则计算HUD显示的时间,并根据需要推迟隐藏操作
    if (self.minShowTime > 0.0 && self.showStarted) {
        NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:self.showStarted];
        if (interv < self.minShowTime) {
            NSTimer *timer = [NSTimer timerWithTimeInterval:(self.minShowTime - interv) target:self selector:@selector(handleMinShowTimer:) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            self.minShowTimer = timer;
            return;
        }
    }
    // ... 否则立即隐藏HUD
    [self hideUsingAnimation:self.useAnimation];
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(handleHideTimer:) userInfo:@(animated) repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.hideDelayTimer = timer;
}

#pragma mark - Timer callbacks

- (void)handleGraceTimer:(NSTimer *)theTimer {
    // 仅当任务仍在运行时显示HUD
    if (!self.hasFinished) {
        [self showUsingAnimation:self.useAnimation];
    }
}

- (void)handleMinShowTimer:(NSTimer *)theTimer {
    [self hideUsingAnimation:self.useAnimation];
}

- (void)handleHideTimer:(NSTimer *)timer {
    [self hideAnimated:[timer.userInfo boolValue]];
}

#pragma mark - View Hierrarchy

- (void)didMoveToSuperview {
    [self updateForCurrentOrientationAnimated:NO];
}

#pragma mark - Internal show & hide operations

- (void)showUsingAnimation:(BOOL)animated {
    // 取消任何以前的动画
    [self.bezelView.layer removeAllAnimations];
    [self.backgroundView.layer removeAllAnimations];
    
    // 取消任何预定的hideDelayed:通知
    [self.hideDelayTimer invalidate];
    
    self.showStarted = [NSDate date];
    self.alpha = 1.f;
    
    // 如果我们隐藏并重新显示与附加的相同的NSProgress对象,则需要它们.
    [self setNSProgressDisplayLinkEnabled:YES];
    
    if (animated) {
        [self animateIn:YES withType:self.animationType completion:NULL];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.bezelView.alpha = self.opacity;
#pragma clang diagnostic pop
        self.backgroundView.alpha = 1.f;
    }
}

- (void)hideUsingAnimation:(BOOL)animated {
    if (animated && self.showStarted) {
        self.showStarted = nil;
        [self animateIn:NO withType:self.animationType completion:^(BOOL finished) {
            [self done];
        }];
    } else {
        self.showStarted = nil;
        self.bezelView.alpha = 0.f;
        self.backgroundView.alpha = 1.f;
        [self done];
    }
}

- (CGFloat)opacity {
    return _opacity;
}

- (void)animateIn:(BOOL)animatingIn withType:(CSProgressHUDAnimation)type completion:(void(^)(BOOL finished))completion {
    // 自动确定正确的缩放动画类型
    if (type == CSProgressHUDAnimationZoom) {
        type = animatingIn ? CSProgressHUDAnimationZoomIn : CSProgressHUDAnimationZoomOut;
    }
    
    CGAffineTransform small = CGAffineTransformMakeScale(0.5f, 0.5f);
    CGAffineTransform large = CGAffineTransformMakeScale(1.5f, 1.5f);
    
    // 设置启动状态
    UIView *bezelView = self.bezelView;
    if (animatingIn && bezelView.alpha == 0.f && type == CSProgressHUDAnimationZoomIn) {
        bezelView.transform = small;
    } else if (animatingIn && bezelView.alpha == 0.f && type == CSProgressHUDAnimationZoomOut) {
        bezelView.transform = large;
    }
    
    // 执行动画
    dispatch_block_t animations = ^{
        if (animatingIn) {
            bezelView.transform = CGAffineTransformIdentity;
        } else if (!animatingIn && type == CSProgressHUDAnimationZoomIn) {
            bezelView.transform = large;
        } else if (!animatingIn && type == CSProgressHUDAnimationZoomOut) {
            bezelView.transform = small;
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        bezelView.alpha = animatingIn ? self.opacity : 0.f;
#pragma clang diagnostic pop
        self.backgroundView.alpha = animatingIn ? 1.f : 0.f;
    };
    
    // Spring animations也比较好,但只在iOS7+适用
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 || TARGET_OS_TV
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) {
        [UIView animateWithDuration:0.3 delay:0. usingSpringWithDamping:1.f initialSpringVelocity:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
        return;
    }
#endif
    [UIView animateWithDuration:0.3 delay:0. options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
}

- (void)done {
    // 取消任何预定的hideDelayed:通知
    [self.hideDelayTimer invalidate];
    [self setNSProgressDisplayLinkEnabled:NO];
    
    if (self.hasFinished) {
        self.alpha = 0.0f;
        if (self.removeFromSuperViewOnHide) {
            [self removeFromSuperview];
        }
    }
    CSProgressHUDCompletionBlock completionBlock = self.completionBlock;
    if (completionBlock) {
        completionBlock();
    }
    id<CSProgressHUDDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(hudWasHidden:)]) {
        [delegate performSelector:@selector(hudWasHidden:) withObject:self];
    }
}

#pragma mark - UI

- (void)setupViews {
    UIColor *defaultColor = self.contentColor;
    
    CSBackgroundView *backgroundView = [[CSBackgroundView alloc] initWithFrame:self.bounds];
    backgroundView.style = CSProgressHUDBackgroundStyleSolidColor;
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.alpha = 0.f;
    [self addSubview:backgroundView];
    _backgroundView = backgroundView;
    
    CSBackgroundView *bezelView = [CSBackgroundView new];
    bezelView.translatesAutoresizingMaskIntoConstraints = NO;
    bezelView.layer.cornerRadius = 5.f;
    bezelView.alpha = 0.f;
    [self addSubview:bezelView];
    _bezelView = bezelView;
    [self updateBezelMotionEffects];
    
    UILabel *label = [UILabel new];
    label.adjustsFontSizeToFitWidth = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = defaultColor;
    label.font = [UIFont boldSystemFontOfSize:CSDefaultLabelFontSize];
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    _label = label;
    
    UILabel *detailsLabel = [UILabel new];
    detailsLabel.adjustsFontSizeToFitWidth = NO;
    detailsLabel.textAlignment = NSTextAlignmentCenter;
    detailsLabel.textColor = defaultColor;
    detailsLabel.numberOfLines = 0;
    detailsLabel.font = [UIFont boldSystemFontOfSize:CSDefaultDetailsLabelFontSize];
    detailsLabel.opaque = NO;
    detailsLabel.backgroundColor = [UIColor clearColor];
    _detailsLabel = detailsLabel;
    
    UIButton *button = [CSProgressHUDRoundedButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:CSDefaultDetailsLabelFontSize];
    [button setTitleColor:defaultColor forState:UIControlStateNormal];
    _button = button;
    
    for (UIView *view in @[label, detailsLabel, button]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisHorizontal];
        [view setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        [bezelView addSubview:view];
    }
    
    UIView *topSpacer = [UIView new];
    topSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    topSpacer.hidden = YES;
    [bezelView addSubview:topSpacer];
    _topSpacer = topSpacer;
    
    UIView *bottomSpacer = [UIView new];
    bottomSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    bottomSpacer.hidden = YES;
    [bezelView addSubview:bottomSpacer];
    _bottomSpacer = bottomSpacer;
}

- (void)updateIndicators {
    UIView *indicator = self.indicator;
    BOOL isActivityIndicator = [indicator isKindOfClass:[UIActivityIndicatorView class]];
    BOOL isRoundIndicator = [indicator isKindOfClass:[CSRoundProgressView class]];
    
    CSProgressHUDMode mode = self.mode;
    if (mode == CSProgressHUDModeIndeterminate) {
        if (!isActivityIndicator) {
            // 更新到不确定的指标
            [indicator removeFromSuperview];
            indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [(UIActivityIndicatorView *)indicator startAnimating];
            [self.bezelView addSubview:indicator];
        }
    }
    else if (mode == CSProgressHUDModeDeterminateHorizontalBar) {
        // 更新到栏确定指标
        [indicator removeFromSuperview];
        indicator = [[CSBarProgressView alloc] init];
        [self.bezelView addSubview:indicator];
    }
    else if (mode == CSProgressHUDModeDeterminate || mode == CSProgressHUDModeAnnularDeterminate) {
        if (!isRoundIndicator) {
            // 更新到确定指标
            [indicator removeFromSuperview];
            indicator = [[CSRoundProgressView alloc] init];
            [self.bezelView addSubview:indicator];
        }
        if (mode == CSProgressHUDModeAnnularDeterminate) {
            [(CSRoundProgressView *)indicator setAnnular:YES];
        }
    }
    else if (mode == CSProgressHUDModeCustomView && self.customView != indicator) {
        // 更新自定义视图指标
        [indicator removeFromSuperview];
        indicator = self.customView;
        [self.bezelView addSubview:indicator];
    }
    else if (mode == CSProgressHUDModeText) {
        [indicator removeFromSuperview];
        indicator = nil;
    }
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.indicator = indicator;
    
    if ([indicator respondsToSelector:@selector(setProgress:)]) {
        [(id)indicator setValue:@(self.progress) forKey:@"progress"];
    }
    
    [indicator setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisHorizontal];
    [indicator setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
    
    [self updateViewsForColor:self.contentColor];
    [self setNeedsUpdateConstraints];
}

- (UIColor *)activityIndicatorColor {
    return _activityIndicatorColor;
}

- (void)setActivityIndicatorColor:(UIColor *)activityIndicatorColor {
    if (activityIndicatorColor != _activityIndicatorColor) {
        _activityIndicatorColor = activityIndicatorColor;
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)self.indicator;
        if ([indicator isKindOfClass:[UIActivityIndicatorView class]]) {
            [indicator setColor:activityIndicatorColor];
        }
    }
}


- (void)updateViewsForColor:(UIColor *)color {
    if (!color) return;
    
    self.label.textColor = color;
    self.detailsLabel.textColor = color;
    [self.button setTitleColor:color forState:UIControlStateNormal];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (self.activityIndicatorColor) {
        color = self.activityIndicatorColor;
    }
#pragma clang diagnostic pop
    
    // UIAppearance设置优先.如果它们是预设的,则设置的颜色将被忽略.
    
    UIView *indicator = self.indicator;
    if ([indicator isKindOfClass:[UIActivityIndicatorView class]]) {
        UIActivityIndicatorView *appearance = nil;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 90000
        appearance = [UIActivityIndicatorView appearanceWhenContainedIn:[CSProgressHUD class], nil];
#else
        // For iOS 9+
        appearance = [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[CSProgressHUD class]]];
#endif
        
        if (appearance.color == nil) {
            ((UIActivityIndicatorView *)indicator).color = color;
        }
    } else if ([indicator isKindOfClass:[CSRoundProgressView class]]) {
        CSRoundProgressView *appearance = nil;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 90000
        appearance = [CSRoundProgressView appearanceWhenContainedIn:[CSProgressHUD class], nil];
#else
        appearance = [CSRoundProgressView appearanceWhenContainedInInstancesOfClasses:@[[CSProgressHUD class]]];
#endif
        if (appearance.progressTintColor == nil) {
            ((CSRoundProgressView *)indicator).progressTintColor = color;
        }
        if (appearance.backgroundTintColor == nil) {
            ((CSRoundProgressView *)indicator).backgroundTintColor = [color colorWithAlphaComponent:0.1];
        }
    } else if ([indicator isKindOfClass:[CSBarProgressView class]]) {
        CSBarProgressView *appearance = nil;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 90000
        appearance = [CSBarProgressView appearanceWhenContainedIn:[CSProgressHUD class], nil];
#else
        appearance = [CSBarProgressView appearanceWhenContainedInInstancesOfClasses:@[[CSProgressHUD class]]];
#endif
        if (appearance.progressColor == nil) {
            ((CSBarProgressView *)indicator).progressColor = color;
        }
        if (appearance.lineColor == nil) {
            ((CSBarProgressView *)indicator).lineColor = color;
        }
    } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 || TARGET_OS_TV
        if ([indicator respondsToSelector:@selector(setTintColor:)]) {
            [indicator setTintColor:color];
        }
#endif
    }
}

- (void)updateBezelMotionEffects {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 || TARGET_OS_TV
    CSBackgroundView *bezelView = self.bezelView;
    if (![bezelView respondsToSelector:@selector(addMotionEffect:)]) return;
    
    if (self.defaultMotionEffectsEnabled) {
        CGFloat effectOffset = 10.f;
        UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        effectX.maximumRelativeValue = @(effectOffset);
        effectX.minimumRelativeValue = @(-effectOffset);
        
        UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        effectY.maximumRelativeValue = @(effectOffset);
        effectY.minimumRelativeValue = @(-effectOffset);
        
        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        group.motionEffects = @[effectX, effectY];
        
        [bezelView addMotionEffect:group];
    } else {
        NSArray *effects = [bezelView motionEffects];
        for (UIMotionEffect *effect in effects) {
            [bezelView removeMotionEffect:effect];
        }
    }
#endif
}

#pragma mark - Layout

- (void)updateConstraints {
    UIView *bezel = self.bezelView;
    UIView *topSpacer = self.topSpacer;
    UIView *bottomSpacer = self.bottomSpacer;
    CGFloat margin = self.margin;
    NSMutableArray *bezelConstraints = [NSMutableArray array];
    NSDictionary *metrics = @{@"margin": @(margin)};
    
    NSMutableArray *subviews = [NSMutableArray arrayWithObjects:self.topSpacer, self.label, self.detailsLabel, self.button, self.bottomSpacer, nil];
    if (self.indicator) [subviews insertObject:self.indicator atIndex:1];
    
    // 删除现有约束
    [self removeConstraints:self.constraints];
    [topSpacer removeConstraints:topSpacer.constraints];
    [bottomSpacer removeConstraints:bottomSpacer.constraints];
    if (self.bezelConstraints) {
        [bezel removeConstraints:self.bezelConstraints];
        self.bezelConstraints = nil;
    }
    
    // 在容器(个体自身)中心挡板,应用如果设置偏移
    CGPoint offset = self.offset;
    NSMutableArray *centeringConstraints = [NSMutableArray array];
    [centeringConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:offset.x]];
    [centeringConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:offset.y]];
    [self applyPriority:998.f toConstraints:centeringConstraints];
    [self addConstraints:centeringConstraints];
    
    // 确保保留最小边缘
    NSMutableArray *sideConstraints = [NSMutableArray array];
    [sideConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=margin)-[bezel]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bezel)]];
    [sideConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=margin)-[bezel]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bezel)]];
    [self applyPriority:999.f toConstraints:sideConstraints];
    [self addConstraints:sideConstraints];
    
    // 最小边框尺寸,如果设置
    CGSize minimumSize = self.minSize;
    if (!CGSizeEqualToSize(minimumSize, CGSizeZero)) {
        NSMutableArray *minSizeConstraints = [NSMutableArray array];
        [minSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:minimumSize.width]];
        [minSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:minimumSize.height]];
        [self applyPriority:997.f toConstraints:minSizeConstraints];
        [bezelConstraints addObjectsFromArray:minSizeConstraints];
    }
    
    // 方形长宽比,如果设置
    if (self.square) {
        NSLayoutConstraint *square = [NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeWidth multiplier:1.f constant:0];
        square.priority = 997.f;
        [bezelConstraints addObject:square];
    }
    
    // 顶部和底部间距
    [topSpacer addConstraint:[NSLayoutConstraint constraintWithItem:topSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:margin]];
    [bottomSpacer addConstraint:[NSLayoutConstraint constraintWithItem:bottomSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:margin]];
    // 顶部和底部空间应相等
    [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:topSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:bottomSpacer attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
    
    // 在边框中布置子视图
    NSMutableArray *paddingConstraints = [NSMutableArray new];
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        // 中心在边框
        [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
        // 确保保留最小边缘
        [bezelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=margin)-[view]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
        // 元素间距
        if (idx == 0) {
            // 首先,确保边框边缘的间距
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        } else if (idx == subviews.count - 1) {
            // 最后,确保边框边缘的间距
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f]];
        }
        if (idx > 0) {
            // 以前有
            NSLayoutConstraint *padding = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:subviews[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
            [bezelConstraints addObject:padding];
            [paddingConstraints addObject:padding];
        }
    }];
    
    [bezel addConstraints:bezelConstraints];
    self.bezelConstraints = bezelConstraints;
    
    self.paddingConstraints = [paddingConstraints copy];
    [self updatePaddingConstraints];
    
    [super updateConstraints];
}

- (void)layoutSubviews {
    /**
     如果要在[super layoutSubviews]中重新创建限制,则由于需要设置UpdateConstraints,因此无需更新约束.
     这也避免了iOS8上的问题,其中updatePaddingConstraints会触发僵尸对象访问.
     */
    if (!self.needsUpdateConstraints) {
        [self updatePaddingConstraints];
    }
    [super layoutSubviews];
}

- (void)updatePaddingConstraints {
    // 根据视图是否可见,动态设置填充
    __block BOOL hasVisibleAncestors = NO;
    [self.paddingConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *padding, NSUInteger idx, BOOL *stop) {
        UIView *firstView = (UIView *)padding.firstItem;
        UIView *secondView = (UIView *)padding.secondItem;
        BOOL firstVisible = !firstView.hidden && !CGSizeEqualToSize(firstView.intrinsicContentSize, CGSizeZero);
        BOOL secondVisible = !secondView.hidden && !CGSizeEqualToSize(secondView.intrinsicContentSize, CGSizeZero);
        //设置两个视图是否可见,或者如果顶部有可见的视图,但没有相对于当前视图添加填充
        padding.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? CSDefaultPadding : 0.f;
        hasVisibleAncestors |= secondVisible;
    }];
}

- (void)applyPriority:(UILayoutPriority)priority toConstraints:(NSArray *)constraints {
    for (NSLayoutConstraint *constraint in constraints) {
        constraint.priority = priority;
    }
}

#pragma mark - Properties

- (void)setMode:(CSProgressHUDMode)mode {
    if (mode != _mode) {
        _mode = mode;
        [self updateIndicators];
    }
}

- (void)setCustomView:(UIView *)customView {
    if (customView != _customView) {
        _customView = customView;
        if (self.mode == CSProgressHUDModeCustomView) {
            [self updateIndicators];
        }
    }
}

- (void)setOffset:(CGPoint)offset {
    if (!CGPointEqualToPoint(offset, _offset)) {
        _offset = offset;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setMargin:(CGFloat)margin {
    if (margin != _margin) {
        _margin = margin;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setMinSize:(CGSize)minSize {
    if (!CGSizeEqualToSize(minSize, _minSize)) {
        _minSize = minSize;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setSquare:(BOOL)square {
    if (square != _square) {
        _square = square;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setProgressObjectDisplayLink:(CADisplayLink *)progressObjectDisplayLink {
    if (progressObjectDisplayLink != _progressObjectDisplayLink) {
        [_progressObjectDisplayLink invalidate];
        
        _progressObjectDisplayLink = progressObjectDisplayLink;
        
        [_progressObjectDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)setProgressObject:(NSProgress *)progressObject {
    if (progressObject != _progressObject) {
        _progressObject = progressObject;
        [self setNSProgressDisplayLinkEnabled:YES];
    }
}

- (void)setProgress:(float)progress {
    if (progress != _progress) {
        _progress = progress;
        UIView *indicator = self.indicator;
        if ([indicator respondsToSelector:@selector(setProgress:)]) {
            [(id)indicator setValue:@(self.progress) forKey:@"progress"];
        }
    }
}

- (void)setContentColor:(UIColor *)contentColor {
    if (contentColor != _contentColor && ![contentColor isEqual:_contentColor]) {
        _contentColor = contentColor;
        [self updateViewsForColor:contentColor];
    }
}

- (void)setDefaultMotionEffectsEnabled:(BOOL)defaultMotionEffectsEnabled {
    if (defaultMotionEffectsEnabled != _defaultMotionEffectsEnabled) {
        _defaultMotionEffectsEnabled = defaultMotionEffectsEnabled;
        [self updateBezelMotionEffects];
    }
}

#pragma mark - NSProgress

- (void)setNSProgressDisplayLinkEnabled:(BOOL)enabled {
    //我们正在使用CADisplayLink,因为NSProgress可以很快地改变,观察它可能会使主线程变得饿死,所以我们只是在每帧画面上刷新进度
    if (enabled && self.progressObject) {
        // 仅在尚未激活的情况下创建.
        if (!self.progressObjectDisplayLink) {
            self.progressObjectDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgressFromProgressObject)];
        }
    } else {
        self.progressObjectDisplayLink = nil;
    }
}

- (void)updateProgressFromProgressObject {
    self.progress = self.progressObject.fractionCompleted;
}

#pragma mark - Notifications

- (void)registerForNotifications {
#if !TARGET_OS_TV
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(statusBarOrientationDidChange:)
               name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
#endif
}

- (void)unregisterFromNotifications {
#if !TARGET_OS_TV
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
#endif
}

#if !TARGET_OS_TV
- (void)statusBarOrientationDidChange:(NSNotification *)notification {
    UIView *superview = self.superview;
    if (!superview) {
        return;
    } else {
        [self updateForCurrentOrientationAnimated:YES];
    }
}
#endif

- (void)updateForCurrentOrientationAnimated:(BOOL)animated {
    // 在任何情况下与superview保持同步
    if (self.superview) {
        self.bounds = self.superview.bounds;
    }
    
    // 在iOS8+上不需要,在部署目标允许时编译出来,以避免扩展目标上的sharedApplication问题
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    // 添加到窗口时,需要iOS 8之前的版本
    BOOL iOS8OrLater = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0;
    if (iOS8OrLater || ![self.superview isKindOfClass:[UIWindow class]]) return;
    
    // 使扩展友好.
    // 由于上述检查,将不会在扩展程序(iOS8+)上调用.
    // 这只是确保我们没有收到关于extension-unsafe API的警告.
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if (!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) return;
    
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    UIInterfaceOrientation orientation = application.statusBarOrientation;
    CGFloat radians = 0;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        radians = orientation == UIInterfaceOrientationLandscapeLeft ? -(CGFloat)M_PI_2 : (CGFloat)M_PI_2;
        // 窗口坐标不同!
        self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        radians = orientation == UIInterfaceOrientationPortraitUpsideDown ? (CGFloat)M_PI : 0.f;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformMakeRotation(radians);
        }];
    } else {
        self.transform = CGAffineTransformMakeRotation(radians);
    }
#endif
}

@end











@implementation CSRoundProgressView

#pragma mark - Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _progress = 0.f;
        _annular = NO;
        _progressTintColor = [[UIColor alloc] initWithWhite:1.f alpha:1.f];
        _backgroundTintColor = [[UIColor alloc] initWithWhite:1.f alpha:.1f];
    }
    return self;
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    return CGSizeMake(37.f, 37.f);
}

#pragma mark - Properties

- (void)setProgress:(float)progress {
    if (progress != _progress) {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    NSAssert(progressTintColor, @"颜色不应该是nil.");
    if (progressTintColor != _progressTintColor && ![progressTintColor isEqual:_progressTintColor]) {
        _progressTintColor = progressTintColor;
        [self setNeedsDisplay];
    }
}

- (void)setBackgroundTintColor:(UIColor *)backgroundTintColor {
    NSAssert(backgroundTintColor, @"颜色不应该是nil.");
    if (backgroundTintColor != _backgroundTintColor && ![backgroundTintColor isEqual:_backgroundTintColor]) {
        _backgroundTintColor = backgroundTintColor;
        [self setNeedsDisplay];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    BOOL isPreiOS7 = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0;
    
    if (_annular) {
        // 画背景
        CGFloat lineWidth = isPreiOS7 ? 5.f : 2.f;
        UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
        processBackgroundPath.lineWidth = lineWidth;
        processBackgroundPath.lineCapStyle = kCGLineCapButt;
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        CGFloat radius = (self.bounds.size.width - lineWidth)/2;
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (2 * (float)M_PI) + startAngle;
        [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_backgroundTintColor set];
        [processBackgroundPath stroke];
        // 绘制进度
        UIBezierPath *processPath = [UIBezierPath bezierPath];
        processPath.lineCapStyle = isPreiOS7 ? kCGLineCapRound : kCGLineCapSquare;
        processPath.lineWidth = lineWidth;
        endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_progressTintColor set];
        [processPath stroke];
    } else {
        // 画背景
        CGFloat lineWidth = 2.f;
        CGRect allRect = self.bounds;
        CGRect circleRect = CGRectInset(allRect, lineWidth/2.f, lineWidth/2.f);
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [_progressTintColor setStroke];
        [_backgroundTintColor setFill];
        CGContextSetLineWidth(context, lineWidth);
        if (isPreiOS7) {
            CGContextFillEllipseInRect(context, circleRect);
        }
        CGContextStrokeEllipseInRect(context, circleRect);
        // 90度
        CGFloat startAngle = - ((float)M_PI / 2.f);
        // 绘制进度
        if (isPreiOS7) {
            CGFloat radius = (CGRectGetWidth(self.bounds) / 2.f) - lineWidth;
            CGFloat endAngle = (self.progress * 2.f * (float)M_PI) + startAngle;
            [_progressTintColor setFill];
            CGContextMoveToPoint(context, center.x, center.y);
            CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
            CGContextClosePath(context);
            CGContextFillPath(context);
        } else {
            UIBezierPath *processPath = [UIBezierPath bezierPath];
            processPath.lineCapStyle = kCGLineCapButt;
            processPath.lineWidth = lineWidth * 2.f;
            CGFloat radius = (CGRectGetWidth(self.bounds) / 2.f) - (processPath.lineWidth / 2.f);
            CGFloat endAngle = (self.progress * 2.f * (float)M_PI) + startAngle;
            [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
            // 确保当 _progress TintColor alpha < 1.f时,我们不会得到颜色重叠.
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            [_progressTintColor set];
            [processPath stroke];
        }
    }
}

@end


@implementation CSBarProgressView

#pragma mark - Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(.0f, .0f, 120.0f, 20.0f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _progress = 0.f;
        _lineColor = [UIColor whiteColor];
        _progressColor = [UIColor whiteColor];
        _progressRemainingColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    BOOL isPreiOS7 = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0;
    return CGSizeMake(120.f, isPreiOS7 ? 20.f : 10.f);
}

#pragma mark - Properties

- (void)setProgress:(float)progress {
    if (progress != _progress) {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

- (void)setProgressColor:(UIColor *)progressColor {
    NSAssert(progressColor, @"颜色不应该是 nil.");
    if (progressColor != _progressColor && ![progressColor isEqual:_progressColor]) {
        _progressColor = progressColor;
        [self setNeedsDisplay];
    }
}

- (void)setProgressRemainingColor:(UIColor *)progressRemainingColor {
    NSAssert(progressRemainingColor, @"颜色不应该是 nil.");
    if (progressRemainingColor != _progressRemainingColor && ![progressRemainingColor isEqual:_progressRemainingColor]) {
        _progressRemainingColor = progressRemainingColor;
        [self setNeedsDisplay];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context,[_lineColor CGColor]);
    CGContextSetFillColorWithColor(context, [_progressRemainingColor CGColor]);
    
    // Draw background
    CGFloat radius = (rect.size.height / 2) - 2;
    CGContextMoveToPoint(context, 2, rect.size.height/2);
    CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
    CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
    CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width - 2, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2, rect.size.width - radius - 2, rect.size.height - 2, radius);
    CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);
    CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2, rect.size.height/2, radius);
    CGContextFillPath(context);
    
    // Draw border
    CGContextMoveToPoint(context, 2, rect.size.height/2);
    CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
    CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
    CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width - 2, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2, rect.size.width - radius - 2, rect.size.height - 2, radius);
    CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);
    CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2, rect.size.height/2, radius);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, [_progressColor CGColor]);
    radius = radius - 2;
    CGFloat amount = self.progress * rect.size.width;
    
    // Progress in the middle area
    if (amount >= radius + 4 && amount <= (rect.size.width - radius - 4)) {
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, amount, 4);
        CGContextAddLineToPoint(context, amount, radius + 4);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, amount, rect.size.height - 4);
        CGContextAddLineToPoint(context, amount, radius + 4);
        
        CGContextFillPath(context);
    }
    
    // Progress in the right arc
    else if (amount > radius + 4) {
        CGFloat x = amount - (rect.size.width - radius - 4);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - 4, 4);
        CGFloat angle = -acos(x/radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(context, rect.size.width - radius - 4, rect.size.height/2, radius, M_PI, angle, 0);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - 4, rect.size.height - 4);
        angle = acos(x/radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(context, rect.size.width - radius - 4, rect.size.height/2, radius, -M_PI, angle, 1);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);
        
        CGContextFillPath(context);
    }
    
    // Progress is in the left arc
    else if (amount < radius + 4 && amount > 0) {
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);
        
        CGContextFillPath(context);
    }
}

@end


@interface CSBackgroundView ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 || TARGET_OS_TV
@property UIVisualEffectView *effectView;
#endif
#if !TARGET_OS_TV
@property UIToolbar *toolbar;
#endif

@end


@implementation CSBackgroundView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) {
            _style = CSProgressHUDBackgroundStyleBlur;
            if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
                _color = [UIColor colorWithWhite:0.8f alpha:0.6f];
            } else {
                _color = [UIColor colorWithWhite:0.95f alpha:0.6f];
            }
        } else {
            _style = CSProgressHUDBackgroundStyleSolidColor;
            _color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        }
        
        self.clipsToBounds = YES;
        
        [self updateForBackgroundStyle];
    }
    return self;
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    // 最小尺寸可能.内容推动这一点.
    return CGSizeZero;
}

#pragma mark - Appearance

- (void)setStyle:(CSProgressHUDBackgroundStyle)style {
    if (style == CSProgressHUDBackgroundStyleBlur && kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0) {
        style = CSProgressHUDBackgroundStyleSolidColor;
    }
    if (_style != style) {
        _style = style;
        [self updateForBackgroundStyle];
    }
}

- (void)setColor:(UIColor *)color {
    NSAssert(color, @"颜色不应该是 nil.");
    if (color != _color && ![color isEqual:_color]) {
        _color = color;
        [self updateViewsForColor:color];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Views

- (void)updateForBackgroundStyle {
    CSProgressHUDBackgroundStyle style = self.style;
    if (style == CSProgressHUDBackgroundStyleBlur) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 || TARGET_OS_TV
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
            [self addSubview:effectView];
            effectView.frame = self.bounds;
            effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            self.backgroundColor = self.color;
            self.layer.allowsGroupOpacity = NO;
            self.effectView = effectView;
        } else {
#endif
#if !TARGET_OS_TV
            UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectInset(self.bounds, -100.f, -100.f)];
            toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            toolbar.barTintColor = self.color;
            toolbar.translucent = YES;
            [self addSubview:toolbar];
            self.toolbar = toolbar;
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 || TARGET_OS_TV
        }
#endif
    } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 || TARGET_OS_TV
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            [self.effectView removeFromSuperview];
            self.effectView = nil;
        } else {
#endif
#if !TARGET_OS_TV
            [self.toolbar removeFromSuperview];
            self.toolbar = nil;
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 || TARGET_OS_TV
        }
#endif
        self.backgroundColor = self.color;
    }
}

- (void)updateViewsForColor:(UIColor *)color {
    if (self.style == CSProgressHUDBackgroundStyleBlur) {
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            self.backgroundColor = self.color;
        } else {
#if !TARGET_OS_TV
            self.toolbar.barTintColor = color;
#endif
        }
    } else {
        self.backgroundColor = self.color;
    }
}

@end









@implementation CSProgressHUDRoundedButton

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CALayer *layer = self.layer;
        layer.borderWidth = 1.f;
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    // 全圆角
    CGFloat height = CGRectGetHeight(self.bounds);
    self.layer.cornerRadius = ceil(height / 2.f);
}

- (CGSize)intrinsicContentSize {
    // 只有当我们有关联的控制事件时才显示
    if (self.allControlEvents == 0) return CGSizeZero;
    CGSize size = [super intrinsicContentSize];
    // 添加一些边填充
    size.width += 20.f;
    return size;
}

#pragma mark - Color

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [super setTitleColor:color forState:state];
    // 更新相关颜色
    [self setHighlighted:self.highlighted];
    self.layer.borderColor = color.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    UIColor *baseColor = [self titleColorForState:UIControlStateSelected];
    self.backgroundColor = highlighted ? [baseColor colorWithAlphaComponent:0.1f] : [UIColor clearColor];
}

@end









