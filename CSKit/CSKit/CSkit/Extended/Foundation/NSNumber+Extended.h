//
//  NSNumber+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (Extended)

/**
 从字符串中创建并返回一个NSNumber对象.
 有效格式: @"12", @"12.345", @" -0xFF", @" .23e99 "...
 
 @param string  字符串描述的数字.
 
 @return 解析成功时的NSNumber,如果发生错误,则为nil.
 */
+ (nullable NSNumber *)numberWithString:(NSString *)string;

- (NSString *)fileSize;

@end


NS_ASSUME_NONNULL_END
