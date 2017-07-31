//
//  CSTestTableModel.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSTestTableModel : NSObject

@property(copy,nonatomic) NSString *userName;//用户名
@property(copy,nonatomic) NSString *avtar;//头像
@property(copy,nonatomic) NSString *time;//发布时间
@property(copy,nonatomic) NSString *content;//发布时间
@property(strong,nonatomic) NSArray *imageArr;//图片数组

@end
