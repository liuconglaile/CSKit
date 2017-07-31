//
//  CSBaseCell.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSBaseClickView,CSBaseLayoutModel;

/** cell 点击 */
typedef void(^CSCellAction)(id action);


/**
 基类 cell
 */
@interface CSBaseCell : UITableViewCell

/**
 containerView 用于替换contetView
 ~介于tableViewCell的姿势图如果设置了阴影&圆角&选中的时候这些都会消息
 */
@property(strong ,nonatomic) CSBaseClickView  *containerView;
@property(strong ,nonatomic) CSBaseLayoutModel *layout;
@property(assign ,nonatomic) CAGradientLayer *line;//分割线
@property(strong ,nonatomic) UIColor *lineColor;
@property(copy   ,nonatomic) CSCellAction cellAction;



//初始化视图控件 这个方法教给子类去重写 不需要调用父类
- (void)setUpView;
- (UITableView*)currnTableView;
- (NSIndexPath *)currnIndexPath;
- (void)addActionBlock:(CSCellAction)block;

- (void)getlayout:(CSBaseLayoutModel *)layout;

@end
