//
//  CSNotificationIndicatorView.m
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSNotificationIndicatorView.h"

@interface CSNotificationIndicatorView ()

@property (strong, nonatomic) NSString *message;

@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;

@end

@implementation CSNotificationIndicatorView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    return self;
}

#pragma mark - getters

-(UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCSNotificationMargin_X, kCSNotificationStatusBarHeight + kCSNotificationMargin_Y, kCSNotificationImageSize, kCSNotificationImageSize)];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCSNotificationMargin_X*2 + kCSNotificationImageSize, kCSNotificationStatusBarHeight, kCSNotificationScreenWidth - kCSNotificationMargin_X*2 - kCSNotificationImageSize,  kCSNotificationTitleHeight)];
        _titleLabel.font = kCSNotificationDefaultTitleFont;
        _titleLabel.textColor = kCSNotificationDefaultTextColor;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

-(UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCSNotificationMargin_X*2 + kCSNotificationImageSize, kCSNotificationStatusBarHeight+kCSNotificationTitleHeight, kCSNotificationScreenWidth - kCSNotificationMargin_X*2 - kCSNotificationImageSize, 40)];
        _messageLabel.textColor = kCSNotificationDefaultTextColor;
        _messageLabel.font = kCSNotificationDefaultMessageFont;
        _messageLabel.numberOfLines = 0;
        [self.contentView addSubview:_messageLabel];
    }
    return _messageLabel;
}

-(UIColor *)getTextColorWithStyle:(UIBlurEffectStyle)style
{
    switch (style) {
        case UIBlurEffectStyleDark:
            return kCSNotificationDefaultTextColor_ForDarkStyle;
            break;
        default:
            return kCSNotificationDefaultTextColor;
            break;
    }
}

#pragma mark - main methods

-(void)showWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message style:(UIBlurEffectStyle)style
{
    self.effect = [UIBlurEffect effectWithStyle:style];
    
    if (image) {
        self.iconImageView.image = image;
    }
    self.iconImageView.hidden = !(image);
    self.titleLabel.text = title;
    self.messageLabel.text = message;
    self.titleLabel.textColor = [self getTextColorWithStyle:style];
    self.messageLabel.textColor = [self getTextColorWithStyle:style];
    
    
    CGSize messageSize = [self getFrameForNotificationMessageLabelWithImage:self.iconImageView.image message:message];
    
    CGFloat text_X = image ? kCSNotificationMargin_X*2 + kCSNotificationImageSize : kCSNotificationMargin_X;
    
    _iconImageView.frame = CGRectMake(kCSNotificationMargin_X, kCSNotificationStatusBarHeight + kCSNotificationMargin_Y, kCSNotificationImageSize, kCSNotificationImageSize);
    
    self.titleLabel.frame = CGRectMake(text_X, kCSNotificationStatusBarHeight, kCSNotificationScreenWidth - kCSNotificationMargin_X - text_X,  kCSNotificationTitleHeight);
    self.messageLabel.frame = CGRectMake(text_X, kCSNotificationStatusBarHeight+kCSNotificationTitleHeight, kCSNotificationScreenWidth - kCSNotificationMargin_X - text_X, messageSize.height);
}

#pragma mark - getFrameForNotificationMessageLabelWithImage

-(CGSize )getFrameForNotificationMessageLabelWithImage:(UIImage *)image message:(NSString *)notificationMessage
{
    CGFloat textWidth = image ? (kCSNotificationScreenWidth - kCSNotificationMargin_X*3 - kCSNotificationImageSize) : (kCSNotificationScreenWidth - kCSNotificationMargin_X*2);
    CGRect textSize = [notificationMessage boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                                        options:(NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin)
                                                     attributes:@{NSFontAttributeName : kCSNotificationDefaultMessageFont}
                                                        context:nil];
    CGSize size = CGSizeMake(textSize.size.width, MIN(textSize.size.height ,kCSNotificationMaxHeight - kCSNotificationTitleHeight - kCSNotificationStatusBarHeight - kCSNotificationMargin_Y));
    return size;
}

#pragma mark - getFrameForNotificationViewWithImage

-(CGSize )getFrameForNotificationViewWithImage:(UIImage *)image message:(NSString *)notificationMessage
{
    CGSize textSize = [self getFrameForNotificationMessageLabelWithImage:image message:notificationMessage];
    CGSize size = CGSizeMake(kCSNotificationScreenWidth, MAX(MIN(textSize.height + kCSNotificationMargin_Y + kCSNotificationTitleHeight + kCSNotificationStatusBarHeight,kCSNotificationMaxHeight), kCSNotificationStatusBarHeight + kCSNotificationMargin_Y*2 + kCSNotificationImageSize));
    return size;
}


@end
