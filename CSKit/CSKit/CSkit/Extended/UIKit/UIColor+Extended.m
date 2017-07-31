//
//  UIColor+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIColor+Extended.h"
#import "NSString+Extended.h"
#import "CSKitMacro.h"

CSSYNTH_DUMMY_CLASS(UIColor_Extended)

@implementation UIColor (Extended)

+ (UIColor *)colorWithHue:(CGFloat)hue
               saturation:(CGFloat)saturation
                lightness:(CGFloat)lightness
                    alpha:(CGFloat)alpha {
    CGFloat r, g, b;
    CS_HSL2RGB(hue, saturation, lightness, &r, &g, &b);
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}
+ (UIColor *)colorWithCyan:(CGFloat)cyan
                   magenta:(CGFloat)magenta
                    yellow:(CGFloat)yellow
                     black:(CGFloat)black
                     alpha:(CGFloat)alpha {
    CGFloat r, g, b;
    CS_CMYK2RGB(cyan, magenta, yellow, black, &r, &g, &b);
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

+ (UIColor *)colorWithRGB:(uint32_t)rgbValue {
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0f
                           green:((rgbValue & 0xFF00) >> 8) / 255.0f
                            blue:(rgbValue & 0xFF) / 255.0f
                           alpha:1];
}

+ (UIColor *)colorWithRGBA:(uint32_t)rgbaValue {
    return [UIColor colorWithRed:((rgbaValue & 0xFF000000) >> 24) / 255.0f
                           green:((rgbaValue & 0xFF0000) >> 16) / 255.0f
                            blue:((rgbaValue & 0xFF00) >> 8) / 255.0f
                           alpha:(rgbaValue & 0xFF) / 255.0f];
}

+ (UIColor *)colorWithRGB:(uint32_t)rgbValue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0f
                           green:((rgbValue & 0xFF00) >> 8) / 255.0f
                            blue:(rgbValue & 0xFF) / 255.0f
                           alpha:alpha];
}

- (uint32_t)rgbValue {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    [self getRed:&r green:&g blue:&b alpha:&a];
    int8_t red = r * 255;
    uint8_t green = g * 255;
    uint8_t blue = b * 255;
    return (red << 16) + (green << 8) + blue;
}

- (uint32_t)rgbaValue {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    [self getRed:&r green:&g blue:&b alpha:&a];
    int8_t red = r * 255;
    uint8_t green = g * 255;
    uint8_t blue = b * 255;
    uint8_t alpha = a * 255;
    return (red << 24) + (green << 16) + (blue << 8) + alpha;
}

static inline NSUInteger hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL hexStrToRGBA(NSString *str,
                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    str = [[str stringByTrim] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    //         RGB            RGBA          RRGGBB        RRGGBBAA
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    //RGB,RGBA,RRGGBB,RRGGBBAA
    if (length < 5) {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}

+ (instancetype)colorWithHexString:(NSString *)hexStr {
    CGFloat r, g, b, a;
    if (hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

- (NSString *)hexString {
    return [self hexStringWithAlpha:NO];
}

- (NSString *)hexStringWithAlpha {
    return [self hexStringWithAlpha:YES];
}

- (NSString *)hexStringWithAlpha:(BOOL)withAlpha {
    CGColorRef color = self.CGColor;
    size_t count = CGColorGetNumberOfComponents(color);
    const CGFloat *components = CGColorGetComponents(color);
    static NSString *stringFormat = @"%02x%02x%02x";
    NSString *hex = nil;
    if (count == 2) {
        NSUInteger white = (NSUInteger)(components[0] * 255.0f);
        hex = [NSString stringWithFormat:stringFormat, white, white, white];
    } else if (count == 4) {
        hex = [NSString stringWithFormat:stringFormat,
               (NSUInteger)(components[0] * 255.0f),
               (NSUInteger)(components[1] * 255.0f),
               (NSUInteger)(components[2] * 255.0f)];
    }
    
    if (hex && withAlpha) {
        hex = [hex stringByAppendingFormat:@"%02lx",
               (unsigned long)(self.alpha * 255.0 + 0.5)];
    }
    return hex;
}

- (UIColor *)colorByAddColor:(UIColor *)add blendMode:(CGBlendMode)blendMode {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    uint8_t pixel[4] = { 0 };
    CGContextRef context = CGBitmapContextCreate(&pixel, 1, 1, 8, 4, colorSpace, bitmapInfo);
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextSetBlendMode(context, blendMode);
    CGContextSetFillColorWithColor(context, add.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIColor colorWithRed:pixel[0] / 255.0f green:pixel[1] / 255.0f blue:pixel[2] / 255.0f alpha:pixel[3] / 255.0f];
}

- (UIColor *)colorByChangeHue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)b alpha:(CGFloat)a {
    CGFloat hh, ss, bb, aa;
    if (![self getHue:&hh saturation:&ss brightness:&bb alpha:&aa]) {
        return self;
    }
    hh += h;
    ss += s;
    bb += b;
    aa += a;
    hh -= (int)hh;
    hh = hh < 0 ? hh + 1 : hh;
    ss = ss < 0 ? 0 : ss > 1 ? 1 : ss;
    bb = bb < 0 ? 0 : bb > 1 ? 1 : bb;
    aa = aa < 0 ? 0 : aa > 1 ? 1 : aa;
    return [UIColor colorWithHue:hh saturation:ss brightness:bb alpha:aa];
}

- (BOOL)getHue:(CGFloat *)hue
    saturation:(CGFloat *)saturation
     lightness:(CGFloat *)lightness
         alpha:(CGFloat *)alpha {
    CGFloat r, g, b, a;
    if (![self getRed:&r green:&g blue:&b alpha:&a]) {
        return NO;
    }
    CS_RGB2HSL(r, g, b, hue, saturation, lightness);
    *alpha = a;
    return YES;
}

- (BOOL)getCyan:(CGFloat *)cyan
        magenta:(CGFloat *)magenta
         yellow:(CGFloat *)yellow
          black:(CGFloat *)black
          alpha:(CGFloat *)alpha {
    CGFloat r, g, b, a;
    if (![self getRed:&r green:&g blue:&b alpha:&a]) {
        return NO;
    }
    CS_RGB2CMYK(r, g, b, cyan, magenta, yellow, black);
    *alpha = a;
    return YES;
}

- (CGFloat)red {
    CGFloat r = 0, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return r;
}

- (CGFloat)green {
    CGFloat r, g = 0, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return g;
}

- (CGFloat)blue {
    CGFloat r, g, b = 0, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return b;
}

- (CGFloat)alpha {
    return CGColorGetAlpha(self.CGColor);
}

- (CGFloat)hue {
    CGFloat h = 0, s, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return h;
}

- (CGFloat)saturation {
    CGFloat h, s = 0, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return s;
}

- (CGFloat)brightness {
    CGFloat h, s, b = 0, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return b;
}

- (CGColorSpaceModel)colorSpaceModel {
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (NSString *)colorSpaceString {
    CGColorSpaceModel model =  CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    switch (model) {
        case kCGColorSpaceModelUnknown:
            return @"kCGColorSpaceModelUnknown";
            
        case kCGColorSpaceModelMonochrome:
            return @"kCGColorSpaceModelMonochrome";
            
        case kCGColorSpaceModelRGB:
            return @"kCGColorSpaceModelRGB";
            
        case kCGColorSpaceModelCMYK:
            return @"kCGColorSpaceModelCMYK";
            
        case kCGColorSpaceModelLab:
            return @"kCGColorSpaceModelLab";
            
        case kCGColorSpaceModelDeviceN:
            return @"kCGColorSpaceModelDeviceN";
            
        case kCGColorSpaceModelIndexed:
            return @"kCGColorSpaceModelIndexed";
            
        case kCGColorSpaceModelPattern:
            return @"kCGColorSpaceModelPattern";
            
        default:
            return @"ColorSpaceInvalid";
    }
}




///MARK:=============================================================================
///MARK:WEB颜色
///MARK:=============================================================================
/** 获取canvas用的颜色字符串 */
- (NSString *)canvasColorString
{
    CGFloat *arrRGBA = [self getRGB];
    int r = arrRGBA[0] * 255;
    int g = arrRGBA[1] * 255;
    int b = arrRGBA[2] * 255;
    float a = arrRGBA[3];
    return [NSString stringWithFormat:@"rgba(%d,%d,%d,%f)", r, g, b, a];
}

/** 获取网页颜色字串 */
- (NSString *)webColorString
{
    CGFloat *arrRGBA = [self getRGB];
    int r = arrRGBA[0] * 255;
    int g = arrRGBA[1] * 255;
    int b = arrRGBA[2] * 255;
    NSLog(@"%d,%d,%d", r, g, b);
    NSString *webColor = [NSString stringWithFormat:@"#%02X%02X%02X", r, g, b];
    return webColor;
}

- (CGFloat *) getRGB{
    UIColor * uiColor = self;
    CGColorRef cgColor = [uiColor CGColor];
    int numComponents = (int)CGColorGetNumberOfComponents(cgColor);
    if (numComponents == 4){
        static CGFloat * components = Nil;
        components = (CGFloat *) CGColorGetComponents(cgColor);
        return (CGFloat *)components;
    } else { //否则默认返回黑色
        static CGFloat components[4] = {0};
        CGFloat f = 0;
        //非RGB空间的系统颜色单独处理
        if ([uiColor isEqual:[UIColor whiteColor]]) {
            f = 1.0;
        } else if ([uiColor isEqual:[UIColor lightGrayColor]]) {
            f = 0.8;
        } else if ([uiColor isEqual:[UIColor grayColor]]) {
            f = 0.5;
        }
        components[0] = f;
        components[1] = f;
        components[2] = f;
        components[3] = 1.0;
        return (CGFloat *)components;
    }
}






///MARK:=============================================================================
///MARK:常用颜色
///MARK:=============================================================================
+ (instancetype)mainColor{
    return [self colorWithRGB:0x3B7EE7];
}
+ (instancetype)backColor{
    return [UIColor colorWithRGB:0xF0F1F2];
}
+ (instancetype)backColor2{
    return [UIColor colorWithRGB:0xEBEBEB];
}

+ (instancetype)FontColor1{
    return [UIColor colorWithRGB:0x4A4A4A];
}
+ (instancetype)FontColor2{
    return [UIColor colorWithRGB:0x646464];
}
+ (instancetype)FontColor3{
    return [UIColor colorWithRGB:0x9B9B9B];
}
+ (instancetype)FontColor4{
    return [UIColor colorWithRGB:0xC5CAD1];
}


+ (UIColor*)gradientFromColor:(UIColor*)aColor toColor:(UIColor*)bColor withHeight:(int)height{
    CGSize size = CGSizeMake(1, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    NSArray* colors = [NSArray arrayWithObjects:(id)aColor.CGColor, (id)bColor.CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)colors, NULL);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
    
    return [UIColor colorWithPatternImage:image];
}


#pragma mark - **************** 红色系
/** 薄雾玫瑰*/
+ (instancetype)mistyRose
{
    return [UIColor colorWithRGB:0xFFE4E1];
}
/** 浅鲑鱼色*/
+ (instancetype)lightSalmon
{
    return [UIColor colorWithRGB:0xFFA07A];
}
/** 淡珊瑚色*/
+ (instancetype)lightCoral
{
    return [UIColor colorWithRGB:0xF08080];
}
/** 鲑鱼色*/
+ (instancetype)salmonColor
{
    return [UIColor colorWithRGB:0xFA8072];
}
/** 珊瑚色*/
+ (instancetype)coralColor
{
    return [UIColor colorWithRGB:0xFF7F50];
}
/** 番茄*/
+ (instancetype)tomatoColor
{
    return [UIColor colorWithRGB:0xFF6347];
}
/** 橙红色*/
+ (instancetype)orangeRed
{
    return [UIColor colorWithRGB:0xFF4500];
}
/** 印度红*/
+ (instancetype)indianRed
{
    return [UIColor colorWithRGB:0xCD5C5C];
}
/** 猩红*/
+ (instancetype)crimsonColor
{
    return [UIColor colorWithRGB:0xDC143C];
}
/** 耐火砖*/
+ (instancetype)fireBrick
{
    return [UIColor colorWithRGB:0xB22222];
}


#pragma mark - **************** 黄色系
/** 玉米色*/
+ (instancetype)cornColor
{
    return [UIColor colorWithRGB:0xFFF8DC];
}
/** 柠檬薄纱*/
+ (instancetype)LemonChiffon
{
    return [UIColor colorWithRGB:0xFFFACD];
}
/** 苍金麒麟*/
+ (instancetype)paleGodenrod
{
    return [UIColor colorWithRGB:0xEEE8AA];
}
/** 卡其色*/
+ (instancetype)khakiColor
{
    return [UIColor colorWithRGB:0xF0E68C];
}
/** 金色*/
+ (instancetype)goldColor
{
    return [UIColor colorWithRGB:0xFFD700];
}
/** 雌黄*/
+ (instancetype)orpimentColor
{
    return [UIColor colorWithRGB:0xFFC64B];
}
/** 藤黄*/
+ (instancetype)gambogeColor
{
    return [UIColor colorWithRGB:0xFFB61E];
}
/** 雄黄*/
+ (instancetype)realgarColor
{
    return [UIColor colorWithRGB:0xE9BB1D];
}
/** 金麒麟色*/
+ (instancetype)goldenrod
{
    return [UIColor colorWithRGB:0xDAA520];
}
/** 乌金*/
+ (instancetype)darkGold
{
    return [UIColor colorWithRGB:0xA78E44];
}


#pragma mark - **************** 绿色系
/** 苍绿*/
+ (instancetype)paleGreen
{
    return [UIColor colorWithRGB:0x98FB98];
}
/** 淡绿色*/
+ (instancetype)lightGreen
{
    return [UIColor colorWithRGB:0x90EE90];
}
/** 春绿*/
+ (instancetype)springGreen
{
    return [UIColor colorWithRGB:0x2AFD84];
}
/** 绿黄色*/
+ (instancetype)greenYellow
{
    return [UIColor colorWithRGB:0xADFF2F];
}
/** 草坪绿*/
+ (instancetype)lawnGreen
{
    return [UIColor colorWithRGB:0x7CFC00];
}
/** 酸橙绿*/
+ (instancetype)limeColor
{
    return [UIColor colorWithRGB:0x00FF00];
}
/** 森林绿*/
+ (instancetype)forestGreen
{
    return [UIColor colorWithRGB:0x228B22];
}
/** 海洋绿*/
+ (instancetype)seaGreen
{
    return [UIColor colorWithRGB:0x2E8B57];
}
/** 深绿*/
+ (instancetype)darkGreen
{
    return [UIColor colorWithRGB:0x006400];
}
/** 橄榄(墨绿)*/
+ (instancetype)olive
{
    return [UIColor colorWithRGB:0x556B2F];
}


#pragma mark - **************** 青色系
/** 淡青色*/
+ (instancetype)lightCyan
{
    return [UIColor colorWithRGB:0xE1FFFF];
}
/** 苍白绿松石*/
+ (instancetype)paleTurquoise
{
    return [UIColor colorWithRGB:0xAFEEEE];
}
/** 绿碧*/
+ (instancetype)aquamarine
{
    return [UIColor colorWithRGB:0x7FFFD4];
}
/** 绿松石*/
+ (instancetype)turquoise
{
    return [UIColor colorWithRGB:0x40E0D0];
}
/** 适中绿松石*/
+ (instancetype)mediumTurquoise
{
    return [UIColor colorWithRGB:0x48D1CC];
}
/** 美团色*/
+ (instancetype)meituanColor
{
    return [UIColor colorWithRGB:0x2BB8AA];
}
/** 浅海洋绿*/
+ (instancetype)lightSeaGreen
{
    return [UIColor colorWithRGB:0x20B2AA];
}
/** 深青色*/
+ (instancetype)darkCyan
{
    return [UIColor colorWithRGB:0x008B8B];
}
/** 水鸭色*/
+ (instancetype)tealColor
{
    return [UIColor colorWithRGB:0x008080];
}
/** 深石板灰*/
+ (instancetype)darkSlateGray
{
    return [UIColor colorWithRGB:0x2F4F4F];
}


#pragma mark - **************** 蓝色系
/** 天蓝色*/
+ (instancetype)skyBlue
{
    return [UIColor colorWithRGB:0xE1FFFF];
}
/** 淡蓝*/
+ (instancetype)lightBLue
{
    return [UIColor colorWithRGB:0xADD8E6];
}
/** 深天蓝*/
+ (instancetype)deepSkyBlue
{
    return [UIColor colorWithRGB:0x00BFFF];
}
/** 道奇蓝*/
+ (instancetype)doderBlue
{
    return [UIColor colorWithRGB:0x1E90FF];
}
/** 矢车菊*/
+ (instancetype)cornflowerBlue
{
    return [UIColor colorWithRGB:0x6495ED];
}
/** 皇家蓝*/
+ (instancetype)royalBlue
{
    return [UIColor colorWithRGB:0x4169E1];
}
/** 适中的蓝色*/
+ (instancetype)mediumBlue
{
    return [UIColor colorWithRGB:0x0000CD];
}
/** 深蓝*/
+ (instancetype)darkBlue
{
    return [UIColor colorWithRGB:0x00008B];
}
/** 海军蓝*/
+ (instancetype)navyColor
{
    return [UIColor colorWithRGB:0x000080];
}
/** 午夜蓝*/
+ (instancetype)midnightBlue
{
    return [UIColor colorWithRGB:0x191970];
}


#pragma mark - **************** 紫色系
/** 薰衣草*/
+ (instancetype)lavender
{
    return [UIColor colorWithRGB:0xE6E6FA];
}
/** 蓟*/
+ (instancetype)thistleColor
{
    return [UIColor colorWithRGB:0xD8BFD8];
}
/** 李子*/
+ (instancetype)plumColor
{
    return [UIColor colorWithRGB:0xDDA0DD];
}
/** 紫罗兰*/
+ (instancetype)violetColor
{
    return [UIColor colorWithRGB:0xEE82EE];
}
/** 适中的兰花紫*/
+ (instancetype)mediumOrchid
{
    return [UIColor colorWithRGB:0xBA55D3];
}
/** 深兰花紫*/
+ (instancetype)darkOrchid
{
    return [UIColor colorWithRGB:0x9932CC];
}
/** 深紫罗兰色*/
+ (instancetype)darkVoilet
{
    return [UIColor colorWithRGB:0x9400D3];
}
/** 泛蓝紫罗兰*/
+ (instancetype)blueViolet
{
    return [UIColor colorWithRGB:0x8A2BE2];
}
/** 深洋红色*/
+ (instancetype)darkMagenta
{
    return [UIColor colorWithRGB:0x8B008B];
}
/** 靛青*/
+ (instancetype)indigoColor
{
    return [UIColor colorWithRGB:0x4B0082];
}


#pragma mark - **************** 灰色系
/** 白烟*/
+ (instancetype)whiteSmoke
{
    return [UIColor colorWithRGB:0xF5F5F5];
}
/** 鸭蛋*/
+ (instancetype)duckEgg
{
    return [UIColor colorWithRGB:0xE0EEE8];
}
/** 亮灰*/
+ (instancetype)gainsboroColor
{
    return [UIColor colorWithRGB:0xDCDCDC];
}
/** 蟹壳青*/
+ (instancetype)carapaceColor
{
    return [UIColor colorWithRGB:0xBBCDC5];
}
/** 银白色*/
+ (instancetype)silverColor
{
    return [UIColor colorWithRGB:0xC0C0C0];
}
/** 暗淡的灰色*/
+ (instancetype)dimGray
{
    return [UIColor colorWithRGB:0x696969];
}


#pragma mark - **************** 白色系
/** 海贝壳*/
+ (instancetype)seaShell
{
    return [UIColor colorWithRGB:0xFFF5EE];
}
/** 雪*/
+ (instancetype)snowColor
{
    return [UIColor colorWithRGB:0xFFFAFA];
}
/** 亚麻色*/
+ (instancetype)linenColor
{
    return [UIColor colorWithRGB:0xFAF0E6];
}
/** 花之白*/
+ (instancetype)floralWhite
{
    return [UIColor colorWithRGB:0xFFFAF0];
}
/** 老饰带*/
+ (instancetype)oldLace
{
    return [UIColor colorWithRGB:0xFDF5E6];
}
/** 象牙白*/
+ (instancetype)ivoryColor
{
    return [UIColor colorWithRGB:0xFFFFF0];
}
/** 蜂蜜露*/
+ (instancetype)honeydew
{
    return [UIColor colorWithRGB:0xF0FFF0];
}
/** 薄荷奶油*/
+ (instancetype)mintCream
{
    return [UIColor colorWithRGB:0xF5FFFA];
}
/** 蔚蓝色*/
+ (instancetype)azureColor
{
    return [UIColor colorWithRGB:0xF0FFFF];
}
/** 爱丽丝蓝*/
+ (instancetype)aliceBlue
{
    return [UIColor colorWithRGB:0xF0F8FF];
}
/** 幽灵白*/
+ (instancetype)ghostWhite
{
    return [UIColor colorWithRGB:0xF8F8FF];
}
/** 淡紫红*/
+ (instancetype)lavenderBlush
{
    return [UIColor colorWithRGB:0xFFF0F5];
}
/** 米色*/
+ (instancetype)beigeColor
{
    return [UIColor colorWithRGB:0xF5F5DD];
}


#pragma mark - **************** 棕色系
/** 黄褐色*/
+ (instancetype)tanColor
{
    return [UIColor colorWithRGB:0xD2B48C];
}
/** 玫瑰棕色*/
+ (instancetype)rosyBrown
{
    return [UIColor colorWithRGB:0xBC8F8F];
}
/** 秘鲁*/
+ (instancetype)peruColor
{
    return [UIColor colorWithRGB:0xCD853F];
}
/** 巧克力*/
+ (instancetype)chocolateColor
{
    return [UIColor colorWithRGB:0xD2691E];
}
/** 古铜色*/
+ (instancetype)bronzeColor // $$$$$
{
    return [UIColor colorWithRGB:0xB87333];
}
/** 黄土赭色*/
+ (instancetype)siennaColor
{
    return [UIColor colorWithRGB:0xA0522D];
}
/** 马鞍棕色*/
+ (instancetype)saddleBrown
{
    return [UIColor colorWithRGB:0x8B4513];
}
/** 土棕*/
+ (instancetype)soilColor
{
    return [UIColor colorWithRGB:0x734A12];
}
/** 栗色*/
+ (instancetype)maroonColor
{
    return [UIColor colorWithRGB:0x800000];
}
/** 乌贼墨棕*/
+ (instancetype)inkfishBrown
{
    return [UIColor colorWithRGB:0x5E2612];
}


#pragma mark - **************** 粉色系
/** 水粉*/
+ (instancetype)waterPink // $$$$$
{
    return [UIColor colorWithRGB:0xF3D3E7];
}
/** 藕色*/
+ (instancetype)lotusRoot // $$$$$
{
    return [UIColor colorWithRGB:0xEDD1D8];
}
/** 浅粉红*/
+ (instancetype)lightPink
{
    return [UIColor colorWithRGB:0xFFB6C1];
}
/** 适中的粉红*/
+ (instancetype)mediumPink
{
    return [UIColor colorWithRGB:0xFFC0CB];
}
/** 桃红*/
+ (instancetype)peachRed // $$$$$
{
    return [UIColor colorWithRGB:0xF47983];
}
/** 苍白的紫罗兰红色*/
+ (instancetype)paleVioletRed
{
    return [UIColor colorWithRGB:0xDB7093];
}
/** 深粉色*/
+ (instancetype)deepPink
{
    return [UIColor colorWithRGB:0xFF1493];
}

///MARK:=============================================================================
///MARK:常用颜色
///MARK:=============================================================================




@end






#define CLAMP_COLOR_VALUE(v) (v) = (v) < 0 ? 0 : (v) > 1 ? 1 : (v)

void CS_RGB2HSL(CGFloat r, CGFloat g, CGFloat b,
                CGFloat *h, CGFloat *s, CGFloat *l) {
    CLAMP_COLOR_VALUE(r);
    CLAMP_COLOR_VALUE(g);
    CLAMP_COLOR_VALUE(b);
    
    CGFloat max, min, delta, sum;
    max = fmaxf(r, fmaxf(g, b));
    min = fminf(r, fminf(g, b));
    delta = max - min;
    sum = max + min;
    
    *l = sum / 2;           // 亮度
    if (delta == 0) {       // 没有饱和度,所以色相不定(消色差)
        *h = *s = 0;
        return;
    }
    *s = delta / (sum < 1 ? sum : 2 - sum);             // 饱和度
    if (r == max) *h = (g - b) / delta / 6;             // y＆m之间的颜色
    else if (g == max) *h = (2 + (b - r) / delta) / 6;  // c＆y之间的颜色
    else *h = (4 + (r - g) / delta) / 6;                // m＆y之间的颜色
    if (*h < 0) *h += 1;
}

void CS_HSL2RGB(CGFloat h, CGFloat s, CGFloat l,
                CGFloat *r, CGFloat *g, CGFloat *b) {
    CLAMP_COLOR_VALUE(h);
    CLAMP_COLOR_VALUE(s);
    CLAMP_COLOR_VALUE(l);
    
    if (s == 0) { // 无饱和度,色相未定义(消色差)
        *r = *g = *b = l;
        return;
    }
    
    CGFloat q;
    q = (l <= 0.5) ? (l * (1 + s)) : (l + s - (l * s));
    if (q <= 0) {
        *r = *g = *b = 0.0;
    } else {
        *r = *g = *b = 0;
        int sextant;
        CGFloat m, sv, fract, vsf, mid1, mid2;
        m = l + l - q;
        sv = (q - m) / q;
        if (h == 1) h = 0;
        h *= 6.0;
        sextant = h;
        fract = h - sextant;
        vsf = q * sv * fract;
        mid1 = m + vsf;
        mid2 = q - vsf;
        switch (sextant) {
            case 0: *r = q; *g = mid1; *b = m; break;
            case 1: *r = mid2; *g = q; *b = m; break;
            case 2: *r = m; *g = q; *b = mid1; break;
            case 3: *r = m; *g = mid2; *b = q; break;
            case 4: *r = mid1; *g = m; *b = q; break;
            case 5: *r = q; *g = m; *b = mid2; break;
        }
    }
}

void CS_RGB2HSB(CGFloat r, CGFloat g, CGFloat b,
                CGFloat *h, CGFloat *s, CGFloat *v) {
    CLAMP_COLOR_VALUE(r);
    CLAMP_COLOR_VALUE(g);
    CLAMP_COLOR_VALUE(b);
    
    CGFloat max, min, delta;
    max = fmax(r, fmax(g, b));
    min = fmin(r, fmin(g, b));
    delta = max - min;
    
    *v = max;               // 亮度
    if (delta == 0) {       // 没有饱和度,所以色相不定(消色差)
        *h = *s = 0;
        return;
    }
    *s = delta / max;       // 饱和
    
    if (r == max) *h = (g - b) / delta / 6;             // color between y & m
    else if (g == max) *h = (2 + (b - r) / delta) / 6;  // color between c & y
    else *h = (4 + (r - g) / delta) / 6;                // color between m & c
    if (*h < 0) *h += 1;
}

void CS_HSB2RGB(CGFloat h, CGFloat s, CGFloat v,
                CGFloat *r, CGFloat *g, CGFloat *b) {
    CLAMP_COLOR_VALUE(h);
    CLAMP_COLOR_VALUE(s);
    CLAMP_COLOR_VALUE(v);
    
    if (s == 0) {
        *r = *g = *b = v; // No Saturation, so Hue is undefined (Achromatic)
    } else {
        int sextant;
        CGFloat f, p, q, t;
        if (h == 1) h = 0;
        h *= 6;
        sextant = floor(h);
        f = h - sextant;
        p = v * (1 - s);
        q = v * (1 - s * f);
        t = v * (1 - s * (1 - f));
        switch (sextant) {
            case 0: *r = v; *g = t; *b = p; break;
            case 1: *r = q; *g = v; *b = p; break;
            case 2: *r = p; *g = v; *b = t; break;
            case 3: *r = p; *g = q; *b = v; break;
            case 4: *r = t; *g = p; *b = v; break;
            case 5: *r = v; *g = p; *b = q; break;
        }
    }
}

void CS_RGB2CMYK(CGFloat r, CGFloat g, CGFloat b,
                 CGFloat *c, CGFloat *m, CGFloat *y, CGFloat *k) {
    CLAMP_COLOR_VALUE(r);
    CLAMP_COLOR_VALUE(g);
    CLAMP_COLOR_VALUE(b);
    
    *c = 1 - r;
    *m = 1 - g;
    *y = 1 - b;
    *k = fmin(*c, fmin(*m, *y));
    
    if (*k == 1) {
        *c = *m = *y = 0;   // Pure black
    } else {
        *c = (*c - *k) / (1 - *k);
        *m = (*m - *k) / (1 - *k);
        *y = (*y - *k) / (1 - *k);
    }
}

void CS_CMYK2RGB(CGFloat c, CGFloat m, CGFloat y, CGFloat k,
                 CGFloat *r, CGFloat *g, CGFloat *b) {
    CLAMP_COLOR_VALUE(c);
    CLAMP_COLOR_VALUE(m);
    CLAMP_COLOR_VALUE(y);
    CLAMP_COLOR_VALUE(k);
    
    *r = (1 - c) * (1 - k);
    *g = (1 - m) * (1 - k);
    *b = (1 - y) * (1 - k);
}

void CS_HSB2HSL(CGFloat h, CGFloat s, CGFloat b,
                CGFloat *hh, CGFloat *ss, CGFloat *ll) {
    CLAMP_COLOR_VALUE(h);
    CLAMP_COLOR_VALUE(s);
    CLAMP_COLOR_VALUE(b);
    
    *hh = h;
    *ll = (2 - s) * b / 2;
    if (*ll <= 0.5) {
        *ss = (s) / ((2 - s));
    } else {
        *ss = (s * b) / (2 - (2 - s) * b);
    }
}

void CS_HSL2HSB(CGFloat h, CGFloat s, CGFloat l,
                CGFloat *hh, CGFloat *ss, CGFloat *bb) {
    CLAMP_COLOR_VALUE(h);
    CLAMP_COLOR_VALUE(s);
    CLAMP_COLOR_VALUE(l);
    
    *hh = h;
    if (l <= 0.5) {
        *bb = (s + 1) * l;
        *ss = (2 * s) / (s + 1);
    } else {
        *bb = l + s * (1 - l);
        *ss = (2 * s * (1 - l)) / *bb;
    }
}




