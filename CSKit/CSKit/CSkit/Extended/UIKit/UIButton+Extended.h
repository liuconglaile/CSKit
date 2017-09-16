//
//  UIButton+Extended.h
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^TouchedButtonBlock)(UIButton* btn);

/**
 按钮排版枚举
 
 - CSImagePositionLeft:   图左文右.默认
 - CSImagePositionRight:  图右文左
 - CSImagePositionTop:    图上文下
 - CSImagePositionBottom: 图下文上
 */
typedef NS_ENUM(NSInteger, CSImagePosition) {
    CSImagePositionLeft   = 0,
    CSImagePositionRight  = 1,
    CSImagePositionTop    = 2,
    CSImagePositionBottom = 3,
};


@interface UIButton (Extended)

@property (nonatomic, strong) UIFont  *titleFont;
@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIColor *highlightedTitleColor;
@property (strong, nonatomic) UIColor *selectedTitleColor;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *highlightedTitle;
@property (copy, nonatomic) NSString *selectedTitle;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *highlightedImage;
@property (copy, nonatomic) NSString *selectedImage;
@property (copy, nonatomic) NSString *bgImage;
@property (copy, nonatomic) NSString *highlightedBgImage;
@property (copy, nonatomic) NSString *selectedBgImage;




/** 使用颜色设置按钮背景 */
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;


/**
 添加点击事件
 
 @param touchHandler 事件回调
 */
- (void)addActionHandler:(TouchedButtonBlock)touchHandler;

/**
 倒计时按钮
 
 @param timeout 时间
 @param tittle 标题
 @param waitTittle 等待标题
 */
- (void)startTime:(NSInteger )timeout title:(NSString *)tittle waitTittle:(NSString *)waitTittle;



/**
 设置按钮排版
 
 @param postion 样式枚举
 @param spacing 间距
 */
- (void)setImagePosition:(CSImagePosition)postion spacing:(CGFloat)spacing;


/**
 imageView和titleLabel中间对准方法
 
 @param spacing ImageView和titleLabel之间的中间间距
 */
- (void)middleAlignButtonWithSpacing:(CGFloat)spacing;


/**
 这种方法会显示活动的指标来代替按钮文本. 不带文字
 */
- (void)showIndicator;

/**
 此方法将删除该标识，并把按钮上的文字放回原处.
 */
- (void)hideIndicator;



/**
 按钮点击后，禁用按钮并在按钮上显示ActivityIndicator，以及title
 
 @param title 按钮上显示的文字
 */
- (void)beginSubmitting:(NSString *)title;



/**
 按钮点击后，恢复按钮点击前的状态
 */
- (void)endSubmitting;

/**
 按钮是否正在提交中
 */
@property(nonatomic, readonly, getter=isSubmitting) NSNumber *submitting;

/**
 设置按钮额外热区
 */
@property (nonatomic, assign) UIEdgeInsets touchAreaInsets;

@end
