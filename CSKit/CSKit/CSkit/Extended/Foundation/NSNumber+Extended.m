//
//  NSNumber+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSNumber+Extended.h"

#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSMacrosHeader.h>
#import <CSkit/NSString+Extended.h>
#else
#import "CSMacrosHeader.h"
#import "NSString+Extended.h"
#endif

CSSYNTH_DUMMY_CLASS(NSNumber_Extended)

@implementation NSNumber (Extended)

+ (NSNumber *)numberWithString:(NSString *)string {
    NSString *str = [[string stringByTrim] lowercaseString];
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


@end
