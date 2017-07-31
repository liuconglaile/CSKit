//
//  CSToastIndicatorView.m
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSToastIndicatorView.h"

@interface CSToastIndicatorView ()

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) UILabel *messageLabel;

@end

@implementation CSToastIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = kCSToastCornerRadius;
        self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    return self;
}

#pragma mark - getters

-(UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = kCSToastDefaultTextColor;
        _messageLabel.font = kCSToastDefaultFont;
        [self.contentView addSubview:_messageLabel];
    }
    return _messageLabel;
}

-(UIColor *)getTextColorWithStyle:(UIBlurEffectStyle)style
{
    switch (style) {
        case UIBlurEffectStyleDark:
            return kCSToastDefaultTextColor_ForDarkStyle;
            break;
        default:
            return kCSToastDefaultTextColor;
            break;
    }
}

#pragma mark - main methods

-(void)showToastMessage:(NSString *)toastMessage withStyle:(UIBlurEffectStyle)style{
    self.effect = [UIBlurEffect effectWithStyle:style];
    
    self.message = toastMessage;
    self.messageLabel.textColor = [self getTextColorWithStyle:style];
    self.messageLabel.text = toastMessage;
    
    CGSize labelSize = [self getFrameForToastLabelWithMessage:toastMessage];
    CGSize viewSize = [self getFrameForToastViewWithMessage:toastMessage];
    
    CGFloat x = (viewSize.width - labelSize.width)/2;
    CGFloat y = (viewSize.height - labelSize.height)/2;
    CGRect rect = CGRectMake(x, y, labelSize.width, labelSize.height);
    self.messageLabel.frame = rect;
}

#pragma mark - getFrameForToastLabelWithMessage

-(CGSize )getFrameForToastLabelWithMessage:(NSString *)toastMessage{
    
    NSStringDrawingOptions options = NSStringDrawingUsesFontLeading |
                                     NSStringDrawingTruncatesLastVisibleLine |
                                     NSStringDrawingUsesLineFragmentOrigin;
    
    
    CGRect textSize = [toastMessage boundingRectWithSize:CGSizeMake(kCSToastMaxWidth - kCSToastMargin_X*2, MAXFLOAT)
                                                 options:options
                                              attributes:@{NSFontAttributeName : kCSToastDefaultFont}
                                                 context:nil];
    
    CGFloat max = MAX(textSize.size.width, kCSToastMargin_Y*2);
    CGFloat min = MIN(textSize.size.height ,kCSToastMaxHeight - kCSToastMargin_Y*2);
    CGSize size = CGSizeMake(max, min);
    return size;
}

#pragma mark - getFrameForToastViewWithMessage

-(CGSize )getFrameForToastViewWithMessage:(NSString *)toastMessage
{
    CGSize textSize = [self getFrameForToastLabelWithMessage:toastMessage];
    
    CGFloat max = MIN(textSize.width + kCSToastMargin_X*2 , kCSToastMaxWidth);
    CGFloat min = MIN(textSize.height + kCSToastMargin_Y*2 ,kCSToastMaxHeight);
    CGSize size = CGSizeMake(max, min);
    return size;
}

@end
