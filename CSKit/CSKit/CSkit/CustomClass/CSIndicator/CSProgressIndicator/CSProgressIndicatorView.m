//
//  CSProgressIndicatorView.m
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSProgressIndicatorView.h"
#import "CSProgressIndicator.h"

@interface CSProgressIndicatorView ()

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIActivityIndicatorView *activatyView;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIView *backgroundView;

@end

@implementation CSProgressIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = kCSProgressCornerRadius;
        self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }
    return self;
}

#pragma mark - getters

-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.image = [UIImage imageNamed:@"ft_info"];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}
-(UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textColor = kCSProgressDefaultTextColor;
        _messageLabel.font = kCSProgressDefaultFont;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        [self.contentView addSubview:_messageLabel];
    }
    return _messageLabel;
}
-(UIActivityIndicatorView *)activatyView
{
    if (!_activatyView) {
        _activatyView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activatyView.color = kCSProgressDefaultTextColor;
        [_activatyView setHidesWhenStopped:YES];
        [self.contentView addSubview:_activatyView];
    }
    return _activatyView;
}
-(UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backgroundView.backgroundColor = kCSProgressDefaultBackgroundColor;
    }
    return _backgroundView;
}

-(void)setUserInteractionEnable:(BOOL)userInteractionEnable
{
    self.userInteractionEnabled = userInteractionEnable;
    self.backgroundView.frame = [UIScreen mainScreen].bounds;
    if (userInteractionEnable) {
        [self.backgroundView removeFromSuperview];
    }else{
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.backgroundView];
    }
    self.backgroundView.hidden = userInteractionEnable;
}


-(UIColor *)getTextColorWithStyle:(UIBlurEffectStyle)style
{
    switch (style) {
        case UIBlurEffectStyleDark:
            return kCSProgressDefaultTextColor_ForDarkStyle;
            break;
        default:
            return kCSProgressDefaultTextColor;
            break;
    }
}
-(UIImage *)getImageWithStyle:(UIBlurEffectStyle)style messageType:(CSProgressIndicatorMessageType )type
{
    UIImage *image;
    NSString *bundlePath = [[NSBundle bundleForClass:[CSProgressIndicator class]] pathForResource:@"CSProgressIndicatorImage" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    switch (type) {
        case CSProgressIndicatorMessageTypeInfo:
            if (style == UIBlurEffectStyleDark) {
                image = [UIImage imageNamed:@"ft_info" inBundle:bundle compatibleWithTraitCollection:nil];
            }else{
                image = [UIImage imageNamed:@"ft_info_dark" inBundle:bundle compatibleWithTraitCollection:nil];
            }
            break;
        case CSProgressIndicatorMessageTypeSuccess:
            if (style == UIBlurEffectStyleDark) {
                image = [UIImage imageNamed:@"ft_success" inBundle:bundle compatibleWithTraitCollection:nil];
            }else{
                image = [UIImage imageNamed:@"ft_success_dark" inBundle:bundle compatibleWithTraitCollection:nil];
            }
            break;
        case CSProgressIndicatorMessageTypeError:
            if (style == UIBlurEffectStyleDark) {
                image = [UIImage imageNamed:@"ft_failure" inBundle:bundle compatibleWithTraitCollection:nil];
            }else{
                image = [UIImage imageNamed:@"ft_failure_dark" inBundle:bundle compatibleWithTraitCollection:nil];
            }
            break;
        default:
            break;
    }
    return image;
}

#pragma mark - main methods

-(void)showProgressWithType:(CSProgressIndicatorMessageType )type message:(NSString *)message style:(UIBlurEffectStyle)style userInteractionEnable:(BOOL)userInteractionEnable
{
    self.effect = [UIBlurEffect effectWithStyle:style];
    
    if (type == CSProgressIndicatorMessageTypeProgress) {
        self.iconImageView.hidden = YES;
        [self.activatyView startAnimating];
    }else{
        self.iconImageView.hidden = NO;
        [self.activatyView stopAnimating];
    }
    self.userInteractionEnable = userInteractionEnable;
    self.messageLabel.text = message;
    self.messageLabel.hidden = !message.length;
    self.messageLabel.textColor = [self getTextColorWithStyle:style];
    self.activatyView.color = [self getTextColorWithStyle:style];
    self.iconImageView.image = [self getImageWithStyle:style messageType:type];
    
    
    CGSize messageSize = [self getFrameForProgressMessageLabelWithMessage:message];
    CGSize viewSize = [self getFrameForProgressViewWithMessage:message];
    
    CGRect rect = CGRectMake((viewSize.width - messageSize.width)/2, kCSProgressMargin_Y + kCSProgressImageSize + kCSProgressImageToLabel, messageSize.width, messageSize.height);
    
    self.iconImageView.frame = CGRectMake((viewSize.width - kCSProgressImageSize)/2, kCSProgressMargin_Y, kCSProgressImageSize,  kCSProgressImageSize);
    self.activatyView.frame = CGRectMake((viewSize.width - kCSProgressImageSize)/2, kCSProgressMargin_Y, kCSProgressImageSize,  kCSProgressImageSize);
    
    self.messageLabel.frame = rect;
    
}

#pragma mark - getFrameForProgressMessageLabelWithMessage

-(CGSize )getFrameForProgressMessageLabelWithMessage:(NSString *)progressMessage
{
    CGSize size = CGSizeZero;
    if (progressMessage.length) {
        CGRect textSize = [progressMessage boundingRectWithSize:CGSizeMake(kCSProgressMaxWidth - kCSProgressMargin_X*2, MAXFLOAT)
                                                        options:(NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin)
                                                     attributes:@{NSFontAttributeName : kCSProgressDefaultFont}
                                                        context:nil];
        size = CGSizeMake(MAX(textSize.size.width, kCSProgressImageSize), MIN(textSize.size.height ,kCSProgressMaxWidth - kCSProgressMargin_Y*2 - kCSProgressImageToLabel - kCSProgressImageSize));
    }else{
        size = CGSizeMake(kCSProgressImageSize, 0);
    }
    return size;
}

#pragma mark - getFrameForProgressViewWithMessage

-(CGSize )getFrameForProgressViewWithMessage:(NSString *)progressMessage
{
    CGSize textSize = [self getFrameForProgressMessageLabelWithMessage:progressMessage];
    CGSize size = CGSizeZero;
    if (progressMessage.length) {
        size = CGSizeMake(MIN(textSize.width + kCSProgressMargin_X*2 , kCSProgressMaxWidth), MIN(textSize.height + kCSProgressMargin_Y*2 + kCSProgressImageSize + kCSProgressImageToLabel,kCSProgressMaxWidth));
    }else{
        size = CGSizeMake(MIN(textSize.width + kCSProgressMargin_X*2 , kCSProgressMaxWidth), kCSProgressMargin_Y*2 + kCSProgressImageSize);
    }
    return size;
}

@end
