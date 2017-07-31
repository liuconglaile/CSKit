//
//  UIColor+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern void CS_RGB2HSL(CGFloat r, CGFloat g, CGFloat b,
                       CGFloat *h, CGFloat *s, CGFloat *l);

extern void CS_HSL2RGB(CGFloat h, CGFloat s, CGFloat l,
                       CGFloat *r, CGFloat *g, CGFloat *b);

extern void CS_RGB2HSB(CGFloat r, CGFloat g, CGFloat b,
                       CGFloat *h, CGFloat *s, CGFloat *v);

extern void CS_HSB2RGB(CGFloat h, CGFloat s, CGFloat v,
                       CGFloat *r, CGFloat *g, CGFloat *b);

extern void CS_RGB2CMYK(CGFloat r, CGFloat g, CGFloat b,
                        CGFloat *c, CGFloat *m, CGFloat *y, CGFloat *k);

extern void CS_CMYK2RGB(CGFloat c, CGFloat m, CGFloat y, CGFloat k,
                        CGFloat *r, CGFloat *g, CGFloat *b);

extern void CS_HSB2HSL(CGFloat h, CGFloat s, CGFloat b,
                       CGFloat *hh, CGFloat *ss, CGFloat *ll);

extern void CS_HSL2HSB(CGFloat h, CGFloat s, CGFloat l,
                       CGFloat *hh, CGFloat *ss, CGFloat *bb);


/*
 使用十六进制字符串创建UIColor.
 示例:UIColorHex(0xF0F),UIColorHex(66ccff),UIColorHex(#66CCFF88)
 
 有效格式:#RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB...
 '#'或'0x'不是必需的.
 */
#ifndef UIColorHex
#define UIColorHex(_hex_)   [UIColor colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif

/**
 为'UIColor'提供一些方法来转换颜色RGB,HSB,HSL,CMYK和Hex.
 | 颜色空间      | 含义                |
 |-------------|---------------------|
 | RGB *       | 红   绿    蓝        |
 | HSB(HSV) *  | 色相 饱和度 亮度(值)   |
 | HSL         | 色相 饱和度 亮度       |
 | CMYK        | 青色 品红色 黄色 黑色   |
 
 苹果使用RGB和HSB为默认值.
 
 此类别中的所有值都是浮点数,范围为0.0到-1.0.
 0.0以下的值被解释为'0.0',而高于'1.0'的值被解释为'1.0'.
 see https://github.com/ibireme/yy_color_convertor
 */
@interface UIColor (Extended)

///MARK:=============================================================================
///MARK:UIColor对象构造函数
///MARK:=============================================================================

/**
 使用指定的不透明度和HSL颜色空间组件值创建和返回颜色对象.
 参数指定为0.0到1.0的值
 
 @param hue        HSL颜色空间中颜色对象的色调分量
 @param saturation HSL颜色空间中颜色对象的饱和度分量
 @param lightness  HSL颜色空间中颜色对象的亮度分量
 @param alpha      颜色对象的不透明度值
 @return           颜色对象.由该对象表示在设备RGB颜色空间中的颜色信息.
 */
+ (UIColor *)colorWithHue:(CGFloat)hue
               saturation:(CGFloat)saturation
                lightness:(CGFloat)lightness
                    alpha:(CGFloat)alpha;

/**
 使用指定的不透明度和CMYK颜色空间分量值创建并返回颜色对象.
 参数指定为0.0到1.0的值
 
 @param cyan    CMYK颜色空间中的颜色对象的青色分量
 @param magenta CMYK颜色空间中颜色对象的洋红色分量
 @param yellow  CMYK颜色空间中颜色对象的黄色分量
 @param black   CMYK颜色空间中的颜色对象的黑色分量
 @param alpha   颜色对象的不透明度值.
 @return        颜色对象.由该对象表示在设备RGB颜色空间中的颜色信息.
 */
+ (UIColor *)colorWithCyan:(CGFloat)cyan
                   magenta:(CGFloat)magenta
                    yellow:(CGFloat)yellow
                     black:(CGFloat)black
                     alpha:(CGFloat)alpha;

/**
 使用十六进制RGB颜色值创建并返回颜色对象.
 
 @param rgbValue  rgb值,如0x66ccff.
 @return          颜色对象.由该对象表示在设备RGB颜色空间中的颜色信息.
 */
+ (UIColor *)colorWithRGB:(uint32_t)rgbValue;

/**
 使用十六进制RGBA颜色值创建并返回颜色对象.
 
 @param rgbaValue  rgb值,如0x66ccff
 @return           颜色对象.由该对象表示在设备RGB颜色空间中的颜色信息.
 */
+ (UIColor *)colorWithRGBA:(uint32_t)rgbaValue;

/**
 使用指定的不透明度和RGB十六进制值创建并返回颜色对象.
 
 @param rgbValue  rgb值,如0x66CCFF.
 @param alpha     alpha颜色对象的不透明度值,指定为0.0到1.0的值.
 @return          颜色对象.由该对象表示在设备RGB颜色空间中的颜色信息.
 */
+ (UIColor *)colorWithRGB:(uint32_t)rgbValue alpha:(CGFloat)alpha;

/**
 从十六进制字符串创建并返回一个颜色对象
 
 @discussion:
 有效格式: #RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB ...
 '#' 和 '0x' 不是必须值.
 alpha如果不设置,默认为1.0.
 如果解析时发生错误时返回nil.
 
 示例: @"0xF0F", @"66ccff", @"#66CCFF88"
 
 @param hexStr  颜色的十六进制字符串值.
 @return        十六进制字符串的UIColor对象,如果发生错误,则为nil.
 */
+ (nullable UIColor *)colorWithHexString:(NSString *)hexStr;

/**
 通过添加新颜色创建并返回混合颜色对象.
 
 @param add        新增颜色
 @param blendMode  颜色混合模式
 */
- (UIColor *)colorByAddColor:(UIColor *)add blendMode:(CGBlendMode)blendMode;

/**
 通过HSB改变和返回颜色对象
 以下值从-1.0到1.0, 0表示没有变化
 
 @param hueDelta         色调值设置.
 @param saturationDelta  饱和度设置.
 @param brightnessDelta  亮度设置.
 @param alphaDelta       通道值(透明度)设置.
 */
- (UIColor *)colorByChangeHue:(CGFloat)hueDelta
                   saturation:(CGFloat)saturationDelta
                   brightness:(CGFloat)brightnessDelta
                        alpha:(CGFloat)alphaDelta;




///MARK:=============================================================================
///MARK:获取颜色的描述
///MARK:=============================================================================

/**
 返回十六进制的RGB值.
 @return RGB的十六进制值,如0x66ccff.
 */
- (uint32_t)rgbValue;

/**
 返回十六进制的RGBA值.
 
 @return RGBA的十六进制值,如0x66ccffff.
 */
- (uint32_t)rgbaValue;

/**
 将颜色的RGB值作为十六进制字符串返回(小写).
 例如 @"0066cc".
 
 当颜色空间不是RGB时,它将返回nil
 
 @return 颜色的值作为十六进制字符串.
 */
- (nullable NSString *)hexString;

/**
 返回颜色的RGBA值作为十六进制字符串(小写).
 例如 @"0066ccff".
 
 当颜色空间不是RGBA时,它将返回nil
 
 @return 颜色的值作为十六进制字符串返回.
 */
- (nullable NSString *)hexStringWithAlpha;


///MARK:=============================================================================
///MARK:检索颜色信息
///MARK:=============================================================================

/**
 返回在HSL颜色空间中组成颜色的组件.
 参数均为指定为0.0和1.0之间的值
 
 @param hue         色调值
 @param saturation  饱和度值
 @param lightness   亮度值
 @param alpha       透明度值
 @return            如果颜色可以转换就返回YES,否则NO.
 */
- (BOOL)getHue:(CGFloat *)hue
    saturation:(CGFloat *)saturation
     lightness:(CGFloat *)lightness
         alpha:(CGFloat *)alpha;

/**
 返回组成CMYK颜色空间中的颜色的组件.
 
 @param cyan     青色值.
 @param magenta  洋红色值.
 @param yellow   黄色值.
 @param black    黑色值.
 @param alpha    透明度值.
 @return         如果颜色可以转换就返回YES,否则NO.
 */
- (BOOL)getCyan:(CGFloat *)cyan
        magenta:(CGFloat *)magenta
         yellow:(CGFloat *)yellow
          black:(CGFloat *)black
          alpha:(CGFloat *)alpha;

/**
 一下属性的值为'0.0'到'1.0'范围内的浮点数
 */

/**
 RGB颜色空间中的颜色红色分量值.
 */
@property (nonatomic, readonly) CGFloat red;

/**
 RGB颜色空间中颜色的绿色分量值.
 */
@property (nonatomic, readonly) CGFloat green;

/**
 RGB颜色空间中颜色的蓝色分量值.
 */
@property (nonatomic, readonly) CGFloat blue;

/**
 HSB颜色空间中颜色的色调分量值
 */
@property (nonatomic, readonly) CGFloat hue;

/**
 HSB颜色空间中颜色的饱和分量值
 */
@property (nonatomic, readonly) CGFloat saturation;

/**
 HSB颜色空间中颜色的亮度分量值
 */
@property (nonatomic, readonly) CGFloat brightness;

/**
 颜色的alpha分量值
 */
@property (nonatomic, readonly) CGFloat alpha;

/**
 颜色的色彩空间模型
 */
@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;

/**
 可读颜色空间字符串.
 */
@property (nullable, nonatomic, readonly) NSString *colorSpaceString;



///MARK:=============================================================================
///MARK:WEB颜色
///MARK:=============================================================================

/** 获取canvas用的颜色字符串 */
- (NSString *)canvasColorString;

/** 获取网页颜色字串 */
- (NSString *)webColorString;




///MARK:=============================================================================
///MARK:常用颜色
///MARK:=============================================================================

+ (instancetype)mainColor;
+ (instancetype)backColor;
+ (instancetype)backColor2;

/**
 常规字体颜色
 
 @return 深灰颜色
 */
+ (instancetype)FontColor1;
+ (instancetype)FontColor2;
+ (instancetype)FontColor3;
+ (instancetype)FontColor4;


/**
 渐变颜色
 
 @param aColor 开始颜色
 @param bColor 结束颜色
 @param height 渐变高度
 @return 渐变颜色
 */
+ (UIColor*)gradientFromColor:(UIColor*)aColor toColor:(UIColor*)bColor withHeight:(int)height;


#pragma mark - **************** 红色系
/** 薄雾玫瑰*/
+ (instancetype)mistyRose;
/** 浅鲑鱼色*/
+ (instancetype)lightSalmon;
/** 淡珊瑚色*/
+ (instancetype)lightCoral;
/** 鲑鱼色*/
+ (instancetype)salmonColor;
/** 珊瑚色*/
+ (instancetype)coralColor;
/** 番茄*/
+ (instancetype)tomatoColor;
/** 橙红色*/
+ (instancetype)orangeRed;
/** 印度红*/
+ (instancetype)indianRed;
/** 猩红*/
+ (instancetype)crimsonColor;
/** 耐火砖*/
+ (instancetype)fireBrick;

#pragma mark - **************** 黄色系
/** 玉米色*/
+ (instancetype)cornColor;
/** 柠檬薄纱*/
+ (instancetype)LemonChiffon;
/** 苍金麒麟*/
+ (instancetype)paleGodenrod;
/** 卡其色*/
+ (instancetype)khakiColor;
/** 金色*/
+ (instancetype)goldColor;
/** 雌黄*/
+ (instancetype)orpimentColor;
/** 藤黄*/
+ (instancetype)gambogeColor;
/** 雄黄*/
+ (instancetype)realgarColor;
/** 金麒麟色*/
+ (instancetype)goldenrod;
/** 乌金*/
+ (instancetype)darkGold;

#pragma mark - **************** 绿色系
/** 苍绿*/
+ (instancetype)paleGreen;
/** 淡绿色*/
+ (instancetype)lightGreen;
/** 春绿*/
+ (instancetype)springGreen;
/** 绿黄色*/
+ (instancetype)greenYellow;
/** 草坪绿*/
+ (instancetype)lawnGreen;
/** 酸橙绿*/
+ (instancetype)limeColor;
/** 森林绿*/
+ (instancetype)forestGreen;
/** 海洋绿*/
+ (instancetype)seaGreen;
/** 深绿*/
+ (instancetype)darkGreen;
/** 橄榄(墨绿)*/
+ (instancetype)olive;

#pragma mark - **************** 青色系
/** 淡青色*/
+ (instancetype)lightCyan;
/** 苍白绿松石*/
+ (instancetype)paleTurquoise;
/** 绿碧*/
+ (instancetype)aquamarine;
/** 绿松石*/
+ (instancetype)turquoise;
/** 适中绿松石*/
+ (instancetype)mediumTurquoise;
/** 美团色*/
+ (instancetype)meituanColor;
/** 浅海洋绿*/
+ (instancetype)lightSeaGreen;
/** 深青色*/
+ (instancetype)darkCyan;
/** 水鸭色*/
+ (instancetype)tealColor;
/** 深石板灰*/
+ (instancetype)darkSlateGray;

#pragma mark - **************** 蓝色系
/** 天蓝色*/
+ (instancetype)skyBlue;
/** 淡蓝*/
+ (instancetype)lightBLue;
/** 深天蓝*/
+ (instancetype)deepSkyBlue;
/** 道奇蓝*/
+ (instancetype)doderBlue;
/** 矢车菊*/
+ (instancetype)cornflowerBlue;
/** 皇家蓝*/
+ (instancetype)royalBlue;
/** 适中的蓝色*/
+ (instancetype)mediumBlue;
/** 深蓝*/
+ (instancetype)darkBlue;
/** 海军蓝*/
+ (instancetype)navyColor;
/** 午夜蓝*/
+ (instancetype)midnightBlue;

#pragma mark - **************** 紫色系
/** 薰衣草*/
+ (instancetype)lavender;
/** 蓟*/
+ (instancetype)thistleColor;
/** 李子*/
+ (instancetype)plumColor;
/** 紫罗兰*/
+ (instancetype)violetColor;
/** 适中的兰花紫*/
+ (instancetype)mediumOrchid;
/** 深兰花紫*/
+ (instancetype)darkOrchid;
/** 深紫罗兰色*/
+ (instancetype)darkVoilet;
/** 泛蓝紫罗兰*/
+ (instancetype)blueViolet;
/** 深洋红色*/
+ (instancetype)darkMagenta;
/** 靛青*/
+ (instancetype)indigoColor;

#pragma mark - **************** 灰色系
/** 白烟*/
+ (instancetype)whiteSmoke;
/** 鸭蛋*/
+ (instancetype)duckEgg;
/** 亮灰*/
+ (instancetype)gainsboroColor;
/** 蟹壳青*/
+ (instancetype)carapaceColor;
/** 银白色*/
+ (instancetype)silverColor;
/** 暗淡的灰色*/
+ (instancetype)dimGray;

#pragma mark - **************** 白色系
/** 海贝壳*/
+ (instancetype)seaShell;
/** 雪*/
+ (instancetype)snowColor;
/** 亚麻色*/
+ (instancetype)linenColor;
/** 花之白*/
+ (instancetype)floralWhite;
/** 老饰带*/
+ (instancetype)oldLace;
/** 象牙白*/
+ (instancetype)ivoryColor;
/** 蜂蜜露*/
+ (instancetype)honeydew;
/** 薄荷奶油*/
+ (instancetype)mintCream;
/** 蔚蓝色*/
+ (instancetype)azureColor;
/** 爱丽丝蓝*/
+ (instancetype)aliceBlue;
/** 幽灵白*/
+ (instancetype)ghostWhite;
/** 淡紫红*/
+ (instancetype)lavenderBlush;
/** 米色*/
+ (instancetype)beigeColor;

#pragma mark - **************** 棕色系
/** 黄褐色*/
+ (instancetype)tanColor;
/** 玫瑰棕色*/
+ (instancetype)rosyBrown;
/** 秘鲁*/
+ (instancetype)peruColor;
/** 巧克力*/
+ (instancetype)chocolateColor;
/** 古铜色*/
+ (instancetype)bronzeColor;
/** 黄土赭色*/
+ (instancetype)siennaColor;
/** 马鞍棕色*/
+ (instancetype)saddleBrown;
/** 土棕*/
+ (instancetype)soilColor;
/** 栗色*/
+ (instancetype)maroonColor;
/** 乌贼墨棕*/
+ (instancetype)inkfishBrown;

#pragma mark - **************** 粉色系
/** 水粉*/
+ (instancetype)waterPink;
/** 藕色*/
+ (instancetype)lotusRoot;
/** 浅粉红*/
+ (instancetype)lightPink;
/** 适中的粉红*/
+ (instancetype)mediumPink;
/** 桃红*/
+ (instancetype)peachRed;
/** 苍白的紫罗兰红色*/
+ (instancetype)paleVioletRed;
/** 深粉色*/
+ (instancetype)deepPink;



@end

NS_ASSUME_NONNULL_END




