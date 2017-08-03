//
//  CSBaseCell.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSControl.h"
@class CSBaseLayoutModel;

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
@property(strong,nonatomic) CSControl  *containerView;
@property(strong,nonatomic) CSBaseLayoutModel *layout;
@property(assign,nonatomic) CAGradientLayer *line;//分割线
@property(strong,nonatomic) UIColor *lineColor;
@property(copy  ,nonatomic) CSCellAction cellAction;
//@property(copy   ,nonatomic) NSString* identifier;
@property (nonatomic, copy) void (^actionBlock)(UITableView *tableView,id data,NSIndexPath *indexPath,id action);


//初始化视图控件 这个方法交给子类去重写 不需要调用父类
- (void)setUpView;
- (UITableView*)currnTableView;
- (NSIndexPath *)currnIndexPath;



//- (void)addActionBlock:(CSCellAction)block;

- (void)getlayout:(CSBaseLayoutModel *)layout;

@end
