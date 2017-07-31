//
//  CSIconLabel.h
//  CSCategory
//
//  Created by mac on 2017/6/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSIconLabelModel;

@interface CSIconLabel : UIControl

@property (nonatomic, strong, readonly) UIImageView *iconView;
@property (nonatomic, strong, readonly) UILabel *textLabel;

/** default = UIEdgeInsetsZero 使用insets.bottom或insets.right来调整间距 */
@property (nonatomic, assign) UIEdgeInsets imageEdgeInsets;
/** default is NO */
@property (nonatomic, assign) BOOL horizontalLayout;
/** default is NO. 根据内容适应自身高度 */
@property (nonatomic, assign) BOOL autoresizingFlexibleSize;
/** textLabel根据文本计算size时，如果纵向布局则限高，横向布局则限宽 */
@property (nonatomic, assign) CGFloat sizeLimit;
/** 赋值模型 */
@property (nonatomic, strong) CSIconLabelModel *model;


/**
 属性赋值后需更新布局

 @param aSize 渲染布局 size
 @param aFinished 完成回调
 */
- (void)updateLayoutBySize:(CGSize)aSize finished:(void (^)(CSIconLabel *item))aFinished;

@end


@interface CSIconLabelModel : NSObject

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *text;
+ (instancetype)modelWithTitle:(NSString *)aTitle image:(UIImage *)aImage;

@end
