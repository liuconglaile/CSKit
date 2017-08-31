//
//  CSTextUtilities.h
//  CSCategory
//
//  Created by mac on 2017/7/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>

#if __has_include(<CSKit/CSKit.h>)
#import <CSkit/CSMacrosHeader.h>
#else
#import "CSMacrosHeader.h"
#endif


CS_EXTERN_C_BEGIN
NS_ASSUME_NONNULL_BEGIN


/**
 字符是否为'换行符':
 U+000D (\\r or CR)
 U+2028 (Unicode line separator)
 U+000A (\\n or LF)
 U+2029 (Unicode paragraph separator)
 
 @param c  一个字符
 @return YES or NO.
 */
static inline BOOL CSTextIsLinebreakChar(unichar c) {
    switch (c) {
        case 0x000D:
        case 0x2028:
        case 0x000A:
        case 0x2029:
            return YES;
        default:
            return NO;
    }
}


/**
 字符串是否为'换行符':
 U+000D (\\r or CR)
 U+2028 (Unicode line separator)
 U+000A (\\n or LF)
 U+2029 (Unicode paragraph separator)
 \\r\\n, in that order (also known as CRLF)
 
 @param str A string
 @return YES or NO.
 */
static inline BOOL CSTextIsLinebreakString(NSString * _Nullable str) {
    if (str.length > 2 || str.length == 0) return NO;
    if (str.length == 1) {
        unichar c = [str characterAtIndex:0];
        return CSTextIsLinebreakChar(c);
    } else {
        return ([str characterAtIndex:0] == '\r') && ([str characterAtIndex:1] == '\n');
    }
}



/**
 如果字符串具有'换行符'后缀,则返回'换行符'长度.
 
 @param str  A string.
 @return The length of the tail line break: 0, 1 or 2.
 */
static inline NSUInteger CSTextLinebreakTailLength(NSString * _Nullable str) {
    if (str.length >= 2) {
        unichar c2 = [str characterAtIndex:str.length - 1];
        if (CSTextIsLinebreakChar(c2)) {
            unichar c1 = [str characterAtIndex:str.length - 2];
            if (c1 == '\r' && c2 == '\n') return 2;
            else return 1;
        } else {
            return 0;
        }
    } else if (str.length == 1) {
        return CSTextIsLinebreakChar([str characterAtIndex:0]) ? 1 : 0;
    } else {
        return 0;
    }
}


/**
 将 UIDataDetectorTypes 转换为 NSTextCheckingType
 
 @param types  The `UIDataDetectorTypes` type.
 @return The `NSTextCheckingType` type.
 */
static inline NSTextCheckingType NSTextCheckingTypeFromUIDataDetectorType(UIDataDetectorTypes types) {
    NSTextCheckingType t = 0;
    if (types & UIDataDetectorTypePhoneNumber) t |= NSTextCheckingTypePhoneNumber;
    if (types & UIDataDetectorTypeLink) t |= NSTextCheckingTypeLink;
    if (types & UIDataDetectorTypeAddress) t |= NSTextCheckingTypeAddress;
    if (types & UIDataDetectorTypeCalendarEvent) t |= NSTextCheckingTypeDate;
    return t;
}



/**
 字体是否为'AppleColorEmoji'字体.
 
 @param font  A font.
 @return YES:字体是Emoji,NO:字体不是表情符号.
 */
static inline BOOL UIFontIsEmoji(UIFont *font) {
    return [font.fontName isEqualToString:@"AppleColorEmoji"];
}



/**
 字体是否为'AppleColorEmoji'字体.
 
 @param font  A font.
 @return YES:字体是Emoji,NO:字体不是表情符号.
 */
static inline BOOL CTFontIsEmoji(CTFontRef font) {
    BOOL isEmoji = NO;
    CFStringRef name = CTFontCopyPostScriptName(font);
    if (name && CFEqual(CFSTR("AppleColorEmoji"), name)) isEmoji = YES;
    if (name) CFRelease(name);
    return isEmoji;
}


/**
 字体是否为'AppleColorEmoji'字体.
 
 @param font  A font.
 @return YES:字体是Emoji,NO:字体不是表情符号.
 */
static inline BOOL CGFontIsEmoji(CGFontRef font) {
    BOOL isEmoji = NO;
    CFStringRef name = CGFontCopyPostScriptName(font);
    if (name && CFEqual(CFSTR("AppleColorEmoji"), name)) isEmoji = YES;
    if (name) CFRelease(name);
    return isEmoji;
}



/**
 字体是否包含颜色位图字形.
 
 @discussion 只有'AppleColorEmoji'在iOS系统字体中包含彩色位图字形.
 @param font  A font.
 @return  YES:字体包含彩色位图字形,NO:字体没有颜色位图字形.
 */
static inline BOOL CTFontContainsColorBitmapGlyphs(CTFontRef font) {
    return  (CTFontGetSymbolicTraits(font) & kCTFontTraitColorGlyphs) != 0;
}




/**
 字形是否是位图.
 
 @param font  字体字形的字体.
 @param glyph 从指定字体创建的字形.
 @return 是:字形是位图,NO:字形是向量.
 */
static inline BOOL CGGlyphIsBitmap(CTFontRef font, CGGlyph glyph) {
    if (!font && !glyph) return NO;
    if (!CTFontContainsColorBitmapGlyphs(font)) return NO;
    CGPathRef path = CTFontCreatePathForGlyph(font, glyph, NULL);
    if (path) {
        CFRelease(path);
        return NO;
    }
    return YES;
}




/**
 以指定的字体大小获取'AppleColorEmoji'字体的上升.它可能用于创建自定义表情符号.
 
 @param fontSize  指定的字体大小.
 @return 字体上升.
 */
static inline CGFloat CSEmojiGetAscentWithFontSize(CGFloat fontSize) {
    if (fontSize < 16) {
        return 1.25 * fontSize;
    } else if (16 <= fontSize && fontSize <= 24) {
        return 0.5 * fontSize + 12;
    } else {
        return fontSize;
    }
}





/**
 以指定的字体大小获取'AppleColorEmoji'字体的下降.它可能用于创建自定义表情符号.
 
 @param fontSize  指定的字体大小.
 @return 字体下降.
 */
static inline CGFloat CSEmojiGetDescentWithFontSize(CGFloat fontSize) {
    if (fontSize < 16) {
        return 0.390625 * fontSize;
    } else if (16 <= fontSize && fontSize <= 24) {
        return 0.15625 * fontSize + 3.75;
    } else {
        return 0.3125 * fontSize;
    }
    return 0;
}




/**
 以指定的字体大小获取'AppleColorEmoji'字体的字形边界.它可能用于创建自定义表情符号.
 
 @param fontSize  指定的字体大小.
 @return 字体字形边界rect.
 */
static inline CGRect CSEmojiGetGlyphBoundingRectWithFontSize(CGFloat fontSize) {
    CGRect rect;
    rect.origin.x = 0.75;
    rect.size.width = rect.size.height = CSEmojiGetAscentWithFontSize(fontSize);
    if (fontSize < 16) {
        rect.origin.y = -0.2525 * fontSize;
    } else if (16 <= fontSize && fontSize <= 24) {
        rect.origin.y = 0.1225 * fontSize -6;
    } else {
        rect.origin.y = -0.1275 * fontSize;
    }
    return rect;
}



/**
 将UTF-32字符(等于或大于0x10000)转换为两个UTF-16代理对.
 
 @param char32 输入:UTF-32字符(等于或大于0x10000,不在BMP中)
 @param char16 输出:两个UTF-16字符.
 */
static inline void UTF32CharToUTF16SurrogatePair(UTF32Char char32, UTF16Char char16[_Nullable 2]) {
    char32 -= 0x10000;
    char16[0] = (char32 >> 10) + 0xD800;
    char16[1] = (char32 & 0x3FF) + 0xDC00;
}



/**
 将UTF-16替代对转换为UTF-32字符.
 
 @param char16 两个UTF-16字符.
 @return UTF-32字符.
 */
static inline UTF32Char UTF16SurrogatePairToUTF32Char(UTF16Char char16[_Nullable 2]) {
    return ((char16[0] - 0xD800) << 10) + (char16[1] - 0xDC00) + 0x10000;
}



/**
 获取应垂直旋转的字符集.
 @return 共享字符集.
 */
NSCharacterSet *CSTextVerticalFormRotateCharacterSet();

/**
 获取应旋转并以垂直形式移动的字符集.
 @return 共享字符集.
 */
NSCharacterSet *CSTextVerticalFormRotateAndMoveCharacterSet();




NS_ASSUME_NONNULL_END
CS_EXTERN_C_END

@interface CSTextUtilities : NSObject

@end







