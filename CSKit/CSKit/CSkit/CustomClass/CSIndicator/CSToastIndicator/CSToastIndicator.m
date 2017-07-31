//
//  CSToastIndicator.m
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSToastIndicator.h"
#import "CSToastIndicatorView.h"

@interface CSToastIndicator ()

@property (nonatomic, strong) CSToastIndicatorView *toastView;
@property (nonatomic, assign) UIBlurEffectStyle indicatorStyle;
@property (nonatomic, strong) NSString *toastMessage;
@property (nonatomic, strong) NSTimer *dismissTimer;
@property (nonatomic, assign) BOOL isDuringAnimation;
@property (nonatomic, assign) BOOL isCurrentlyOnScreen;

@end

@implementation CSToastIndicator

#pragma mark - class methods

+(CSToastIndicator *)sharedInstance{
    static CSToastIndicator *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[CSToastIndicator alloc] init];
    });
    return shared;
}

+(void)setToastIndicatorStyleToDefaultStyle{
    [self sharedInstance].indicatorStyle = UIBlurEffectStyleLight;
}

+(void)setToastIndicatorStyle:(UIBlurEffectStyle)style{
    [self sharedInstance].indicatorStyle = style;
}

+(void)showToastMessage:(NSString *)toastMessage{
    [[self sharedInstance] showToastMessage:toastMessage];
}

+(void)dismiss{
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

- (CSToastIndicatorView *)toastView{
    if (!_toastView) {
        _toastView = [[CSToastIndicatorView alloc] initWithFrame:CGRectZero];
    }
    return _toastView;
}

- (void)showToastMessage:(NSString *)toastMessage{
    self.toastMessage = toastMessage;
    self.isCurrentlyOnScreen = NO;
    
    if (self.isDuringAnimation) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kCSToastDefaultAnimationDuration * 2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self adjustIndicatorFrame];
        });
    }else{
        [self adjustIndicatorFrame];
    }
}

- (void)dismiss{
    [self stopDismissTimer];
    [self dismissingToastView];
}

-(void)adjustIndicatorFrame{
    self.toastView.alpha = 1;
    self.toastView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    
    CGSize toastSize = [self.toastView getFrameForToastViewWithMessage:self.toastMessage];
    
    [self.toastView setFrame:CGRectMake((kCSToastScreenWidth - toastSize.width)/2, kCSToastScreenHeight - [self keyboardHeight] - kCSToastToBottom - toastSize.height, toastSize.width, toastSize.height)];
    
    [self.toastView showToastMessage:self.toastMessage withStyle:self.indicatorStyle];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.toastView];
    
    self.toastView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
    
    [self startShowingToastView];
}

-(void)onChangeStatusBarOrientationNotification:(NSNotification *)notification{
    if (self.isCurrentlyOnScreen) {
        [self adjustIndicatorFrame];
    }
}

- (void)onKeyboardWillChangeFrame:(NSNotification *)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSTimeInterval animationDuration;
    
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect originRect = self.toastView.frame;
    
    CGFloat y = MIN(kCSToastScreenWidth, keyboardRect.origin.y) - kCSToastToBottom - originRect.size.height;
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.toastView setFrame:CGRectMake(originRect.origin.x, y, originRect.size.width, originRect.size.height)];
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
    
    CGFloat timeInterval = MAX(self.toastMessage.length * 0.04 + 0.5, 2.0);
    _dismissTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                     target:self
                                                   selector:@selector(dismissingToastView)
                                                   userInfo:nil
                                                    repeats:NO];
}

-(void)stopDismissTimer{
    if (_dismissTimer) {
        [_dismissTimer invalidate];
        _dismissTimer = nil;
    }
}

-(void)startShowingToastView{
    self.isDuringAnimation = YES;
    self.toastView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
    [UIView animateWithDuration:kCSToastDefaultAnimationDuration
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.toastView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                         
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

-(void)dismissingToastView{
    self.isDuringAnimation = YES;
    [UIView animateWithDuration:kCSToastDefaultAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.toastView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
                         
                     } completion:^(BOOL finished) {
                         if(finished){
                             self.isDuringAnimation = NO;
                             self.isCurrentlyOnScreen = NO;
                             [self.toastView removeFromSuperview];
                         }
                     }];
}

@end
