//
//  CSNetworkTopMaskView.m
//  CSKit
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSNetworkTopMaskView.h"


#define kMaskUIColorFromHex(hexValue)     ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0\
                                                           green:((float)((hexValue & 0x00FF00) >> 8))/255.0 \
                                                            blue:((float)(hexValue & 0x0000FF))/255.0        \
                                                           alpha:1.0])


@interface CSNetworkTopMaskView ()

@property (nonatomic, copy) void (^touchBlock)(void);

@end




@implementation CSProgressHUD (Extension)

/** 获取子view */
+ (UIView *)getHUDFromSubview:(UIView *)addView
{
    if (addView) {
        for (UIView *tipVieww in addView.subviews) {
            if ([tipVieww isKindOfClass:[CSProgressHUD class]]) {
                if (tipVieww.superview) {
                    [tipVieww removeFromSuperview];
                }
            }
        }
    } else {
        addView = [UIApplication sharedApplication].keyWindow;
    }
    return addView;
}

/** 隐藏指定view上创建的CSProgressHUD */
+ (void)hideLoadingFromView:(UIView *)view
{
    for (UIView *tipView in view.subviews) {
        if ([tipView isKindOfClass:[CSProgressHUD class]]) {
            CSProgressHUD *HUD = (CSProgressHUD *)tipView;
            if (tipView.superview) {
                [tipView removeFromSuperview];
            }
            [HUD showAnimated:YES];
        }
    }
}

/**
 在自定义view上暂时卡住页面
 
 @param addView  提示层加在当前页面上
 @param message 提示语
 */
+ (void)showToastViewOnView:(UIView *)addView text:(NSString *)message
{
    addView = [self getHUDFromSubview:addView];
    
    CSProgressHUD *HUD = [[CSProgressHUD alloc] initWithView:addView];
    [addView addSubview:HUD];
    
    if (message.length>14) {
        HUD.detailsLabel.text = message;
    } else {
        if(message) HUD.label.text = message;
        else HUD.label.text = @"请稍等";
    }
    
    HUD.mode = CSProgressHUDModeText;
    HUD.removeFromSuperViewOnHide = YES;
    // HUD.dimBackground = YES;// YES代表需要蒙版效果
    [HUD showAnimated:YES];
    [HUD hideAnimated:YES afterDelay:2.0];
}


/**
 在指定view上显示转圈的CSProgressHUD (不会自动消失,需要手动调用隐藏方法)
 
 @param tipStr 提示语
 */
+ (void)showLoadingWithView:(UIView *)addView text:(NSString *)tipStr
{
    addView = [self getHUDFromSubview:addView];
    
    CSProgressHUD *HUD = [[CSProgressHUD alloc] initWithView:addView];
    [addView addSubview:HUD];
    HUD.mode = CSProgressHUDModeIndeterminate;
    HUD.userInteractionEnabled = NO;
    HUD.label.text = tipStr;
    [HUD showAnimated:YES];
}

@end





@implementation CSNetworkTopMaskView


/** 根据类型显示提示view */
+ (UIView *)tipViewByFrame:(CGRect)frame
              tipImageName:(NSString *)imageName
                   tipText:(id)tipText
               actionTitle:(NSString *)actionTitle
               actionBlock:(void(^)(void))touchBlock
{
    CSNetworkTopMaskView *tipBgView = [[CSNetworkTopMaskView alloc] initCustomView:frame tipImageName:imageName tipText:tipText actionTitle:actionTitle actionBlock:touchBlock];
    tipBgView.tag = kRequestTipViewTag;
    tipBgView.backgroundColor = kMaskUIColorFromHex(0xf5f6f8);
    return tipBgView;
}


- (instancetype)initCustomView:(CGRect)frame
                  tipImageName:(NSString *)imageName
                       tipText:(id)tipText
                   actionTitle:(NSString *)actionTitle
                   actionBlock:(void(^)(void))touchBlock{
    if (self == [super initWithFrame:frame]) {
        self.touchBlock = touchBlock;
        
        UIImage *image = [UIImage imageNamed:imageName];
        if (!image) {
            NSBundle *bundle = [NSBundle bundleForClass:[CSNetworkTopMaskView class]];
            NSString *imageNamePath = [NSString stringWithFormat:@"CSNetworkTools.bundle/%@",imageName];
            image = [UIImage imageNamed:imageNamePath inBundle:bundle compatibleWithTraitCollection:nil];
        }
        
        //中间文字
        UILabel *_tipLabel = nil;
        if (tipText) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.font = [UIFont boldSystemFontOfSize:14];
            _tipLabel.textColor = kMaskUIColorFromHex(0x666666);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_tipLabel];
            
            if ([tipText isKindOfClass:[NSString class]]) {
                _tipLabel.text = tipText;
            } else if ([tipText isKindOfClass:[NSAttributedString class]]) {
                _tipLabel.attributedText = tipText;
            }
            [_tipLabel sizeToFit];
            
            CGRect rect = _tipLabel.frame;
            rect.origin.x = (frame.size.width - _tipLabel.frame.size.width)/2;
            rect.origin.y = frame.size.height *0.4;
            _tipLabel.frame = rect;
        }
        
        //顶部图片
        UIImageView *_tipImageView = nil;
        if (image && _tipLabel) {
            CGFloat tipImageX = (frame.size.width-image.size.width)/2;
            _tipImageView = [[UIImageView alloc] initWithImage:image];
            _tipImageView.frame = CGRectMake(tipImageX, 0, image.size.width, image.size.height);
            _tipImageView.contentMode = UIViewContentModeScaleAspectFill;
            [self addSubview:_tipImageView];
            
            CGRect tipRect = _tipImageView.frame;
            tipRect.origin.y = CGRectGetMinY(_tipLabel.frame) - (_tipImageView.frame.size.height);
            _tipImageView.frame = tipRect;
        }
        
        //底部按钮
        if (actionTitle && touchBlock && _tipLabel) {
            CGFloat actionBtnW = 80;
            CGFloat actionBtnX = (frame.size.width - actionBtnW)/2;
            CGFloat actionBtnY = CGRectGetMaxY(_tipLabel.frame) + 15;
            UIButton *actionBtn = [[UIButton alloc] initWithFrame:CGRectMake(actionBtnX, actionBtnY, actionBtnW, 30)];
            [actionBtn setTitle:actionTitle forState:0];
            actionBtn.backgroundColor = [UIColor whiteColor];
            actionBtn.layer.cornerRadius = 6;
            actionBtn.layer.borderColor = kMaskUIColorFromHex(0x666666).CGColor;
            actionBtn.layer.borderWidth = 1;
            [actionBtn setTitleColor:kMaskUIColorFromHex(0x666666) forState:0];
            actionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            [self addSubview:actionBtn];
            [actionBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

/** 点击事件 */
- (void)btnAction:(UIButton *)btn{
    if (self.touchBlock) {
        self.touchBlock();
    }
}

@end






