//
//  CSBaseLayoutModel.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CSTextLayout.h"


/**
 布局模型基类
 */
@interface CSBaseLayoutModel : NSObject
/** 重用标识符 */
@property(copy,nonatomic) NSString *reuseIdentifier;
/** 通用模型 */
@property(strong,nonatomic) id dataModel;
/** 行高 */
@property(assign,nonatomic) CGFloat cellHeight;
/** cell的 layout 配置 */
- (void)celllayout;
/** 匹配 url */
- (NSArray *)compareUrl:(NSString*)string;


/**
 得到富文本的布局&内容

 @param font 字体
 @param color 颜色
 @param width 宽度
 @param string 内容
 @param max 是否有最大行展示
 @return 布局类
 */
- (CSTextLayout *)layout:(UIFont *)font color:(UIColor*)color width:(CGFloat )width string:(NSString *)string max:(BOOL)max;

/**
 根据identifier 得到一个布局模型 
 identifier和tableVew注册的cell的identifier保持一致

 @param model 数据模型
 @param identifier 标识符
 @return 布局模型
 */
- (id )initWithModel:(id)model identifier:(NSString *)identifier;

@end
