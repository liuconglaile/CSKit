//
//  CSAlertView.h
//  CSCategory
//
//  Created by mac on 2017/6/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


@interface CSAlertButton : UIButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType NS_UNAVAILABLE;
+ (instancetype)buttonWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(CSAlertButton *button))handler;

@property (nonatomic, assign) UIEdgeInsets edgeInset; // top -> 间距 / bottom -> 最底部留白

@end

@interface CSAlertView : UIView

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message;
- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message width:(CGFloat)width;

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *messageLabel;
@property (nonatomic, strong, nullable) UIColor *linesColor; // All the line color.
@property (nonatomic, assign) BOOL linesHidden;

- (void)addAction:(nonnull CSAlertButton *)action;
- (void)addAdjoinWithCancelAction:(nonnull CSAlertButton *)cancelAction okAction:(nonnull CSAlertButton *)okAction;

@end

NS_ASSUME_NONNULL_END

