//
//  NSDictionary+ShowProperty.h
//  CSCategory
//
//  Created by mac on 2017/6/16.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 用于打印 json 返回数据转 Model 属性 (可针对 CSModel 打印映射)
 */
@interface NSDictionary (ShowProperty)

- (void)showPropertyWithPrefix:(NSString *)aPrefix AndBaseName:(NSString*)aBaseName isMapper:(BOOL)aMapper;

@end
