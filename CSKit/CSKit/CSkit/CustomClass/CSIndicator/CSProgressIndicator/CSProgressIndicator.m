//
//  CSProgressIndicator.m
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSProgressIndicator.h"
#import "CSProgressIndicatorView.h"

@interface CSProgressIndicator ()

@property (nonatomic, strong) CSProgressIndicatorView *progressView;
@property (nonatomic, assign) UIBlurEffectStyle indicatorStyle;
@property (nonatomic, strong) NSString *progressMessage;
@property (nonatomic, strong) NSTimer *dismissTimer;
@property (nonatomic, assign) CSProgressIndicatorMessageType  messageType;
@property (nonatomic, assign) BOOL isDuringAnimation;
@property (nonatomic, assign) BOOL isCurrentlyOnScreen;
@property (nonatomic, assign) BOOL userInteractionEnable;

@end

@implementation CSProgressIndicator

#pragma mark - class methods

+ (CSProgressIndicator *)sharedInstance{
    static CSProgressIndicator *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[CSProgressIndicator alloc] init];
    });
    return shared;
}

+ (void)setProgressIndicatorStyleToDefaultStyle{
    [self sharedInstance].indicatorStyle = UIBlurEffectStyleLight;
}

+ (void)setProgressIndicatorStyle:(UIBlurEffectStyle)style{
    [self sharedInstance].indicatorStyle = style;
}

+ (void)showProgressWithmessage:(NSString *)message{
    [[self sharedInstance] showProgressWithType:CSProgressIndicatorMessageTypeProgress message:message userInteractionEnable:YES];
}

+ (void)showProgressWithmessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable{
    [[self sharedInstance] showProgressWithType:CSProgressIndicatorMessageTypeProgress message:message userInteractionEnable:userInteractionEnable];
}

+ (void)showInfoWithMessage:(NSString *)message{
    [[self sharedInstance] showProgressWithType:CSProgressIndicatorMessageTypeInfo message:message userInteractionEnable:YES];
}

+ (void)showInfoWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable{
    [[self sharedInstance] showProgressWithType:CSProgressIndicatorMessageTypeInfo message:message userInteractionEnable:userInteractionEnable];
}

+ (void)showSuccessWithMessage:(NSString *)message{
    [[self sharedInstance] showProgressWithType:CSProgressIndicatorMessageTypeSuccess message:message userInteractionEnable:YES];
}

+ (void)showSuccessWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable{
    [[self sharedInstance] showProgressWithType:CSProgressIndicatorMessageTypeSuccess message:message userInteractionEnable:userInteractionEnable];
}

+ (void)showErrorWithMessage:(NSString *)message{
    [[self sharedInstance] showProgressWithType:CSProgressIndicatorMessageTypeError message:message userInteractionEnable:YES];
}

+ (void)showErrorWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable{
    [[self sharedInstance] showProgressWithType:CSProgressIndicatorMessageTypeError message:message userInteractionEnable:userInteractionEnable];
}

+ (void)dismiss{
    [[self sharedInstance] dismiss];
}


#pragma mark - instance methods

- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onChangeStatusBarOrientationNotification:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardWillChangeFrame:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
    return self;
}

- (CSProgressIndicatorView *)progressView{
    if (!_progressView) {
        _progressView = [[CSProgressIndicatorView alloc] initWithFrame:CGRectZero];
    }
    return _progressView;
}

- (void)setUserInteractionEnable:(BOOL)userInteractionEnable{
    self.progressView.userInteractionEnable = userInteractionEnable;
    _userInteractionEnable = userInteractionEnable;
}

- (void)showProgressWithType:(CSProgressIndicatorMessageType )type message:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable{
    self.messageType = type;
    self.progressMessage = message;
    self.userInteractionEnable = userInteractionEnable;
    self.isCurrentlyOnScreen = NO;
    
    if (self.isDuringAnimation) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kCSProgressDefaultAnimationDuration * 2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self adjustIndicatorFrame];
        });
    }else{
        [self adjustIndicatorFrame];
    }
}

- (void)dismiss{
    [self stopDismissTimer];
    [self dismissingProgressView];
}

- (void)adjustIndicatorFrame{
    self.progressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    
    CGSize progressSize = [self.progressView getFrameForProgressViewWithMessage:self.progressMessage];
    
    [self.progressView setFrame:CGRectMake((kCSProgressScreenWidth - progressSize.width)/2, (kCSProgressScreenHeight - [self keyboardHeight] - progressSize.height)/2, progressSize.width, progressSize.height)];
    
    [self.progressView showProgressWithType:self.messageType message:self.progressMessage style:self.indicatorStyle userInteractionEnable:self.userInteractionEnable];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.progressView];
    
    [self startShowingProgressView];
}

- (void)onChangeStatusBarOrientationNotification:(NSNotification *)notification{
    if (self.isCurrentlyOnScreen) {
        [self adjustIndicatorFrame];
    }
}

- (void)onKeyboardWillChangeFrame:(NSNotification *)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    CGRect originRect = self.progressView.frame;
    CGFloat y = (MIN(kCSProgressScreenHeight, keyboardRect.origin.y) - originRect.size.height)/2;
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [self.progressView setFrame:CGRectMake(originRect.origin.x, y, originRect.size.width, originRect.size.height)];
                     }completion:^(BOOL finished) {
                         
                     }];
}

- (CGFloat)keyboardHeight{
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]){
        if ([[testWindow class] isEqual:[UIWindow class]] == NO){
            for (UIView *possibleKeyboard in [testWindow subviews]){
                if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]){
                    return possibleKeyboard.bounds.size.height;
                }else if ([[possibleKeyboard description] hasPrefix:@"<UIInputSetContainerView"]){
                    for (UIView *hostKeyboard in [possibleKeyboard subviews]){
                        if ([[hostKeyboard description] hasPrefix:@"<UIInputSetHost"]){
                            return hostKeyboard.frame.size.height;
                        }
                    }
                }
            }
        }
    }
    return 0;
}

- (void)startDismissTimer{
    [self stopDismissTimer];
    if (self.messageType != CSProgressIndicatorMessageTypeProgress) {
        CGFloat timeInterval = MAX(self.progressMessage.length * 0.04 + 0.5, 2.0);
        _dismissTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                         target:self
                                                       selector:@selector(dismissingProgressView)
                                                       userInfo:nil
                                                        repeats:NO];
    }
}

- (void)stopDismissTimer{
    if (_dismissTimer) {
        [_dismissTimer invalidate];
        _dismissTimer = nil;
    }
}

- (void)startShowingProgressView{
    self.progressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
    self.isDuringAnimation = YES;
    [UIView animateWithDuration:kCSProgressDefaultAnimationDuration
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.5
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         
                         self.progressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                         
                     } completion:^(BOOL finished) {
                         if (finished) {
                             self.isDuringAnimation = NO;
                             if (!self.isCurrentlyOnScreen) {
                                 [self startDismissTimer];
                             }
                             self.isCurrentlyOnScreen = YES;
                         }
                     }];
}

- (void)dismissingProgressView{
    self.isDuringAnimation = YES;
    [UIView animateWithDuration:kCSProgressDefaultAnimationDuration
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         
                         self.progressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
                         
                     } completion:^(BOOL finished) {
                         if(finished){
                             self.isDuringAnimation = NO;
                             self.isCurrentlyOnScreen = NO;
                             [self.progressView removeFromSuperview];
                             if (!self.userInteractionEnable) {
                                 self.userInteractionEnable = YES;
                             }
                         }
                     }];
}

@end
