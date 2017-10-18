//
//  NSNumber+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSNumber+Extended.h"

/**
 在每个类别实现之前添加这个宏,所以我们不必使用  -all_load 或 -force_load 仅从静态库加载对象文件包含类别,没有类.
 更多信息: http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html .
 *******************************************************************************
 
 示例:
 CSSYNTH_DUMMY_CLASS(NSString_CSAdd)
 
 @param _name_ 类别名
 @return 添加的类别
 */
#ifndef CSSYNTH_DUMMY_CLASS
#define CSSYNTH_DUMMY_CLASS(_name_) \
@interface CSSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation CSSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif

CSSYNTH_DUMMY_CLASS(NSNumber_Extended)

@implementation NSNumber (Extended)

+ (NSNumber *)numberWithString:(NSString *)string {
    NSString *str = [[self stringByTrimForString:string] lowercaseString];
    if (!str || !str.length) {
        return nil;
    }
    
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{@"true" :   @(YES),
                @"yes" :    @(YES),
                @"false" :  @(NO),
                @"no" :     @(NO),
                @"nil" :    [NSNull null],
                @"null" :   [NSNull null],
                @"<null>" : [NSNull null]};
    });
    id num = dic[str];
    if (num) {
        if (num == [NSNull null]) return nil;
        return num;
    }
    
    // hex number
    int sign = 0;
    if ([str hasPrefix:@"0x"]) sign = 1;
    else if ([str hasPrefix:@"-0x"]) sign = -1;
    if (sign != 0) {
        NSScanner *scan = [NSScanner scannerWithString:str];
        unsigned num = -1;
        BOOL suc = [scan scanHexInt:&num];
        if (suc)
            return [NSNumber numberWithLong:((long)num * sign)];
        else
            return nil;
    }
    // normal number
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

- (NSString *)fileSize{
    
    NSString *ret;
    unsigned long long size = [self unsignedLongLongValue];
    if (size<1024) {
        ret = [NSString stringWithFormat:@"%llu bytes",size];
    }else if (size<1024*1024) {
        ret = [NSString stringWithFormat:@"%.1lf KB",size/1024.f];
    }else if (size<1024*1024*1024) {
        ret = [NSString stringWithFormat:@"%.1lf MB",size/(1024.f*1024.f)];
    }
    
    return ret;
}


/**
 修剪头部和尾部的空白字符(空格和换行符)
 
 @return 处理好的字符串
 */
+ (NSString *)stringByTrimForString:(NSString*)aString {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [aString stringByTrimmingCharactersInSet:set];
}




#pragma mark - Display
- (NSString*)toDisplayNumberWithDigit:(NSInteger)digit
{
    NSString *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:digit];
    result = [formatter  stringFromNumber:self];
    if (result == nil)
        return @"";
    return result;
    
}

- (NSString*)toDisplayPercentageWithDigit:(NSInteger)digit
{
    NSString *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:digit];
    result = [formatter  stringFromNumber:self];
    return result;
}



#pragma mark - round, ceil, floor
- (NSNumber*)doRoundWithDigit:(NSUInteger)digit
{
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:digit];
    [formatter setMinimumFractionDigits:digit];
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    return result;
}


- (NSNumber*)doCeilWithDigit:(NSUInteger)digit
{
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    [formatter setMaximumFractionDigits:digit];
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    return result;
}

- (NSNumber*)doFloorWithDigit:(NSUInteger)digit
{
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundFloor];
    [formatter setMaximumFractionDigits:digit];
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    return result;
}





@end
