//
//  CSPopupController.m
//  CSCategory
//
//  Created by mac on 2017/6/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSPopupController.h"
#import <objc/runtime.h>
#import "CSKitMacro.h"

/**
 随机值
 
 @param i <#i description#>
 @param j <#j description#>
 @return <#return value description#>
 */
UIKIT_STATIC_INLINE int randomValues(int i, int j) {
    if (arc4random() % 2) return i;
    return j;
}

static void *PopupControllerParametersKey = &PopupControllerParametersKey;
@interface CSPopupController()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *superview;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *popupView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation CSPopupController

+(instancetype)popupControllerWithLayoutType:(CSPopupLayoutType)layoutType
                                    maskType:(CSPopupMaskType)maskType
                        dismissOnMaskTouched:(BOOL)dismissOnMaskTouched
                                    allowPan:(BOOL)allowPan {
    
    CSPopupController *popupController = [[CSPopupController alloc] init];
    popupController.maskType = maskType;
    popupController.layoutType = layoutType;
    popupController.dismissOnMaskTouched = dismissOnMaskTouched;
    popupController.allowPan = allowPan;
    return popupController;
}

+ (instancetype)popupControllerLayoutInCenterWithTransitStyle:(CSPopupTransitStyle)transitStyle
                                                     maskType:(CSPopupMaskType)maskType
                                         dismissOnMaskTouched:(BOOL)dismissOnMaskTouched
                                     dismissOppositeDirection:(BOOL)dismissOppositeDirection
                                                     allowPan:(BOOL)allowPan {
    
    CSPopupController *popupController = [[CSPopupController alloc] init];
    popupController.maskType = maskType;
    popupController.layoutType = CSPopupLayoutTypeCenter;
    popupController.transitStyle = transitStyle;
    popupController.dismissOnMaskTouched = dismissOnMaskTouched;
    popupController.dismissOppositeDirection = dismissOppositeDirection;
    popupController.allowPan = allowPan;
    return popupController;
}

- (instancetype)init {
    self = [super init];
    if (!self)  return nil;
    
    //  default value
    _maskType                 = CSPopupMaskTypeDefault;
    _layoutType               = CSPopupLayoutTypeCenter;
    _transitStyle             = CSPopupTransitStyleDefault;
    _maskAlpha                = 0.55;
    _dismissOnMaskTouched     = YES;
    _dismissOppositeDirection = NO;
    _dropTransitionAnimated   = NO;
    _allowPan                 = NO;
    _isPresenting             = NO;
    
    // superview
    _superview = [self keyWindow];
    
    // popupView
    _popupView = [[UIView alloc] init];
    _popupView.backgroundColor = [UIColor clearColor];
    
    // maskView
    _maskView = [[UIView alloc] initWithFrame:_superview.bounds];
    self.maskType = _maskType;
    [_maskView addGestureRecognizer:[self tap]];
    
    // Observer statusBar orientation changes.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willChangeStatusBarOrientation)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeStatusBarOrientation)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    return self;
}

- (UIWindow *)keyWindow {
    return [UIApplication sharedApplication].keyWindow;
}

- (UIView *)maskViewType:(CSPopupMaskType)maskType {
    switch (maskType) {
        case CSPopupMaskTypeDefault:
            _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_maskAlpha];
            break;
        case CSPopupMaskTypeWhite:
            _maskView.backgroundColor = [UIColor whiteColor];
            break;
        case CSPopupMaskTypeClear:
            _maskView.backgroundColor = [UIColor clearColor];
            break;
        case CSPopupMaskTypeBlackBlur:
            _maskView = [self maskBlurStyle:UIBarStyleBlackTranslucent];
            break;
        case CSPopupMaskTypeWhiteBlur:
            _maskView = [self maskBlurStyle:UIBarStyleDefault];
            break;
        default: break;
    }
    return _maskView;
}

- (UIView *)maskBlurStyle:(UIBarStyle)barStyle {
    UIToolbar *mask = [[UIToolbar alloc] initWithFrame:_superview.bounds];
    mask.barStyle = barStyle;
    [mask addGestureRecognizer:[self tap]];
    return mask;
}

- (UITapGestureRecognizer *)tap {
    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    g.delegate = self;
    return g;
}

#pragma mark - Setter

- (void)setAllowPan:(BOOL)allowPan {
    _allowPan = allowPan;
    if (_allowPan) {
        UIPanGestureRecognizer *g = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_popupView addGestureRecognizer:g];
    }
}

- (void)setMaskType:(CSPopupMaskType)maskType {
    _maskType = maskType;
    _maskView = [self maskViewType:_maskType];
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    _maskAlpha = maskAlpha;
    _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_maskAlpha];
}

- (void)setContentView:(UIView *)contentView {
    _contentView = contentView;
    if (nil == _contentView) {
        if (nil != _popupView.superview) {
            [_popupView removeFromSuperview];
        }
        return;
    }
    if (_contentView.superview != _popupView) {
        _contentView.frame = (CGRect){.origin = CGPointZero, .size = contentView.frame.size};
        _popupView.frame = _contentView.frame;
        _popupView.backgroundColor = _contentView.backgroundColor;
        if (_contentView.layer.cornerRadius > 0) {
            _popupView.layer.cornerRadius = _contentView.layer.cornerRadius;
            _popupView.clipsToBounds = NO;
        }
        [_popupView addSubview:_contentView];
        [_maskView addSubview:_popupView];
    }
}

- (void)addSubviews {
    [_superview addSubview:_maskView];
}

- (void)removeSubviews {
    if (_popupView.subviews.count > 0) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    [_maskView removeFromSuperview];
}

- (void)message { // cue words
    if (_layoutType != CSPopupLayoutTypeCenter) {
        if (_transitStyle != CSPopupTransitStyleDefault) {
            CSNSLog(@"\n ◎ Set 'transitStyle' is invalid. when 'layoutType' is not 'CSPopupLayoutTypeCenter'.");
        }
        if (_dismissOppositeDirection) {
            CSNSLog(@"\n ◎ Set 'isDismissOppositeDirection' is invalid. when 'layoutType' is not 'CSPopupLayoutTypeCenter'.");
        }
    }
}

#pragma mark - Present

- (void)presentContentView:(UIView *)contentView
                  duration:(NSTimeInterval)duration
           elasticAnimated:(BOOL)isElasticAnimated
                    inView:(UIView *)sView {
    
    if (self.isPresenting) return;
    
    if (nil != self.willPresent) {
        self.willPresent(self);
    } else {
        if ([self.delegate respondsToSelector:@selector(popupControllerWillPresent:)]) {
            [self.delegate popupControllerWillPresent:self];
        }
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setValue:@(duration) forKey:@"duration"];
    [parameters setValue:@(isElasticAnimated) forKey:@"isElasticAnimated"];
    objc_setAssociatedObject(self, PopupControllerParametersKey, parameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self message];
    
    if (nil != sView) {
        _superview = sView;
        _maskView.frame = _superview.frame;
    }
    
    [self setContentView:contentView];
    [self addSubviews];
    [self dropAnimatedInitial];
    [self maskAlphaInitial];
    _popupView.userInteractionEnabled = NO;
    _popupView.center = [self initialCenterPoint];
    
    if (isElasticAnimated) {
        
        [UIView animateWithDuration:duration
                              delay:0.0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.2
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             [self dropAnimatedFinished];
                             [self maskAlphaFinished];
                             _popupView.center = [self finishedCenterPoint];
                             
                         } completion:^(BOOL finished) {
                             
                             if (!finished) return;
                             _popupView.userInteractionEnabled = YES;
                             _isPresenting = YES;
                             if (nil != self.didPresent) {
                                 self.didPresent(self);
                             } else {
                                 if ([self.delegate respondsToSelector:@selector(popupControllerDidPresent:)]) {
                                     [self.delegate popupControllerDidPresent:self];
                                 }
                             }
                         }];
    } else {
        
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             [self dropAnimatedFinished];
                             [self maskAlphaFinished];
                             _popupView.center = [self finishedCenterPoint];
                             
                         } completion:^(BOOL finished) {
                             
                             if (!finished) return;
                             _popupView.userInteractionEnabled = YES;
                             _isPresenting = YES;
                             if (nil != self.didPresent) {
                                 self.didPresent(self);
                             } else {
                                 if ([self.delegate respondsToSelector:@selector(popupControllerDidPresent:)]) {
                                     [self.delegate popupControllerDidPresent:self];
                                 }
                             }
                         }];
    }
}

- (void)presentContentView:(UIView *)contentView duration:(NSTimeInterval)duration elasticAnimated:(BOOL)isElasticAnimated {
    [self presentContentView:contentView duration:duration elasticAnimated:isElasticAnimated inView:nil];
}

- (void)presentContentView:(UIView *)contentView {
    [self presentContentView:contentView duration:0.25 elasticAnimated:NO inView:nil];
}

#pragma mark - Dismiss

- (void)dismissWithDuration:(NSTimeInterval)duration elasticAnimated:(BOOL)isElasticAnimated {
    if (!self.isPresenting) return;
    
    if (nil != self.willDismiss) {
        self.willDismiss(self);
    } else {
        if ([self.delegate respondsToSelector:@selector(popupControllerWillDismiss:)]) {
            [self.delegate popupControllerWillDismiss:self];
        }
    }
    
    if (isElasticAnimated) {
        
        NSTimeInterval duration1 = duration * 0.25, duration2 = duration - duration1;
        [UIView animateWithDuration:duration1
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             _popupView.center = [self elasticSpacePoint:30];
                             [self maskAlphaElastic];
                             
                         } completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:duration2
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  
                                                  [self dropAnimatedDismissed];
                                                  [self maskAlphaInitial];
                                                  _popupView.center = [self dismissedCenterPoint];
                                                  
                                              } completion:^(BOOL finished) {
                                                  
                                                  if (!finished) return;
                                                  [self removeSubviews];
                                                  _isPresenting = NO;
                                                  _popupView.transform = CGAffineTransformIdentity;
                                                  if (nil != self.didDismiss) {
                                                      self.didDismiss(self);
                                                  } else {
                                                      if ([self.delegate respondsToSelector:@selector(popupControllerDidDismiss:)]) {
                                                          [self.delegate popupControllerDidDismiss:self];
                                                      }
                                                  }
                                              }];
                         }];
    } else {
        
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             [self dropAnimatedDismissed];
                             [self maskAlphaInitial];
                             _popupView.center = [self dismissedCenterPoint];
                             
                         } completion:^(BOOL finished) {
                             
                             if (!finished) return;
                             [self removeSubviews];
                             _isPresenting = NO;
                             _popupView.transform = CGAffineTransformIdentity;
                             if (nil != self.didDismiss) {
                                 self.didDismiss(self);
                             } else {
                                 if ([self.delegate respondsToSelector:@selector(popupControllerDidDismiss:)]) {
                                     [self.delegate popupControllerDidDismiss:self];
                                 }
                             }
                         }];
    }
}

- (void)dismiss {
    id object = objc_getAssociatedObject(self, PopupControllerParametersKey);
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        NSTimeInterval duration = 0.0;
        NSNumber* durationNumber = [object valueForKey:@"duration"];
        if (nil != durationNumber) {
            duration = durationNumber.doubleValue;
        }
        BOOL flag = NO;
        NSNumber *flagNumber = [object valueForKey:@"isElasticAnimated"];
        if (nil != flagNumber) {
            flag = flagNumber.boolValue;
        }
        [self dismissWithDuration:duration elasticAnimated:flag];
    }
}

#pragma mark - Move Elastic

- (CGPoint)elasticSpacePoint:(CGFloat)move {
    
    CGPoint point = _popupView.center;
    switch (_layoutType) {
        case CSPopupLayoutTypeTop:
            point.y += move;
            break;
        case CSPopupLayoutTypeBottom:
            point.y -= move;
            break;
        case CSPopupLayoutTypeLeft:
            point.x += move;
            break;
        case CSPopupLayoutTypeRight:
            point.x -= move;
            break;
        case CSPopupLayoutTypeCenter: {
            
            switch (_transitStyle) {
                case CSPopupTransitStyleFromTop:
                    point.y += _dismissOppositeDirection ? -move : move;
                    break;
                case CSPopupTransitStyleFromBottom:
                    point.y += _dismissOppositeDirection ? move : -move;
                    break;
                case CSPopupTransitStyleFromLeft:
                    point.x += _dismissOppositeDirection ? -move : move;
                    break;
                case CSPopupTransitStyleFromRight:
                    point.x += _dismissOppositeDirection ? move : -move;
                    break;
                case CSPopupTransitStyleSlightScale:
                    _popupView.transform = _dismissOppositeDirection ? CGAffineTransformMakeScale(1.05, 1.05) : CGAffineTransformMakeScale(0.95, 0.95);
                    break;
                case CSPopupTransitStyleShrinkInOut:
                    _popupView.transform = _dismissOppositeDirection ? CGAffineTransformMakeScale(0.95, 0.95) : CGAffineTransformMakeScale(1.05, 1.05);
                    break;
                case CSPopupTransitStyleDefault: break;
                default: break;
            }
            
        } break;
        default: break;
    }
    return point;
}

#pragma mark - Drop Animated

- (BOOL)dropEligible {
    if (_layoutType == CSPopupLayoutTypeCenter && _transitStyle == CSPopupTransitStyleFromTop) {
        return YES;
    }
    return NO;
}

- (void)dropAnimatedInitial {
    if (_dropTransitionAnimated && [self dropEligible]) {
        _dismissOppositeDirection = YES;
        CGFloat ty = (_maskView.bounds.size.height + _popupView.frame.size.height) / 2;
        CATransform3D transform = CATransform3DMakeTranslation(0, -ty, 0);
        transform = CATransform3DRotate(transform, randomValues(40, -40) * M_PI / 180, 0, 0, 1.0);
        _popupView.layer.transform = transform;
    }
}

- (void)dropAnimatedFinished {
    if (_dropTransitionAnimated && [self dropEligible]) {
        _popupView.layer.transform = CATransform3DIdentity;
    }
}

- (void)dropAnimatedDismissed {
    if (_dropTransitionAnimated && [self dropEligible]) {
        CGFloat ty = _maskView.bounds.size.height;
        CATransform3D transform = CATransform3DMakeTranslation(0, ty, 0);
        transform = CATransform3DRotate(transform, randomValues(40, -40) * M_PI / 180, 0, 0, 1.0);
        _popupView.layer.transform = transform;
    }
}

#pragma mark - Mask Alpha

- (void)maskAlphaInitial {
    if (_maskType == CSPopupMaskTypeBlackBlur || _maskType == CSPopupMaskTypeWhiteBlur) {
        _maskView.alpha = 0;
    } else {
        _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
    }
}

- (void)maskAlphaElastic {
    if (_maskType == CSPopupMaskTypeBlackBlur || _maskType == CSPopupMaskTypeWhiteBlur) {
        _maskView.alpha = 0.95;
    } else if (_maskType == CSPopupMaskTypeDefault) {
        _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_maskAlpha - _maskAlpha * 0.15];
    }
}

- (void)maskAlphaFinished {
    if (_maskType == CSPopupMaskTypeBlackBlur || _maskType == CSPopupMaskTypeWhiteBlur) {
        _maskView.alpha = 1;
    } else {
        [self setMaskType:_maskType];
    }
}

#pragma mark - Center Point

- (CGPoint)finishedCenterPoint {
    
    CGPoint point = _maskView.center;
    switch (_layoutType) {
        case CSPopupLayoutTypeTop:
            point = CGPointMake(point.x, _popupView.bounds.size.height * 0.5);
            break;
        case CSPopupLayoutTypeBottom:
            point = CGPointMake(point.x, _maskView.bounds.size.height - _popupView.bounds.size.height * 0.5);
            break;
        case CSPopupLayoutTypeLeft:
            point = CGPointMake(_popupView.bounds.size.width * 0.5, point.y);
            break;
        case CSPopupLayoutTypeRight:
            point = CGPointMake(_maskView.bounds.size.width - _popupView.bounds.size.width * 0.5, point.y);
            break;
        case CSPopupLayoutTypeCenter: {
            
            switch (_transitStyle) {
                case CSPopupTransitStyleSlightScale: {
                    _maskView.alpha = 1;
                    _popupView.transform = CGAffineTransformIdentity;
                } break;
                case CSPopupTransitStyleShrinkInOut:
                    _popupView.transform = CGAffineTransformIdentity;
                    break;
                case CSPopupTransitStyleDefault:
                    _maskView.alpha = 1;
                    break;
                default: break;
            }
            
        } break;
        default: break;
    }
    return point;
}

- (CGPoint)initialCenterPoint {
    switch (_layoutType) {
        case CSPopupLayoutTypeCenter: {
            
            switch (_transitStyle) {
                case CSPopupTransitStyleSlightScale: {
                    _maskView.alpha = 0;
                    _popupView.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    return _maskView.center;
                }
                case CSPopupTransitStyleShrinkInOut: {
                    _popupView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                    return _maskView.center;
                }
                case CSPopupTransitStyleDefault: {
                    _maskView.alpha = 0;
                    return _maskView.center;
                }
                default: return [self pointInitialDirection:_transitStyle];
            }
            
        } break;
        default: return [self pointInitialDirection:_layoutType];
    }
}

- (CGPoint)dismissedCenterPoint {
    
    switch (_layoutType) {
        case CSPopupLayoutTypeCenter: {
            
            switch (_transitStyle) {
                case CSPopupTransitStyleFromTop:
                    return _dismissOppositeDirection ? CGPointMake(_maskView.center.x, _maskView.bounds.size.height + _popupView.bounds.size.height * 0.5) : CGPointMake(_maskView.center.x, -_popupView.bounds.size.height * 0.5);
                    
                case CSPopupTransitStyleFromBottom:
                    return _dismissOppositeDirection ? CGPointMake(_maskView.center.x, -_popupView.bounds.size.height * 0.5) : CGPointMake(_maskView.center.x, _maskView.bounds.size.height + _popupView.bounds.size.height * 0.5);
                    
                case CSPopupTransitStyleFromLeft:
                    return _dismissOppositeDirection ? CGPointMake(_maskView.bounds.size.width + _popupView.bounds.size.width * 0.5, _maskView.center.y) : CGPointMake(-_popupView.bounds.size.width * 0.5, _maskView.center.y);
                    
                case CSPopupTransitStyleFromRight:
                    return _dismissOppositeDirection ? CGPointMake(-_popupView.bounds.size.width * 0.5, _maskView.center.y) : CGPointMake(_maskView.bounds.size.width + _popupView.bounds.size.width * 0.5, _maskView.center.y);
                    
                case CSPopupTransitStyleSlightScale: {
                    _popupView.transform = _dismissOppositeDirection ? CGAffineTransformMakeScale(0.95, 0.95) : CGAffineTransformMakeScale(1.05, 1.05);
                    _maskView.alpha = 0;
                    return _maskView.center;
                }
                case CSPopupTransitStyleShrinkInOut:
                    _popupView.transform = _dismissOppositeDirection ? CGAffineTransformMakeScale(1.95, 1.95) : CGAffineTransformMakeScale(0.05, 0.05);
                    return _maskView.center;
                    
                case CSPopupTransitStyleDefault:
                    _maskView.alpha = 0;
                    return _maskView.center;
                    
                default: return _maskView.center;
            }
            
        } break;
        default: return [self pointInitialDirection:_layoutType];
    }
}

- (CGPoint)pointInitialDirection:(NSInteger)direction {
    switch (direction) {
        case 0: // top
            return CGPointMake(_maskView.center.x, -_popupView.bounds.size.height * 0.5) ;
        case 1: // bottom
            return CGPointMake(_maskView.center.x, _maskView.bounds.size.height + _popupView.bounds.size.height * 0.5);
        case 2: // left
            return CGPointMake(-_popupView.bounds.size.width * 0.5, _maskView.center.y);
        case 3: // right
            return CGPointMake(_maskView.bounds.size.width + _popupView.bounds.size.width * 0.5, _maskView.center.y);
        default:
            return _maskView.center;
    }
}

#pragma mark - Notification handlers

- (void)willChangeStatusBarOrientation {
    _maskView.frame = _superview.bounds;
    _popupView.center = [self finishedCenterPoint];
    [self dismiss];
}

- (void)didChangeStatusBarOrientation {
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) { // must manually fix orientation prior to iOS 8
        CGFloat angle;
        switch ([UIApplication sharedApplication].statusBarOrientation)
        {
            case UIInterfaceOrientationPortraitUpsideDown:
                angle = M_PI;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                angle = -M_PI_2;
                break;
            case UIInterfaceOrientationLandscapeRight:
                angle = M_PI_2;
                break;
            default: // as UIInterfaceOrientationPortrait
                angle = 0.0;
                break;
        }
        _popupView.transform = CGAffineTransformMakeRotation(angle);
    }
    _maskView.frame = _superview.bounds;
    _popupView.center = [self finishedCenterPoint];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:_popupView]) {
        return NO;
    }
    return YES;
}

#pragma mark - Action selector

- (void)handleTap:(UITapGestureRecognizer *)g {
    if (_dismissOnMaskTouched) {
        if (nil != self.maskTouched) {
            self.maskTouched(self);
        } else {
            [self dismiss];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)g {
    if (!_allowPan || !_isPresenting) {
        return;
    }
    
    CGPoint translation = [g translationInView:_maskView];
    switch (g.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            switch (_layoutType) {
                case CSPopupLayoutTypeCenter: {
                    
                    BOOL verticalTransformation = NO;
                    switch (_transitStyle) {
                        case CSPopupTransitStyleFromLeft:
                        case CSPopupTransitStyleFromRight: break;
                        default:
                            verticalTransformation = YES;
                            break;
                    }
                    // set screen ratio `_maskView.bounds.size.height / coefficient`
                    NSInteger coefficient = 4;
                    CGFloat changeValue;
                    if (verticalTransformation) {
                        g.view.center = CGPointMake(g.view.center.x, g.view.center.y + translation.y);
                        changeValue = g.view.center.y / (_maskView.bounds.size.height / coefficient);
                    } else {
                        g.view.center = CGPointMake(g.view.center.x + translation.x, g.view.center.y);
                        changeValue = g.view.center.x / (_maskView.bounds.size.width / coefficient);
                    }
                    CGFloat alpha = coefficient * 0.5 - fabs(changeValue - coefficient * 0.5);
                    [UIView animateWithDuration:0.15 animations:^{
                        _maskView.alpha = alpha;
                    } completion:NULL];
                    
                } break;
                case CSPopupLayoutTypeBottom: {
                    if (g.view.frame.origin.y + translation.y > _maskView.bounds.size.height - g.view.bounds.size.height) {
                        g.view.center = CGPointMake(g.view.center.x, g.view.center.y + translation.y);
                    }
                } break;
                case CSPopupLayoutTypeTop: {
                    if (g.view.frame.origin.y + g.view.frame.size.height + translation.y  < g.view.bounds.size.height) {
                        g.view.center = CGPointMake(g.view.center.x, g.view.center.y + translation.y);
                    }
                } break;
                case CSPopupLayoutTypeLeft: {
                    if (g.view.frame.origin.x + g.view.frame.size.width + translation.x < g.view.bounds.size.width) {
                        g.view.center = CGPointMake(g.view.center.x + translation.x, g.view.center.y);
                    }
                } break;
                case CSPopupLayoutTypeRight: {
                    if (g.view.frame.origin.x + translation.x > _maskView.bounds.size.width - g.view.bounds.size.width) {
                        g.view.center = CGPointMake(g.view.center.x + translation.x, g.view.center.y);
                    }
                } break;
                default: break;
            }
            [g setTranslation:CGPointZero inView:_maskView];
        } break;
        case UIGestureRecognizerStateEnded: {
            BOOL willDismiss = YES, styleCentered = NO;
            switch (_layoutType) {
                case CSPopupLayoutTypeCenter: {
                    styleCentered = YES;
                    if (g.view.center.y != _maskView.center.y) {
                        if (g.view.center.y > _maskView.bounds.size.height * 0.25 && g.view.center.y < _maskView.bounds.size.height * 0.75) {
                            willDismiss = NO;
                        }
                    } else {
                        if (g.view.center.x > _maskView.bounds.size.width * 0.25 && g.view.center.x < _maskView.bounds.size.width * 0.75) {
                            willDismiss = NO;
                        }
                    }
                } break;
                case CSPopupLayoutTypeBottom:
                    willDismiss = g.view.frame.origin.y > _maskView.bounds.size.height - g.view.frame.size.height * 0.75;
                    break;
                case CSPopupLayoutTypeTop:
                    willDismiss = g.view.frame.origin.y + g.view.frame.size.height < g.view.frame.size.height * 0.75;
                    break;
                case CSPopupLayoutTypeLeft:
                    willDismiss = g.view.frame.origin.x + g.view.frame.size.width < g.view.frame.size.width * 0.75;
                    break;
                case CSPopupLayoutTypeRight:
                    willDismiss = g.view.frame.origin.x > _maskView.bounds.size.width - g.view.frame.size.width * 0.75;
                    break;
                default: break;
            }
            if (willDismiss) {
                if (styleCentered) {
                    switch (_transitStyle) {
                        case CSPopupTransitStyleSlightScale:
                        case CSPopupTransitStyleShrinkInOut:
                        case CSPopupTransitStyleDefault: {
                            if (g.view.center.y < _maskView.bounds.size.height * 0.25) {
                                _transitStyle = CSPopupTransitStyleFromTop;
                            } else {
                                if (g.view.center.y > _maskView.bounds.size.height * 0.75) {
                                    _transitStyle = CSPopupTransitStyleFromBottom;
                                }
                            }
                            _dismissOppositeDirection = NO;
                        } break;
                        case CSPopupTransitStyleFromTop:
                            _dismissOppositeDirection = !(g.view.center.y < _maskView.bounds.size.height * 0.25);
                            break;
                        case CSPopupTransitStyleFromBottom:
                            _dismissOppositeDirection = g.view.center.y < _maskView.bounds.size.height * 0.25;
                            break;
                        case CSPopupTransitStyleFromLeft:
                            _dismissOppositeDirection = !(g.view.center.x < _maskView.bounds.size.width * 0.25);
                            break;
                        case CSPopupTransitStyleFromRight:
                            _dismissOppositeDirection = g.view.center.x < _maskView.bounds.size.width * 0.25;
                            break;
                        default: break;
                    }
                }
                [self dismissWithDuration:0.20 elasticAnimated:NO];
                
            } else {
                // restore view location.
                id object = objc_getAssociatedObject(self, PopupControllerParametersKey);
                NSNumber *flagNumber = [object valueForKey:@"isElasticAnimated"];
                BOOL flag = NO;
                if (nil != flagNumber) {
                    flag = flagNumber.boolValue;
                }
                NSTimeInterval duration = 0.25;
                NSNumber* durationNumber = [object valueForKey:@"duration"];
                if (nil != durationNumber) {
                    duration = durationNumber.doubleValue;
                }
                if (flag) {
                    [UIView animateWithDuration:duration
                                          delay:0.0
                         usingSpringWithDamping:0.6
                          initialSpringVelocity:0.2
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:^{
                                         g.view.center = [self finishedCenterPoint];
                                     } completion:NULL];
                } else {
                    [UIView animateWithDuration:duration
                                          delay:0.0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         g.view.center = [self finishedCenterPoint];
                                     } completion:NULL];
                }
            }
        } break;
        case UIGestureRecognizerStateCancelled:
            break;
        default: break;
    }
}

#pragma mark - dealloc

- (void)dealloc{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIApplicationWillChangeStatusBarOrientationNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIApplicationDidChangeStatusBarOrientationNotification
                                                 object:nil];
    [self removeSubviews];
}

@end


static void *NSObjectPopupControllerKey = &NSObjectPopupControllerKey;

@implementation NSObject (CSPopupController)

- (void)setShowPopupController:(CSPopupController *)showPopupController{
    objc_setAssociatedObject(self, NSObjectPopupControllerKey, showPopupController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CSPopupController *)showPopupController{
    id popupController = objc_getAssociatedObject(self, NSObjectPopupControllerKey);
    if (nil == popupController) {
        popupController = [[CSPopupController alloc] init];
        self.showPopupController = popupController;
    }
    return popupController;
}


@end
