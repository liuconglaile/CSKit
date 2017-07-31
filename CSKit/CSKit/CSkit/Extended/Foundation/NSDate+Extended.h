//
//  NSDate+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Extended)

#pragma mark - Component Properties
///=============================================================================
/// @name Component Properties
///=============================================================================

@property (nonatomic, readonly) NSInteger year; ///< 年
@property (nonatomic, readonly) NSInteger month; ///< 月 (1~12)
@property (nonatomic, readonly) NSInteger day; ///< 日 (1~31)
@property (nonatomic, readonly) NSInteger hour; ///< 时 (0~23)
@property (nonatomic, readonly) NSInteger minute; ///< 分 (0~59)
@property (nonatomic, readonly) NSInteger second; ///< 秒 (0~59)
@property (nonatomic, readonly) NSInteger nanosecond; ///< 纳秒
@property (nonatomic, readonly) NSInteger weekday; ///< 工作日 (1~7, 第一天是基于用户设置)
@property (nonatomic, readonly) NSInteger weekdayOrdinal; ///< WeekdayOrdinal component
@property (nonatomic, readonly) NSInteger weekOfMonth; ///< WeekOfMonth component (1~5)
@property (nonatomic, readonly) NSInteger weekOfYear; ///< WeekOfYear component (1~53)
@property (nonatomic, readonly) NSInteger yearForWeekOfYear; ///< YearForWeekOfYear component
@property (nonatomic, readonly) NSInteger quarter; ///< Quarter component
@property (nonatomic, readonly) BOOL isLeapMonth; ///< whether the month is leap month
@property (nonatomic, readonly) BOOL isLeapYear; ///< whether the year is leap year
@property (nonatomic, readonly) BOOL isToday; ///< whether date is today (based on current locale)
@property (nonatomic, readonly) BOOL isYesterday; ///< whether date is yesterday (based on current locale)

#pragma mark - 日期修改
///=============================================================================
/// @name 日期修改
///=============================================================================

/**
 获取 N 年后的时间戳.
 
 @param years  要添加的年数.
 @return 由所需年数获取的日期.
 */
- (nullable NSDate *)dateByAddingYears:(NSInteger)years;

/** 获取 N 月后的时间戳 */
- (nullable NSDate *)dateByAddingMonths:(NSInteger)months;

/** 获取 N 周后的时间戳 */
- (nullable NSDate *)dateByAddingWeeks:(NSInteger)weeks;

/** 获取 N 周后的时间戳 */
- (nullable NSDate *)dateByAddingDays:(NSInteger)days;

/** 获取 N 小时后的时间戳 */
- (nullable NSDate *)dateByAddingHours:(NSInteger)hours;

/** 获取 N 分钟后的时间戳 */
- (nullable NSDate *)dateByAddingMinutes:(NSInteger)minutes;

/** 获取 N 秒后的时间戳 */
- (nullable NSDate *)dateByAddingSeconds:(NSInteger)seconds;


#pragma mark - 日期格式
///=============================================================================
/// @name 日期格式
///=============================================================================

/**
 返回表示此日期的格式化字符串.
 see http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 格式说明.
 
 @param format   表示所需日期格式的字符串. e.g. @"yyyy-MM-dd HH:mm:ss"
 
 @return NSString表示格式化的日期字符串.
 */
- (nullable NSString *)stringWithFormat:(NSString *)format;

/** 返回表示此日期的格式化字符串(带时区&所需语言环境). */
- (nullable NSString *)stringWithFormat:(NSString *)format timeZone:(nullable NSTimeZone *)timeZone locale:(nullable NSLocale *)locale;

/** 以ISO8601格式返回表示此日期的字符串. e.g. "2010-07-09T16:13:30+12:00" */
- (nullable NSString *)stringWithISOFormat;

/**
 返回从使用格式解释的给定字符串解析的日期
 
 @param dateString 要解析的字符串.
 @param format     字符串日期格式.
 */
+ (nullable NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

/** 返回表示此日期的格式化字符串(带时区&所需语言环境). */
+ (nullable NSDate *)dateWithString:(NSString *)dateString
                             format:(NSString *)format
                           timeZone:(nullable NSTimeZone *)timeZone
                             locale:(nullable NSLocale *)locale;

/** 返回从使用ISO8601格式解释的给定字符串解析的日期. */
+ (nullable NSDate *)dateWithISOFormatString:(NSString *)dateString;






#pragma mark - 日期计算
///=============================================================================
/// @name 日期计算
///=============================================================================

/**
 计算日开始/结束
 
 @return 日期
 */
- (NSDate *)beginningOfDay;
- (NSDate *)endOfDay;

/**
 计算周初/结束
 
 @return 开始
 */
- (NSDate *)beginningOfWeek;
- (NSDate *)endOfWeek;

/**
 计算个月，自/结束
 
 @return 开始
 */
- (NSDate *)beginningOfMonth;
- (NSDate *)endOfMonth;

/**
 计算年度开头/结尾
 
 @return 开始
 */
- (NSDate *)beginningOfYear;
- (NSDate *)endOfYear;



/**
 获取日、月、年、小时、分钟、秒
 */
+ (NSUInteger)day:(NSDate *)date;
+ (NSUInteger)month:(NSDate *)date;
+ (NSUInteger)year:(NSDate *)date;
+ (NSUInteger)hour:(NSDate *)date;
+ (NSUInteger)minute:(NSDate *)date;
+ (NSUInteger)second:(NSDate *)date;

/**
 获取一年中的总天数
 */
- (NSUInteger)daysInYear;
+ (NSUInteger)daysInYear:(NSDate *)date;

/**
 判断是否是润年
 
 @return YES表示润年，NO表示平年
 */
- (BOOL)isLeapYear;
+ (BOOL)isLeapYear:(NSDate *)date;

/**
 获取该日期是该年的第几周
 */
+ (NSUInteger)weekOfYear:(NSDate *)date;

/**
 获取格式化为YYYY-MM-dd格式的日期字符串
 */
- (NSString *)formatYMD;
+ (NSString *)formatYMD:(NSDate *)date;

/**
 返回当前月一共有几周(可能为4,5,6)
 */
- (NSUInteger)weeksOfMonth;
+ (NSUInteger)weeksOfMonth:(NSDate *)date;

/**
 获取该月的第一天的日期
 */
- (NSDate *)begindayOfMonth;
+ (NSDate *)begindayOfMonth:(NSDate *)date;

/**
 获取该月的最后一天的日期
 */
- (NSDate *)lastdayOfMonth;
+ (NSDate *)lastdayOfMonth:(NSDate *)date;


/**
 距离该日期前几天
 
 @return 距离天数
 */
- (NSUInteger)daysAgo;
+ (NSUInteger)daysAgo:(NSDate *)date;


/**
 获取星期几
 
 [1 - Sunday]
 [2 - Monday]
 [3 - Tuerday]
 [4 - Wednesday]
 [5 - Thursday]
 [6 - Friday]
 [7 - Saturday]
 
 @return 返回工作日号码
 */
- (NSInteger)weekday;
+ (NSInteger)weekday:(NSDate *)date;


/**
 获取星期几(名称)
 
 [1 - Sunday]
 [2 - Monday]
 [3 - Tuerday]
 [4 - Wednesday]
 [5 - Thursday]
 [6 - Friday]
 [7 - Saturday]
 
 @return 将工作日作为本地化字符串返回
 */
- (NSString *)dayFromWeekday;
+ (NSString *)dayFromWeekday:(NSDate *)date;


/**
 日期是否相等
 
 @param anotherDate 比较的NSDate
 @return 如果是同一天返回YES，否则NO
 */
- (BOOL)isSameDay:(NSDate *)anotherDate;

/**
 是否是今天
 */
- (BOOL)isToday;





/**
 从给定的月份号码获取本月的一个本地化字符串
 */
+ (NSString *)monthWithMonthNumber:(NSInteger)month;

/**
 根据日期返回字符串
 */
+ (NSString *)stringWithDate:(NSDate *)date format:(NSString *)format;

/**
 获取指定月份的天数
 */
- (NSUInteger)daysInMonth:(NSUInteger)month;
+ (NSUInteger)daysInMonth:(NSDate *)date month:(NSUInteger)month;

/**
 获取当前月份的天数
 */
- (NSUInteger)daysInMonth;
+ (NSUInteger)daysInMonth:(NSDate *)date;

/**
 返回x分钟前/x小时前/昨天/x天前/x个月前/x年前
 */
- (NSString *)timeInfo;
+ (NSString *)timeInfoWithDate:(NSDate *)date;
+ (NSString *)timeInfoWithDateString:(NSString *)dateString;

/**
 分别获取yyyy-MM-dd/HH:mm:ss/yyyy-MM-dd HH:mm:ss格式的字符串
 */
- (NSString *)ymdFormat;
- (NSString *)hmsFormat;
- (NSString *)ymdHmsFormat;
+ (NSString *)ymdFormat;
+ (NSString *)hmsFormat;
+ (NSString *)ymdHmsFormat;



@end

NS_ASSUME_NONNULL_END

