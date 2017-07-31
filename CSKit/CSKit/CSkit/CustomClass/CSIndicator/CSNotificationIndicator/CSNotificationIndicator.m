//
//  CSNotificationIndicator.m
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSNotificationIndicator.h"
#import "CSNotificationIndicatorView.h"

@interface CSNotificationIndicator ()

@property (nonatomic, strong) CSNotificationIndicatorView *notificationView;
@property (nonatomic, assign) UIBlurEffectStyle indicatorStyle;
@property (nonatomic, strong) UIImage *notificationImage;
@property (nonatomic, strong) NSString *notificationTitle;
@property (nonatomic, strong) NSString *notificationMessage;
@property (nonatomic, strong) NSTimer *dismissTimer;
@property (nonatomic, assign) BOOL isCurrentlyOnScreen;
@property (nonatomic, copy, nullable) CSNotificationTapHandler tapHandler;
@property (nonatomic, copy, nullable) CSNotificationCompletion completion;

@end

@implementation CSNotificationIndicator

#pragma mark - class methods

+(CSNotificationIndicator *)sharedInstance{
    static CSNotificationIndicator *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[CSNotificationIndicator alloc] init];
    });
    return shared;
}

+(void)setNotificationIndicatorStyleToDefaultStyle{
    [self sharedInstance].indicatorStyle = UIBlurEffectStyleLight;
}

+(void)setNotificationIndicatorStyle:(UIBlurEffectStyle)style{
    [self sharedInstance].indicatorStyle = style;
}

+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message{
    [self showNotificationWithImage:nil title:title message:message tapHandler:nil completion:nil];
}

+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler{
    [self showNotificationWithImage:nil title:title message:message tapHandler:tapHandler completion:nil];
}

+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler completion:(CSNotificationCompletion)completion
{
    [self showNotificationWithImage:nil title:title message:message tapHandler:tapHandler completion:completion];
}

+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message
{
    [self showNotificationWithImage:image title:title message:message tapHandler:nil completion:nil];
}

+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler
{
    [self showNotificationWithImage:image title:title message:message tapHandler:tapHandler completion:nil];
}

+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler completion:(CSNotificationCompletion)completion
{
    [[self sharedInstance] showNotificationWithImage:image title:title message:message tapHandler:tapHandler completion:completion];
}

+(void)dismiss
{
    [[self sharedInstance] dismiss];
}

#pragma mark - instance methods

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onChangeStatusBarOrientationNotification:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

-(CSNotificationIndicatorView *)notificationView
{
    if (!_notificationView) {
        _notificationView = [[CSNotificationIndicatorView alloc] initWithFrame:CGRectZero];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGuestureRecognized:)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGestureRecognized:)];
        [_notificationView addGestureRecognizer:pan];
        [_notificationView addGestureRecognizer:tap];
    }
    return _notificationView;
}

-(void)onPanGuestureRecognized:(UIPanGestureRecognizer *)sender
{
    if (self.isCurrentlyOnScreen) {
        CGPoint translation = [sender translationInView:[[UIApplication sharedApplication] keyWindow]];
        switch (sender.state) {
            case UIGestureRecognizerStateBegan: case UIGestureRecognizerStateChanged:
                if (translation.y < 0) {
                    [self.notificationView setFrame:CGRectMake(0,translation.y,kCSNotificationScreenWidth,self.notificationView.frame.size.height)];
                }
                break;
            case UIGestureRecognizerStateEnded:
                [self dismiss];
                break;
            default:
                break;
        }
    }
}

-(void)onTapGestureRecognized:(UITapGestureRecognizer*)sender{
    if(self.isCurrentlyOnScreen){
        switch (sender.state) {
            case UIGestureRecognizerStateEnded:
                [self dismissOnTapped:YES];
                if(self.tapHandler){
                    self.tapHandler();
                }
                break;
            default:
                break;
        }
    }
}

-(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler completion:(CSNotificationCompletion)completion
{
    self.notificationImage = image;
    self.notificationTitle = title;
    self.notificationMessage = message;
    self.isCurrentlyOnScreen = NO;
    self.tapHandler = tapHandler;
    self.completion = completion;
    
    [self adjustIndicatorFrame];
    
}

-(void)dismiss{
    [self dismissOnTapped:NO];
}

-(void)dismissOnTapped:(BOOL)tapped
{
    [self stopDismissTimer];
    [self dismissingNotificationtViewByTap:tapped];
}

-(void)adjustIndicatorFrame
{
    CGSize notificationSize = [self.notificationView getFrameForNotificationViewWithImage:self.notificationImage message:self.notificationMessage];
    
    [self.notificationView setFrame:CGRectMake(0,-(notificationSize.height),kCSNotificationScreenWidth,notificationSize.height)];
    
    [self.notificationView showWithImage:self.notificationImage title:self.notificationTitle message:self.notificationMessage style:self.indicatorStyle];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.notificationView];
    
    [self startShowingNotificationView];
}

-(void)onChangeStatusBarOrientationNotification:(NSNotification *)notification
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isCurrentlyOnScreen) {
            [self adjustIndicatorFrame];
        }
    });
}

-(void)startDismissTimer
{
    [self stopDismissTimer];
    CGFloat timeInterval = MAX(self.notificationMessage.length * 0.04 + 0.5, 2.0);
    
    _dismissTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                     target:self
                                                   selector:@selector(dismissingNotificationtView)
                                                   userInfo:nil
                                                    repeats:NO];
}

-(void)stopDismissTimer
{
    if (_dismissTimer) {
        [_dismissTimer invalidate];
        _dismissTimer = nil;
    }
}

-(void)startShowingNotificationView
{
    [UIView animateWithDuration:kCSNotificationDefaultAnimationDuration
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         [self.notificationView setFrame:CGRectMake(0,0,kCSNotificationScreenWidth,self.notificationView.frame.size.height)];
                         
                     } completion:^(BOOL finished) {
                         if (finished) {
                             if (!self.isCurrentlyOnScreen) {
                                 [self startDismissTimer];
                             }
                             self.isCurrentlyOnScreen = YES;
                         }
                     }];
}

-(void)dismissingNotificationtView{
    [self dismissingNotificationtViewByTap:NO];
}

-(void)dismissingNotificationtViewByTap:(BOOL)tap
{
    [UIView animateWithDuration:kCSNotificationDefaultAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         [self.notificationView setFrame:CGRectMake(0,-(self.notificationView.frame.size.height),kCSNotificationScreenWidth,(self.notificationView.frame.size.height))];
                         
                     } completion:^(BOOL finished) {
                         if(finished){
                             self.isCurrentlyOnScreen = NO;
                             [self.notificationView removeFromSuperview];
                             if(self.completion && !tap){
                                 self.completion();
                             }
                         }
                     }];
}

@end
