//
//  CSTestTableLayout.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSBaseLayoutModel.h"

@interface CSTestTableLayout : CSBaseLayoutModel

@property(assign,nonatomic) BOOL isOpen;//收起 显示
@property(nonatomic) CGRect avtarFrame;
@property(nonatomic) CGRect allBtnFrame;
@property(strong,nonatomic) CSTextLayout *userNameLayout;//用户名布局
@property(strong,nonatomic) CSTextLayout *timeLayout;//时间布局
@property(strong,nonatomic) CSTextLayout *contentLayout;//内容
@property(strong,nonatomic) NSMutableArray *imageSizeArr;


@end
