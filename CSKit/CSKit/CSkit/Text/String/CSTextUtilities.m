//
//  CSTextUtilities.m
//  CSCategory
//
//  Created by mac on 2017/7/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSTextUtilities.h"



NSCharacterSet *CSTextVerticalFormRotateCharacterSet() {
    static NSMutableCharacterSet *set;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSMutableCharacterSet new];
        [set addCharactersInRange:NSMakeRange(0x1100, 256)];    // 韩文Jamo
        [set addCharactersInRange:NSMakeRange(0x2460, 160)];    // 封闭式字母数字
        [set addCharactersInRange:NSMakeRange(0x2600, 256)];    // 杂项符号
        [set addCharactersInRange:NSMakeRange(0x2700, 192)];    // 装饰符号
        [set addCharactersInRange:NSMakeRange(0x2E80, 128)];    // CJK部首补充
        [set addCharactersInRange:NSMakeRange(0x2F00, 224)];    // 康熙部首
        [set addCharactersInRange:NSMakeRange(0x2FF0, 16)];     // 表意描述字符
        [set addCharactersInRange:NSMakeRange(0x3000, 64)];     // CJK符号和标点符号
        [set removeCharactersInRange:NSMakeRange(0x3008, 10)];
        [set removeCharactersInRange:NSMakeRange(0x3014, 12)];
        [set addCharactersInRange:NSMakeRange(0x3040, 96)];     // 平假名
        [set addCharactersInRange:NSMakeRange(0x30A0, 96)];     // 片假名
        [set addCharactersInRange:NSMakeRange(0x3100, 48)];     // 汉语拼音
        [set addCharactersInRange:NSMakeRange(0x3130, 96)];     // 韩文兼容性Jamo
        [set addCharactersInRange:NSMakeRange(0x3190, 16)];     // 汉文
        [set addCharactersInRange:NSMakeRange(0x31A0, 32)];     // Bopomofo扩展
        [set addCharactersInRange:NSMakeRange(0x31C0, 48)];     // CJK笔画
        [set addCharactersInRange:NSMakeRange(0x31F0, 16)];     // 片假名语音扩展
        [set addCharactersInRange:NSMakeRange(0x3200, 256)];    // 封闭式CJK字母和月份
        [set addCharactersInRange:NSMakeRange(0x3300, 256)];    // CJK兼容性
        [set addCharactersInRange:NSMakeRange(0x3400, 2582)];   // CJK统一表意扩展A
        [set addCharactersInRange:NSMakeRange(0x4E00, 20941)];  // CJK统一表意文字
        [set addCharactersInRange:NSMakeRange(0xAC00, 11172)];  // 韩文音节
        [set addCharactersInRange:NSMakeRange(0xD7B0, 80)];     // 韩文Jamo Extended-B
        [set addCharactersInString:@""];                       // U+F8FF(私人使用区)
        [set addCharactersInRange:NSMakeRange(0xF900, 512)];    // CJK兼容性表意文字
        [set addCharactersInRange:NSMakeRange(0xFE10, 16)];     // 垂直形式
        [set addCharactersInRange:NSMakeRange(0xFF00, 240)];    // 半宽和全宽形式
        [set addCharactersInRange:NSMakeRange(0x1F200, 256)];   // 封闭式表意文字补充
        [set addCharactersInRange:NSMakeRange(0x1F300, 768)];   // 封闭式表意文字补充
        [set addCharactersInRange:NSMakeRange(0x1F600, 80)];    // 表情 (Emoji)
        [set addCharactersInRange:NSMakeRange(0x1F680, 128)];   // 运输和地图符号
        
        // See http://unicode-table.com/ for more information.
    });
    return set;
}

NSCharacterSet *CSTextVerticalFormRotateAndMoveCharacterSet() {
    static NSMutableCharacterSet *set;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSMutableCharacterSet new];
        [set addCharactersInString:@"，。、．"];
    });
    return set;
}




@implementation CSTextUtilities

@end
