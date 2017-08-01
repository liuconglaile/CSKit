//
//  NSString+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSString+Extended.h"
#import "NSData+Extended.h"
#import "NSNumber+Extended.h"
#import "UIDevice+Extended.h"
#import "CSKitMacro.h"

CSSYNTH_DUMMY_CLASS(NSString_Extended)

@implementation NSString (Extended)

- (NSString *)md2String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md2String];
}
- (NSString *)md4String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md4String];
}
- (NSString *)md5String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5String];
}
- (NSString *)sha1String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha1String];
}
- (NSString *)sha224String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha224String];
}
- (NSString *)sha256String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha256String];
}
- (NSString *)sha384String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha384String];
}
- (NSString *)sha512String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha512String];
}
- (NSString *)crc32String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] crc32String];
}
- (NSString *)hmacMD5StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacMD5StringWithKey:key];
}
- (NSString *)hmacSHA1StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacSHA1StringWithKey:key];
}
- (NSString *)hmacSHA224StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacSHA224StringWithKey:key];
}
- (NSString *)hmacSHA256StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacSHA256StringWithKey:key];
}
- (NSString *)hmacSHA384StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacSHA384StringWithKey:key];
}
- (NSString *)hmacSHA512StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] hmacSHA512StringWithKey:key];
}

- (NSString*)encryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv {
    NSData *encrypted = [[self dataUsingEncoding:NSUTF8StringEncoding] encryptedWith3DESUsingKey:key andIV:iv];
    NSString *encryptedString = [encrypted base64EncodedString];
    
    return encryptedString;
}

- (NSString*)decryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv {
    NSData *decrypted = [[NSData dataWithBase64EncodedString:self] decryptedWith3DESUsingKey:key andIV:iv];
    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}




- (NSString*)pinyinWithPhoneticSymbol{
    NSMutableString *pinyin = [NSMutableString stringWithString:self];
    CFStringTransform((__bridge CFMutableStringRef)(pinyin), NULL, kCFStringTransformMandarinLatin, NO);
    return pinyin;
}

- (NSString*)pinyin{
    NSMutableString *pinyin = [NSMutableString stringWithString:[self pinyinWithPhoneticSymbol]];
    CFStringTransform((__bridge CFMutableStringRef)(pinyin), NULL, kCFStringTransformStripCombiningMarks, NO);
    return pinyin;
}

- (NSArray*)pinyinArray{
    NSArray *array = [[self pinyin] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return array;
}

- (NSString*)pinyinWithoutBlank{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (NSString *str in [self pinyinArray]) {
        [string appendString:str];
    }
    return string;
}

- (NSArray*)pinyinInitialsArray{
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *str in [self pinyinArray]) {
        if ([str length] > 0) {
            [array addObject:[str substringToIndex:1]];
        }
    }
    return array;
}

- (NSString*)pinyinInitialsString{
    NSMutableString *pinyin = [NSMutableString stringWithString:@""];
    for (NSString *str in [self pinyinArray]) {
        if ([str length] > 0) {
            [pinyin appendString:[str substringToIndex:1]];
        }
    }
    return pinyin;
}









- (NSString *)base64EncodedString {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}
+ (NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString {
    NSData *data = [NSData dataWithBase64EncodedString:base64EncodedString];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
- (NSString *)stringByURLEncode {
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        /**
         AFNetworking/AFURLRequestSerialization.m
         
         返回百分号转义后的字符串RFC3986查询字符串键或值.
         RFC 3986规定以下字符为'预留'字符.
         - 一般分隔符: ":", "#", "[", "]", "@", "?", "/"
         - 子分隔符: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
         
         在RFC3986第3.4节中,它指出'?' 和'/'字符不应该被转义,以允许查询字符串包含一个URL.
         因此,除'?'之外的所有'预留'字符 和'/'应该在查询字符串中进行百分比转义
         
         - 参数string:要进行百分比转义的字符串.
         - 返回:转义百分比的字符串.
         */
        static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // 不包括 "?" 或者 "/" 由于 RFC 3986 - 第3.4节
        static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
        
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        static NSUInteger const batchSize = 50;
        
        NSUInteger index = 0;
        NSMutableString *escaped = @"".mutableCopy;
        
        while (index < self.length) {
            NSUInteger length = MIN(self.length - index, batchSize);
            NSRange range = NSMakeRange(index, length);
            // 为了避免分解字符序列,例如 👴🏻👮🏽
            range = [self rangeOfComposedCharacterSequencesForRange:range];
            NSString *substring = [self substringWithRange:range];
            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];
            
            index += range.length;
        }
        return escaped;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *encoded = (__bridge_transfer NSString *)
        CFURLCreateStringByAddingPercentEscapes(
                                                kCFAllocatorDefault,
                                                (__bridge CFStringRef)self,
                                                NULL,
                                                CFSTR("!#$&'()*+,/:;=?@[]"),
                                                cfEncoding);
        return encoded;
#pragma clang diagnostic pop
    }
    
    
    /**
     如果以上代码失效,可使用官方封装的方法
     
     NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, (CFStringRef)@":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`", kCFStringEncodingUTF8));
     return encodedString;
     
     */
}

- (NSString *)stringByURLDecode {
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
                                                            withString:@" "];
        decoded = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                NULL,
                                                                (__bridge CFStringRef)decoded,
                                                                CFSTR(""),
                                                                en);
        return decoded;
#pragma clang diagnostic pop
    }
    /**
     如果以上代码失效,可使用官方封装方法
     
     NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)string, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
     return decodedString;
     
     
     */
    
}

/**
 *  URLString解码
 *
 *  @param string URLString
 *
 *  @return 对UTF8解码
 */
+(NSString *)decodeURLString:(NSString *)string
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)string, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

/**
 将常见的 HTML 符号转换为实体
 Example: "a\<b" will be escape to "a&lt;b".
 */
- (NSString *)stringByEscapingHTML {
    NSUInteger len = self.length;
    if (!len) return self;
    
    unichar *buf = malloc(sizeof(unichar) * len);
    if (!buf) return self;
    [self getCharacters:buf range:NSMakeRange(0, len)];
    
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < len; i++) {
        unichar c = buf[i];
        NSString *esc = nil;
        switch (c) {
            case 34: esc = @"&quot;"; break;
            case 38: esc = @"&amp;"; break;
            case 39: esc = @"&apos;"; break;
            case 60: esc = @"&lt;"; break;
            case 62: esc = @"&gt;"; break;
            default: break;
        }
        if (esc) {
            [result appendString:esc];
        } else {
            CFStringAppendCharacters((CFMutableStringRef)result, &c, 1);
        }
    }
    free(buf);
    return result;
}




/**
 JSON字符串转成NSDictionary
 
 @return NSDictionary
 */
- (NSDictionary *)dictionaryValue{
    NSError *errorJson;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&errorJson];
    if (errorJson != nil) {
#ifdef DEBUG
        CSNSLog(@"fail to get dictioanry from JSON: %@, error: %@", self, errorJson);
#endif
    }
    return jsonDict;
}


/**
 判断URL中是否包含中文
 
 @return 包含返回YES,否则NO
 */
- (BOOL)isContainChinese
{
    NSUInteger length = [self length];
    for (NSUInteger i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [self substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3) {
            return YES;
        }
    }
    return NO;
}


/**
 是否包含空格
 
 @return 包含返回YES,否则NO
 */
- (BOOL)isContainBlank
{
    NSRange range = [self rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return YES;
    }
    return NO;
}


/**
 Unicode编码的字符串转成NSString
 
 @return NSString
 */
- (NSString *)makeUnicodeToString
{
    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    //NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}








/**
 使用指定的约束渲染字符串,并返回该字符串的size
 
 @param font  用于计算字符串大小的字体
 @param size 字符串的最大可接受大小.这个值是用于计算在那里换行
 @param lineBreakMode 用于计算字符串大小的换行符选项.有关可能值的列表,请参阅NSLineBreakMode
 @return 生成的字符串边界框的宽度和高度.这些值四舍五入为最接近的整数
 */
- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

/**
 基于指定的约束,并返回单行状态下的字符串宽度
 
 @param font 用于计算字符串大小的字体
 @return 字符串渲染所需宽度
 */
- (CGFloat)widthForFont:(UIFont *)font {
    CGSize size = [self sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}


/**
 基于指定的约束,并返回字符串渲染所需高度
 
 @param font 用于计算字符串大小的字体
 @param width 字符串渲染最大宽度
 @return 字符串渲染所需高度
 */
- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self sizeForFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping];
    return size.height;
}


/**
 字符串分页
 
 @param cache 需要分页的字符串
 @param font 约束字体
 @param r 布局约束
 @return 分页字符串数组
 */
- (NSArray *)getPagesOfString:(NSString *)cache
                     withFont:(UIFont*)font
                       inRect:(CGRect)r {
    
    //返回一个数组, 包含每一页的字符串开始点和长度(NSRange)
    NSMutableArray *ranges = [NSMutableArray array];
    //断行类型
    NSLineBreakMode lineBreakMode = NSLineBreakByCharWrapping;
    //显示字体的行高
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    CGFloat lineHeight = [@"Sample样本" sizeWithFont:font].height;
#else
    CGFloat lineHeight = [@"Sample样本" sizeWithAttributes:@{NSFontAttributeName : font}].height;
#endif
    
    NSInteger maxLine = floor(r.size.height/lineHeight);
    NSInteger totalLines = 0;
    CSNSLog(@"Max Line Per Page: %zd (%.2f/%.2f)", maxLine, r.size.height, lineHeight);
    NSString *lastParaLeft = nil;
    NSRange range = NSMakeRange(0, 0);
    //把字符串按段落分开, 提高解析效率
    NSArray *paragraphs = [cache componentsSeparatedByString:@"\n"];
    for (int p = 0; p<[paragraphs count]; p++) {
        NSString *para;
        if (lastParaLeft != nil) {
            //上一页完成后剩下的内容继续计算
            para = lastParaLeft;
            lastParaLeft = nil;
        } else {
            para = [paragraphs objectAtIndex:p];
            if (p < [paragraphs count] - 1)
                para = [para stringByAppendingString:@"\n"]; //刚才分段去掉了一个换行,现在还给它
        }
        
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
        
        CGSize paraSize = [para sizeWithFont:font constrainedToSize:r.size lineBreakMode:lineBreakMode];
        
#else
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = lineBreakMode;
        NSDictionary *attributes = @{NSFontAttributeName: font,
                                     NSParagraphStyleAttributeName: paragraph};
        CGSize paraSize = [para boundingRectWithSize:r.size
                                             options:(NSStringDrawingUsesLineFragmentOrigin |
                                                      NSStringDrawingTruncatesLastVisibleLine)
                                          attributes:attributes
                                             context:nil].size;
#endif
        
        
        //        CGSize paraSize=[para sizeWithFont:font constrainedToSize:r.size lineBreakMode:lineBreakMode];
        NSInteger paraLines = floor(paraSize.height/lineHeight);
        if (totalLines + paraLines < maxLine) {
            totalLines += paraLines;
            range.length += [para length];
            if (p == [paragraphs count] - 1) {
                //到了文章的结尾 这一页也算
                [ranges addObject:[NSValue valueWithRange:range]];
                //IMILog(@"===========Page Over=============");
            }
        } else if (totalLines+paraLines == maxLine) {
            //很幸运, 刚好一段结束,本页也结束, 有这个判断会提高一定的效率
            range.length += [para length];
            [ranges addObject:[NSValue valueWithRange:range]];
            range.location += range.length;
            range.length = 0;
            totalLines = 0;
            //IMILog(@"===========Page Over=============");
        } else {
            //重头戏, 页结束时候本段文字还有剩余
            NSInteger lineLeft = maxLine - totalLines;
            CGSize tmpSize;
            NSInteger i;
            for (i = 1; i< [para length]; i ++) {
                //逐字判断是否达到了本页最大容量
                NSString *tmp = [para substringToIndex:i];
                
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
                
                tmpSize = [tmp sizeWithFont:font constrainedToSize:r.size lineBreakMode:lineBreakMode];
                
#else
                NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                paragraph.lineBreakMode = lineBreakMode;
                NSDictionary *attributes = @{NSFontAttributeName: font,
                                             NSParagraphStyleAttributeName: paragraph};
                tmpSize = [tmp boundingRectWithSize:r.size
                                            options:(NSStringDrawingUsesLineFragmentOrigin
                                                     | NSStringDrawingTruncatesLastVisibleLine)
                                         attributes:attributes
                                            context:nil].size;
#endif
                //                tmpSize = [tmp sizeWithFont:font
                //                          constrainedToSize:r.size
                //                              lineBreakMode:lineBreakMode];
                
                int nowLine = floor(tmpSize.height / lineHeight);
                if (lineLeft < nowLine) {
                    //超出容量,跳出, 字符要回退一个, 应为当前字符已经超出范围了
                    lastParaLeft = [para substringFromIndex: i - 1];
                    break;
                }
            }
            range.length += i - 1;
            [ranges addObject:[NSValue valueWithRange:range]];
            range.location += range.length;
            range.length = 0;
            totalLines = 0;
            p--;
            //IMILog(@"===========Page Over=============");
        }
    }
    return [NSArray arrayWithArray:ranges];
}



/**
 是否可以匹配正则表达式
 
 @param regex 正则表达式
 @param options 要报告的匹配选项
 @return 返回YES,如果可以匹配正则表达式;否则NO
 */
- (BOOL)matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:NULL];
    if (!pattern) return NO;
    return ([pattern numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0);
}


/**
 匹配正则表达式,并使用匹配中的每个对象执行给定的块
 
 @param regex 正则表达式
 @param options 要报告的匹配选项
 @param block 应用于匹配数组中的元素的块
 */
- (void)enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block {
    
    /**
     回调有4个参数:
     match: 匹配子串.
     matchRange: 匹配选项.
     stop: 设置为 *stop = YES 是停止该回调.
     */
    
    if (regex.length == 0 || !block) return;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!regex) return;
    [pattern enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        block([self substringWithRange:result.range], result.range, stop);
    }];
}


/**
 返回包含匹配与模板字符串替换正则表达式的新字符串
 
 @param regex 正则表达式
 @param options 要报告的匹配选项
 @param replacement 替换匹配实例时使用的替换模板
 @return 与匹配用模板字符串替换正则表达式的字符串
 */
- (NSString *)stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                          withString:(NSString *)replacement; {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!pattern) return self;
    return [pattern stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replacement];
}

- (char)charValue {
    return self.numberValue.charValue;
}

- (unsigned char) unsignedCharValue {
    return self.numberValue.unsignedCharValue;
}

- (short) shortValue {
    return self.numberValue.shortValue;
}

- (unsigned short) unsignedShortValue {
    return self.numberValue.unsignedShortValue;
}

- (unsigned int) unsignedIntValue {
    return self.numberValue.unsignedIntValue;
}

- (long) longValue {
    return self.numberValue.longValue;
}

- (unsigned long) unsignedLongValue {
    return self.numberValue.unsignedLongValue;
}

- (unsigned long long) unsignedLongLongValue {
    return self.numberValue.unsignedLongLongValue;
}

- (NSUInteger) unsignedIntegerValue {
    return self.numberValue.unsignedIntegerValue;
}


/**
 返回 UUID NSString
 e.g. "D1178E50-2A4D-4F1F-9BD3-F6AAB00E06B1"
 */
+ (NSString *)stringWithUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}


/**
 毫秒时间戳 例如 1443066826371
 
 @return 毫秒时间戳
 */
+ (NSString *)UUIDTimestamp
{
    return  [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000] stringValue];
}

/**
 返回包含给定UTF32Char中的字符的字符串.
 
 @param char32 UTF-32字符.
 @return 一个新的字符串,如果字符无效,则为nil.
 */
+ (NSString *)stringWithUTF32Char:(UTF32Char)char32 {
    char32 = NSSwapHostIntToLittle(char32);
    return [[NSString alloc] initWithBytes:&char32 length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

/**
 返回一个包含给定UTF32Char数组中字符的字符串.
 
 @param char32 UTF-32字符的数组.
 @param length 数组中的字符数.
 @return 新的字符串,如果发生错误,则为nil.
 */
+ (NSString *)stringWithUTF32Chars:(const UTF32Char *)char32 length:(NSUInteger)length {
    return [[NSString alloc] initWithBytes:(const void *)char32
                                    length:length * 4
                                  encoding:NSUTF32LittleEndianStringEncoding];
}

/**
 枚举字符串指定范围内的unicode字符(UTF-32).
 
 @param range 用于枚举子字符串的字符串范围
 @param block 为枚举执行的块.
 */
- (void)enumerateUTF32CharInRange:(NSRange)range usingBlock:(void (^)(UTF32Char char32, NSRange range, BOOL *stop))block {
    NSString *str = self;
    if (range.location != 0 || range.length != self.length) {
        str = [self substringWithRange:range];
    }
    NSUInteger len = [str lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
    UTF32Char *char32 = (UTF32Char *)[str cStringUsingEncoding:NSUTF32LittleEndianStringEncoding];
    if (len == 0 || char32 == NULL) return;
    
    NSUInteger location = 0;
    BOOL stop = NO;
    NSRange subRange;
    UTF32Char oneChar;
    
    for (NSUInteger i = 0; i < len; i++) {
        oneChar = char32[i];
        subRange = NSMakeRange(location, oneChar > 0xFFFF ? 2 : 1);
        block(oneChar, subRange, &stop);
        if (stop) return;
        location += subRange.length;
    }
}

/**
 修剪头部和尾部的空白字符(空格和换行符)
 
 @return 处理好的字符串
 */
- (NSString *)stringByTrim {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

/**
 将缩放修饰符添加到文件名(不带拓展名),
 From @"name" to @"name@2x".
 
 e.g.
 <table>
 <tr><th>Before     </th><th>After(scale:2)</th></tr>
 <tr><td>"icon"     </td><td>"icon@2x"     </td></tr>
 <tr><td>"icon "    </td><td>"icon @2x"    </td></tr>
 <tr><td>"icon.top" </td><td>"icon.top@2x" </td></tr>
 <tr><td>"/p/name"  </td><td>"/p/name@2x"  </td></tr>
 <tr><td>"/path/"   </td><td>"/path/"      </td></tr>
 </table>
 
 @param scale 比例
 @return 通过添加比例修饰符的字符串,或者只要返回,如果它不是以文件名结尾
 */
- (NSString *)stringByAppendingNameScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    return [self stringByAppendingFormat:@"@%@x", @(scale)];
}


/**
 将缩放修饰符添加到文件路径(具有路径扩展名),
 From @"name.png" to @"name@2x.png".
 
 e.g.
 <table>
 <tr><th>Before     </th><th>After(scale:2)</th></tr>
 <tr><td>"icon.png" </td><td>"icon@2x.png" </td></tr>
 <tr><td>"icon..png"</td><td>"icon.@2x.png"</td></tr>
 <tr><td>"icon"     </td><td>"icon@2x"     </td></tr>
 <tr><td>"icon "    </td><td>"icon @2x"    </td></tr>
 <tr><td>"icon."    </td><td>"icon.@2x"    </td></tr>
 <tr><td>"/p/name"  </td><td>"/p/name@2x"  </td></tr>
 <tr><td>"/path/"   </td><td>"/path/"      </td></tr>
 </table>
 
 @param scale 比例.
 @return 字符串通过添加比例修饰符,或者只是返回,如果它不是以文件名结尾.
 */
- (NSString *)stringByAppendingPathScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    NSString *ext = self.pathExtension;
    NSRange extRange = NSMakeRange(self.length - ext.length, 0);
    if (ext.length > 0) extRange.location -= 1;
    NSString *scaleStr = [NSString stringWithFormat:@"@%@x", @(scale)];
    return [self stringByReplacingCharactersInRange:extRange withString:scaleStr];
}

/**
 返回路径比例.
 
 e.g.
 <table>
 <tr><th>Path            </th><th>Scale </th></tr>
 <tr><td>"icon.png"      </td><td>1     </td></tr>
 <tr><td>"icon@2x.png"   </td><td>2     </td></tr>
 <tr><td>"icon@2.5x.png" </td><td>2.5   </td></tr>
 <tr><td>"icon@2x"       </td><td>1     </td></tr>
 <tr><td>"icon@2x..png"  </td><td>1     </td></tr>
 <tr><td>"icon@2x.png/"  </td><td>1     </td></tr>
 </table>
 */
- (CGFloat)pathScale {
    if (self.length == 0 || [self hasSuffix:@"/"]) return 1;
    NSString *name = self.stringByDeletingPathExtension;
    __block CGFloat scale = 1;
    [name enumerateRegexMatches:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines usingBlock: ^(NSString *match, NSRange matchRange, BOOL *stop) {
        scale = [match substringWithRange:NSMakeRange(1, match.length - 2)].doubleValue;
    }];
    return scale;
}

/** 判断字符串是否非 nil,@"",@"  ",@"\n" 将返回NO;否则返回YES.*/
- (BOOL)isNotBlank {
    NSCharacterSet *blank = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![blank characterIsMember:c]) {
            return YES;
        }
    }
    return NO;
}

/**
 如果目标字符串包含在接收器中,则返回YES
 (苹果已经在iOS8中实现了这种方法)
 
 @param string 测试接收器的字符串
 @return 是否包含接收器
 */
- (BOOL)containsString:(NSString *)string {
    if (string == nil) return NO;
    return [self rangeOfString:string].location != NSNotFound;
}


/**
 是否包含字符集
 
 @param set 字符集
 @return 包含返回YES,否则NO
 */
- (BOOL)containsCharacterSet:(NSCharacterSet *)set {
    if (set == nil) return NO;
    return [self rangeOfCharacterFromSet:set].location != NSNotFound;
}

/**
 尝试解析这个字符串并返回一个'NSNumber'.
 
 @return 如果解析成功,则返回一个'NSNumber',如果发生错误,则返回nil.
 */
- (NSNumber *)numberValue {
    return [NSNumber numberWithString:self];
}

/**
 使用UTF-8编码返回NSData.
 */
- (NSData *)dataValue {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

/** 返回 NSMakeRange(0,self.length). */
- (NSRange)rangeOfAll {
    return NSMakeRange(0, self.length);
}

/**
 返回从接收器解码的 NSDictionary / NSArray. 如果发生错误,返回nil.
 
 e.g. NSString: @"{"name":"a","count":2}"  => NSDictionary: @[@"name":@"a",@"count":@2]
 */
- (id)jsonValueDecoded {
    return [[self dataValue] jsonValueDecoded];
}

/**
 从 main bundle的文件创建一个字符串(类似于[UIImage imageNamed:])
 
 @param name 文件名
 @return 以UTF-8字符编码形式从文件创建新的字符串
 */
+ (NSString *)stringNamed:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (!str) {
        path = [[NSBundle mainBundle] pathForResource:name ofType:@"txt"];
        str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    }
    return str;
}


#define IS_WHITESPACE(_c) (_c == ' ' ||\
_c == '\t'||\
_c == 0xA ||\
_c == 0xB ||\
_c == 0xC ||\
_c == 0xD ||\
_c == 0x85)

/**
 字符串规范化空格
 
 @return 处理后的字符串
 */
- (instancetype)stringNormalizingWhitespace{
    NSInteger stringLength = [self length];
    unichar* _characters = calloc(stringLength, sizeof(unichar));
    [self getCharacters:_characters range:NSMakeRange(0, stringLength)];
    NSInteger outputLength = 0;
    BOOL inWhite = NO;
    for (NSInteger i = 0; i<stringLength; i++) {
        unichar oneChar = _characters[i];
        if (IS_WHITESPACE(oneChar)) {
            if (!inWhite) {
                _characters[outputLength] = 32;
                outputLength++;
                inWhite = YES;
            }
        } else {
            _characters[outputLength] = oneChar;
            outputLength++;
            inWhite = NO;
        }
    }
    NSString* retString = [NSString stringWithCharacters:_characters length:outputLength];
    free(_characters);
    return retString;
}

/** 获取字符数量 */
- (int)wordsCount
{
    NSInteger n = self.length;
    int i;
    int l = 0, a = 0, b = 0;
    unichar c;
    for (i = 0; i < n; i++)
    {
        c = [self characterAtIndex:i];
        if (isblank(c)) {
            b++;
        } else if (isascii(c)) {
            a++;
        } else {
            l++;
        }
    }
    if (a == 0 && l == 0) {
        return 0;
    }
    return l + (int)ceilf((float)(a + b) / 2.0);
}


/**
 反序字符串
 
 @param strSrc 需要反转的字符串
 @return 反转后的字符串
 */
+ (NSString *)reverseString:(NSString *)strSrc
{
    NSMutableString* reverseString = [[NSMutableString alloc] init];
    NSInteger charIndex = [strSrc length];
    while (charIndex > 0) {
        charIndex --;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reverseString appendString:[strSrc substringWithRange:subStrRange]];
    }
    return reverseString;
}





/**
 清除html标签
 
 @return 清除后的结果
 */
- (NSString *)stringByStrippingHTML {
    return [self stringByReplacingOccurrencesOfString:@"<[^>]+>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}


/**
 清除js脚本
 
 @return 清除js后的结果
 */
- (NSString *)stringByRemovingScriptsAndStrippingHTML {
    NSMutableString *mString = [self mutableCopy];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*>[\\w\\W]*</script>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:mString options:NSMatchingReportProgress range:NSMakeRange(0, [mString length])];
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        [mString replaceCharactersInRange:match.range withString:@""];
    }
    return [mString stringByStrippingHTML];
}



/**
 去除空格
 
 @return 去除空格后的字符串
 */
- (NSString *)trimmingWhitespace{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


/**
 去除字符串与空行
 
 @return 去除字符串与空行的字符串
 */
- (NSString *)trimmingWhitespaceAndNewlines{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


/**
 过滤非法字符
 
 @param string 原字符串
 @param target 过滤关键字 []{}（#%-*+=_）\\|~(＜＞$%^&*)_+
 @return 过滤后的字符串
 */
+(NSString *)filterString:(NSString *)string target:(NSString *)target{
    NSString *tempString = string;
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:target];
    tempString = [[tempString componentsSeparatedByCharactersInSet: doNotWant]componentsJoinedByString:@""];
    return tempString;
}

/**
 过滤非法字符
 
 @param target 过滤关键字 []{}（#%-*+=_）\\|~(＜＞$%^&*)_+
 @return 过滤后的字符串
 */
-(NSString *)filter:(NSString *)target{
    return [NSString filterString:self target:target];
}



- (CGFloat)scoreAgainst:(NSString *)otherString{
    return [self scoreAgainst:otherString fuzziness:nil];
}

- (CGFloat)scoreAgainst:(NSString *)otherString fuzziness:(nullable NSNumber *)fuzziness{
    return [self scoreAgainst:otherString fuzziness:fuzziness options:NSStringScoreOptionNone];
}

- (CGFloat)scoreAgainst:(NSString *)anotherString fuzziness:(nullable NSNumber *)fuzziness options:(NSStringScoreOption)options{
    NSMutableCharacterSet *workingInvalidCharacterSet = [NSMutableCharacterSet lowercaseLetterCharacterSet];
    [workingInvalidCharacterSet formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    [workingInvalidCharacterSet addCharactersInString:@" "];
    NSCharacterSet *invalidCharacterSet = [workingInvalidCharacterSet invertedSet];
    
    NSString *string = [[[self decomposedStringWithCanonicalMapping] componentsSeparatedByCharactersInSet:invalidCharacterSet] componentsJoinedByString:@""];
    NSString *otherString = [[[anotherString decomposedStringWithCanonicalMapping] componentsSeparatedByCharactersInSet:invalidCharacterSet] componentsJoinedByString:@""];
    
    // 如果字符串等于缩写,则完美匹配.
    if([string isEqualToString:otherString]) return (CGFloat) 1.0f;
    
    //if it's not a perfect match and is empty return 0
    if([otherString length] == 0) return (CGFloat) 0.0f;
    
    CGFloat totalCharacterScore = 0;
    NSUInteger otherStringLength = [otherString length];
    NSUInteger stringLength = [string length];
    BOOL startOfStringBonus = NO;
    CGFloat otherStringScore;
    CGFloat fuzzies = 1;
    CGFloat finalScore;
    
    // 如果它不是一个完美的匹配,并且是空的返回0.
    for(uint index = 0; index < otherStringLength; index++){
        CGFloat characterScore = 0.1;
        NSInteger indexInString = NSNotFound;
        NSString *chr;
        NSRange rangeChrLowercase;
        NSRange rangeChrUppercase;
        
        chr = [otherString substringWithRange:NSMakeRange(index, 1)];
        
        //使这些接下来的几条线利用NSNotfound,methinks.
        rangeChrLowercase = [string rangeOfString:[chr lowercaseString]];
        rangeChrUppercase = [string rangeOfString:[chr uppercaseString]];
        
        if(rangeChrLowercase.location == NSNotFound && rangeChrUppercase.location == NSNotFound){
            if(fuzziness){
                fuzzies += 1 - [fuzziness floatValue];
            } else {
                return 0; // 这是一个错误!
            }
            
        } else if (rangeChrLowercase.location != NSNotFound && rangeChrUppercase.location != NSNotFound){
            indexInString = MIN(rangeChrLowercase.location, rangeChrUppercase.location);
            
        } else if(rangeChrLowercase.location != NSNotFound || rangeChrUppercase.location != NSNotFound){
            indexInString = rangeChrLowercase.location != NSNotFound ? rangeChrLowercase.location : rangeChrUppercase.location;
            
        } else {
            indexInString = MIN(rangeChrLowercase.location, rangeChrUppercase.location);
            
        }
        
        // 设置匹配chr的基本分数
        
        // 相同案例 bonus.
        if(indexInString != NSNotFound && [[string substringWithRange:NSMakeRange(indexInString, 1)] isEqualToString:chr]){
            characterScore += 0.1;
        }
        
        // 连续字母和字符串 bonus
        if(indexInString == 0){
            // 当匹配字符串的其余部分的第一个字符时,增加分数
            characterScore += 0.6;
            if(index == 0){
                // 如果匹配是字符串的第一个字符和缩写的第一个字符,则添加一个起始字符串匹配加成.
                startOfStringBonus = YES;
            }
        } else if(indexInString != NSNotFound) {
            // 首字母缩略词Bonus
            // 衡量逻辑:键入首字母缩略词的第一个字符就好像在两个完美的字符匹配之前.
            if( [[string substringWithRange:NSMakeRange(indexInString - 1, 1)] isEqualToString:@" "] ){
                characterScore += 0.8;
            }
        }
        
        // 左修剪字符串已经匹配的部分(强制顺序匹配).
        if(indexInString != NSNotFound){
            string = [string substringFromIndex:indexInString + 1];
        }
        
        totalCharacterScore += characterScore;
    }
    
    if(NSStringScoreOptionFavorSmallerWords == (options & NSStringScoreOptionFavorSmallerWords)){
        // 衡量较小的话返回值更高
        return totalCharacterScore / stringLength;
    }
    
    otherStringScore = totalCharacterScore / otherStringLength;
    
    if(NSStringScoreOptionReducedLongStringPenalty == (options & NSStringScoreOptionReducedLongStringPenalty)){
        // Reduce the penalty for longer words
        CGFloat percentageOfMatchedString = otherStringLength / stringLength;
        CGFloat wordScore = otherStringScore * percentageOfMatchedString;
        finalScore = (wordScore + otherStringScore) / 2;
        
    } else {
        finalScore = ((otherStringScore * ((CGFloat)(otherStringLength) / (CGFloat)(stringLength))) + otherStringScore) / 2;
    }
    
    finalScore = finalScore / fuzzies;
    
    if(startOfStringBonus && finalScore + 0.15 < 1){
        finalScore += 0.15;
    }
    
    return finalScore;
}




/**
 根据文件URL后缀 返回对应的MIMEType
 
 @return MIMEType
 */
- (NSString *)MIMEType{
    return [[self class] MIMETypeForExtension:[self pathExtension]];
}

+ (NSString *)MIMETypeForExtension:(NSString *)extension {
    return [[self MIMEDict] valueForKey:[extension lowercaseString]];
}



/**
 获取常见MIME集合
 
 @return 常见MIME集合
 */
+ (NSDictionary *)MIMEDict {
    NSDictionary * MIMEDict;
    // 懒加载MIME类型的字典.
    if (!MIMEDict) {
        
        // ???: 我应该有这些返回的MIME类型的数组？第一元件将是优选的MIME类型.
        
        // ???: 我应该有几种方法返回MIME媒体类型名称和MIME子类型名称?
        
        // 以下返回值来自 http://www.w3schools.com/media/media_mimeref.asp
        // 可能有遗漏值,但已经比较全面.还有几个被添加到原始列表中并未包含.
        MIMEDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    // Key      // Value
                    @"",        @"application/octet-stream",
                    @"323",     @"text/h323",
                    @"acx",     @"application/internet-property-stream",
                    @"ai",      @"application/postscript",
                    @"aif",     @"audio/x-aiff",
                    @"aifc",    @"audio/x-aiff",
                    @"aiff",    @"audio/x-aiff",
                    @"asf",     @"video/x-ms-asf",
                    @"asr",     @"video/x-ms-asf",
                    @"asx",     @"video/x-ms-asf",
                    @"au",      @"audio/basic",
                    @"avi",     @"video/x-msvideo",
                    @"axs",     @"application/olescript",
                    @"bas",     @"text/plain",
                    @"bcpio",   @"application/x-bcpio",
                    @"bin",     @"application/octet-stream",
                    @"bmp",     @"image/bmp",
                    @"c",       @"text/plain",
                    @"cat",     @"application/vnd.ms-pkiseccat",
                    @"cdf",     @"application/x-cdf",
                    @"cer",     @"application/x-x509-ca-cert",
                    @"class",   @"application/octet-stream",
                    @"clp",     @"application/x-msclip",
                    @"cmx",     @"image/x-cmx",
                    @"cod",     @"image/cis-cod",
                    @"cpio",    @"application/x-cpio",
                    @"crd",     @"application/x-mscardfile",
                    @"crl",     @"application/pkix-crl",
                    @"crt",     @"application/x-x509-ca-cert",
                    @"csh",     @"application/x-csh",
                    @"css",     @"text/css",
                    @"dcr",     @"application/x-director",
                    @"der",     @"application/x-x509-ca-cert",
                    @"dir",     @"application/x-director",
                    @"dll",     @"application/x-msdownload",
                    @"dms",     @"application/octet-stream",
                    @"doc",     @"application/msword",
                    @"docx",    @"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                    @"dot",     @"application/msword",
                    @"dvi",     @"application/x-dvi",
                    @"dxr",     @"application/x-director",
                    @"eps",     @"application/postscript",
                    @"etx",     @"text/x-setext",
                    @"evy",     @"application/envoy",
                    @"exe",     @"application/octet-stream",
                    @"fif",     @"application/fractals",
                    @"flr",     @"x-world/x-vrml",
                    @"gif",     @"image/gif",
                    @"gtar",    @"application/x-gtar",
                    @"gz",      @"application/x-gzip",
                    @"h",       @"text/plain",
                    @"hdf",     @"application/x-hdf",
                    @"hlp",     @"application/winhlp",
                    @"hqx",     @"application/mac-binhex40",
                    @"hta",     @"application/hta",
                    @"htc",     @"text/x-component",
                    @"htm",     @"text/html",
                    @"html",    @"text/html",
                    @"htt",     @"text/webviewhtml",
                    @"ico",     @"image/x-icon",
                    @"ief",     @"image/ief",
                    @"iii",     @"application/x-iphone",
                    @"ins",     @"application/x-internet-signup",
                    @"isp",     @"application/x-internet-signup",
                    @"jfif",    @"image/pipeg",
                    @"jpe",     @"image/jpeg",
                    @"jpeg",    @"image/jpeg",
                    @"jpg",     @"image/jpeg",
                    @"js",      @"application/x-javascript",
                    // 根据 RFC 4627
                    // Also application/x-javascript text/javascript text/x-javascript text/x-json
                    @"json",    @"application/json",
                    @"latex",   @"application/x-latex",
                    @"lha",     @"application/octet-stream",
                    @"lsf",     @"video/x-la-asf",
                    @"lsx",     @"video/x-la-asf",
                    @"lzh",     @"application/octet-stream",
                    @"m",       @"text/plain",
                    @"m13",     @"application/x-msmediaview",
                    @"m14",     @"application/x-msmediaview",
                    @"m3u",     @"audio/x-mpegurl",
                    @"man",     @"application/x-troff-man",
                    @"mdb",     @"application/x-msaccess",
                    @"me",      @"application/x-troff-me",
                    @"mht",     @"message/rfc822",
                    @"mhtml",   @"message/rfc822",
                    @"mid",     @"audio/mid",
                    @"mny",     @"application/x-msmoney",
                    @"mov",     @"video/quicktime",
                    @"movie",   @"video/x-sgi-movie",
                    @"mp2",     @"video/mpeg",
                    @"mp3",     @"audio/mpeg",
                    @"mpa",     @"video/mpeg",
                    @"mpe",     @"video/mpeg",
                    @"mpeg",    @"video/mpeg",
                    @"mpg",     @"video/mpeg",
                    @"mpp",     @"application/vnd.ms-project",
                    @"mpv2",    @"video/mpeg",
                    @"ms",      @"application/x-troff-ms",
                    @"mvb",     @"	application/x-msmediaview",
                    @"nws",     @"message/rfc822",
                    @"oda",     @"application/oda",
                    @"p10",     @"application/pkcs10",
                    @"p12",     @"application/x-pkcs12",
                    @"p7b",     @"application/x-pkcs7-certificates",
                    @"p7c",     @"application/x-pkcs7-mime",
                    @"p7m",     @"application/x-pkcs7-mime",
                    @"p7r",     @"application/x-pkcs7-certreqresp",
                    @"p7s",     @"	application/x-pkcs7-signature",
                    @"pbm",     @"image/x-portable-bitmap",
                    @"pdf",     @"application/pdf",
                    @"pfx",     @"application/x-pkcs12",
                    @"pgm",     @"image/x-portable-graymap",
                    @"pko",     @"application/ynd.ms-pkipko",
                    @"pma",     @"application/x-perfmon",
                    @"pmc",     @"application/x-perfmon",
                    @"pml",     @"application/x-perfmon",
                    @"pmr",     @"application/x-perfmon",
                    @"pmw",     @"application/x-perfmon",
                    @"png",     @"image/png",
                    @"pnm",     @"image/x-portable-anymap",
                    @"pot",     @"application/vnd.ms-powerpoint",
                    @"vppm",    @"image/x-portable-pixmap",
                    @"pps",     @"application/vnd.ms-powerpoint",
                    @"ppt",     @"application/vnd.ms-powerpoint",
                    @"pptx",    @"application/vnd.openxmlformats-officedocument.presentationml.presentation",
                    @"prf",     @"application/pics-rules",
                    @"ps",      @"application/postscript",
                    @"pub",     @"application/x-mspublisher",
                    @"qt",      @"video/quicktime",
                    @"ra",      @"audio/x-pn-realaudio",
                    @"ram",     @"audio/x-pn-realaudio",
                    @"ras",     @"image/x-cmu-raster",
                    @"rgb",     @"image/x-rgb",
                    @"rmi",     @"audio/mid",
                    @"roff",    @"application/x-troff",
                    @"rtf",     @"application/rtf",
                    @"rtx",     @"text/richtext",
                    @"scd",     @"application/x-msschedule",
                    @"sct",     @"text/scriptlet",
                    @"setpay",  @"application/set-payment-initiation",
                    @"setreg",  @"application/set-registration-initiation",
                    @"sh",      @"application/x-sh",
                    @"shar",    @"application/x-shar",
                    @"sit",     @"application/x-stuffit",
                    @"snd",     @"audio/basic",
                    @"spc",     @"application/x-pkcs7-certificates",
                    @"spl",     @"application/futuresplash",
                    @"src",     @"application/x-wais-source",
                    @"sst",     @"application/vnd.ms-pkicertstore",
                    @"stl",     @"application/vnd.ms-pkistl",
                    @"stm",     @"text/html",
                    @"svg",     @"image/svg+xml",
                    @"sv4cpio", @"application/x-sv4cpio",
                    @"sv4crc",  @"application/x-sv4crc",
                    @"swf",     @"application/x-shockwave-flash",
                    @"t",       @"application/x-troff",
                    @"tar",     @"application/x-tar",
                    @"tcl",     @"application/x-tcl",
                    @"tex",     @"application/x-tex",
                    @"texi",    @"application/x-texinfo",
                    @"texinfo", @"application/x-texinfo",
                    @"tgz",     @"application/x-compressed",
                    @"tif",     @"image/tiff",
                    @"tiff",    @"image/tiff",
                    @"tr",      @"application/x-troff",
                    @"trm",     @"application/x-msterminal",
                    @"tsv",     @"text/tab-separated-values",
                    @"txt",     @"text/plain",
                    @"uls",     @"text/iuls",
                    @"ustar",   @"application/x-ustar",
                    @"vcf",     @"text/x-vcard",
                    @"vrml",    @"x-world/x-vrml",
                    @"wav",     @"audio/x-wav",
                    @"wcm",     @"application/vnd.ms-works",
                    @"wdb",     @"application/vnd.ms-works",
                    @"wks",     @"application/vnd.ms-works",
                    @"wmf",     @"application/x-msmetafile",
                    @"wps",     @"application/vnd.ms-works",
                    @"wri",     @"application/x-mswrite",
                    @"wrl",     @"x-world/x-vrml",
                    @"wrz",     @"x-world/x-vrml",
                    @"xaf",     @"x-world/x-vrml",
                    @"xbm",     @"image/x-xbitmap",
                    @"xla",     @"application/vnd.ms-excel",
                    @"xlc",     @"application/vnd.ms-excel",
                    @"xlm",     @"application/vnd.ms-excel",
                    @"xls",     @"application/vnd.ms-excel",
                    @"xlsx",    @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    @"xlt",     @"application/vnd.ms-excel",
                    @"xlw",     @"application/vnd.ms-excel",
                    @"xml",     @"text/xml",   // 根据 RFC 3023   // Also application/xml
                    @"xof",     @"x-world/x-vrml",
                    @"xpm",     @"image/x-xpixmap",
                    @"xwd",     @"image/x-xwindowdump",
                    @"z",       @"application/x-compress",
                    @"zip",     @"application/zip",
                    nil];
    }
    
    return MIMEDict;
}






@end




