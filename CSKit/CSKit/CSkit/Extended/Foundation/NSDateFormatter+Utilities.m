//
//  NSDateFormatter+Utilities.m
//  CSCategory
//
//  Created by mac on 17/5/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSDateFormatter+Utilities.h"

@implementation NSDateFormatter (Utilities)

+(NSDateFormatter *)dateFormatterWithFormat:(NSString *)format {
    return [self dateFormatterWithFormat:format timeZone:nil];
}

+(NSDateFormatter *)dateFormatterWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone {
    return [self dateFormatterWithFormat:format timeZone:timeZone locale:nil];
}

+(NSDateFormatter *)dateFormatterWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale {
    if (format == nil || [format isEqualToString:@""]) return nil;
    NSString *key = [NSString stringWithFormat:@"NSDateFormatter-tz-%@-fmt-%@-loc-%@", [timeZone abbreviation], format, [locale localeIdentifier]];
    NSMutableDictionary* dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter* dateFormatter = [dictionary objectForKey:key];
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:format];
        [dictionary setObject:dateFormatter forKey:key];
#if !__has_feature(objc_arc)
        [dateFormatter autorelease];
#endif
    }
    if (locale != nil) [dateFormatter setLocale:locale]; // 这可能会改变，所以不要缓存
    if (timeZone != nil) [dateFormatter setTimeZone:timeZone]; // 这可能会改变
    return dateFormatter;
}

+(NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)style {
    return [self dateFormatterWithDateStyle:style timeZone:nil];
}

+(NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone {
    NSString *key = [NSString stringWithFormat:@"NSDateFormatter-%@-dateStyle-%d", [timeZone abbreviation], (int)style];
    NSMutableDictionary* dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter* dateFormatter = [dictionary objectForKey:key];
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:style];
        [dictionary setObject:dateFormatter forKey:key];
#if !__has_feature(objc_arc)
        [dateFormatter autorelease];
#endif
    }
    if (timeZone != nil) [dateFormatter setTimeZone:timeZone]; // 这可能会改变，所以不要缓存
    return dateFormatter;
}

+(NSDateFormatter *)dateFormatterWithTimeStyle:(NSDateFormatterStyle)style {
    return [self dateFormatterWithTimeStyle:style timeZone:nil];
}

+(NSDateFormatter *)dateFormatterWithTimeStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone {
    NSString *key = [NSString stringWithFormat:@"NSDateFormatter-%@-timeStyle-%d", [timeZone abbreviation], (int)style];
    NSMutableDictionary* dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter* dateFormatter = [dictionary objectForKey:key];
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:style];
        [dictionary setObject:dateFormatter forKey:key];
#if !__has_feature(objc_arc)
        [dateFormatter autorelease];
#endif
    }
    if (timeZone != nil) [dateFormatter setTimeZone:timeZone]; // 这可能会改变，所以不要缓存
    return dateFormatter;
}

@end
