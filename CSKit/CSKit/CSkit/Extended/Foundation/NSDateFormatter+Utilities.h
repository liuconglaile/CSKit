//
//  NSDateFormatter+Utilities.h
//  CSCategory
//
//  Created by mac on 17/5/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Utilities)

/* 日期格式化，格式为 */
+(NSDateFormatter *)dateFormatterWithFormat:(NSString *)format;
/* 日期格式化，格式为 (带时区)*/
+(NSDateFormatter *)dateFormatterWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone;
/* 日期格式化，格式为 (带时区&区域)*/
+(NSDateFormatter *)dateFormatterWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale;

+(NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)style;
+(NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone;
+(NSDateFormatter *)dateFormatterWithTimeStyle:(NSDateFormatterStyle)style;
+(NSDateFormatter *)dateFormatterWithTimeStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone;

@end
