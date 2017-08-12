//
//  CSTextAttribute.m
//  CSCategory
//
//  Created by mac on 2017/7/26.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSTextAttribute.h"
#import <CoreText/CoreText.h>


#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSKitMacro.h>
#import <CSkit/UIDevice+Extended.h>
#import <CSkit/CSTextArchiver.h>
#import <CSkit/UIFont+Extended.h>
#else
#import "CSKitMacro.h"
#import "UIDevice+Extended.h"
#import "CSTextArchiver.h"
#import "UIFont+Extended.h"
#endif

NSString *const CSTextBackedStringAttributeName = @"CSTextBackedString";
NSString *const CSTextBindingAttributeName = @"CSTextBinding";
NSString *const CSTextShadowAttributeName = @"CSTextShadow";
NSString *const CSTextInnerShadowAttributeName = @"CSTextInnerShadow";
NSString *const CSTextUnderlineAttributeName = @"CSTextUnderline";
NSString *const CSTextStrikethroughAttributeName = @"CSTextStrikethrough";
NSString *const CSTextBorderAttributeName = @"CSTextBorder";
NSString *const CSTextBackgroundBorderAttributeName = @"CSTextBackgroundBorder";
NSString *const CSTextBlockBorderAttributeName = @"CSTextBlockBorder";
NSString *const CSTextAttachmentAttributeName_text = @"CSTextAttachment_text";
NSString *const CSTextHighlightAttributeName = @"CSTextHighlight";
NSString *const CSTextGlyphTransformAttributeName = @"CSTextGlyphTransform";

NSString *const CSTextAttachmentToken = @"\uFFFC";
NSString *const CSTextTruncationToken = @"\u2026";








CSTextAttributeType CSTextAttributeGetType(NSString *name){
    if (name.length == 0) return CSTextAttributeTypeNone;
    
    static NSMutableDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = [NSMutableDictionary new];
        NSNumber *All = @(CSTextAttributeTypeUIKit | CSTextAttributeTypeCoreText | CSTextAttributeTypeCSText);
        NSNumber *CoreText_CSText = @(CSTextAttributeTypeCoreText | CSTextAttributeTypeCSText);
        NSNumber *UIKit_CSText = @(CSTextAttributeTypeUIKit | CSTextAttributeTypeCSText);
        NSNumber *UIKit_CoreText = @(CSTextAttributeTypeUIKit | CSTextAttributeTypeCoreText);
        NSNumber *UIKit = @(CSTextAttributeTypeUIKit);
        NSNumber *CoreText = @(CSTextAttributeTypeCoreText);
        NSNumber *CSText = @(CSTextAttributeTypeCSText);
        
        dic[NSFontAttributeName] = All;
        dic[NSKernAttributeName] = All;
        dic[NSForegroundColorAttributeName] = UIKit;
        dic[(id)kCTForegroundColorAttributeName] = CoreText;
        dic[(id)kCTForegroundColorFromContextAttributeName] = CoreText;
        dic[NSBackgroundColorAttributeName] = UIKit;
        dic[NSStrokeWidthAttributeName] = All;
        dic[NSStrokeColorAttributeName] = UIKit;
        dic[(id)kCTStrokeColorAttributeName] = CoreText_CSText;
        dic[NSShadowAttributeName] = UIKit_CSText;
        dic[NSStrikethroughStyleAttributeName] = UIKit;
        dic[NSUnderlineStyleAttributeName] = UIKit_CoreText;
        dic[(id)kCTUnderlineColorAttributeName] = CoreText;
        dic[NSLigatureAttributeName] = All;
        dic[(id)kCTSuperscriptAttributeName] = UIKit; //这是一个CoreText的attrubite,但只支持UIKit...
        dic[NSVerticalGlyphFormAttributeName] = All;
        dic[(id)kCTGlyphInfoAttributeName] = CoreText_CSText;
        dic[(id)kCTCharacterShapeAttributeName] = CoreText_CSText;
        dic[(id)kCTRunDelegateAttributeName] = CoreText_CSText;
        dic[(id)kCTBaselineClassAttributeName] = CoreText_CSText;
        dic[(id)kCTBaselineInfoAttributeName] = CoreText_CSText;
        dic[(id)kCTBaselineReferenceInfoAttributeName] = CoreText_CSText;
        dic[(id)kCTWritingDirectionAttributeName] = CoreText_CSText;
        dic[NSParagraphStyleAttributeName] = All;
        
        if (kiOS7Later) {
            dic[NSStrikethroughColorAttributeName] = UIKit;
            dic[NSUnderlineColorAttributeName] = UIKit;
            dic[NSTextEffectAttributeName] = UIKit;
            dic[NSObliquenessAttributeName] = UIKit;
            dic[NSExpansionAttributeName] = UIKit;
            dic[(id)kCTLanguageAttributeName] = CoreText_CSText;
            dic[NSBaselineOffsetAttributeName] = UIKit;
            dic[NSWritingDirectionAttributeName] = All;
            dic[NSAttachmentAttributeName] = UIKit;
            dic[NSLinkAttributeName] = UIKit;
        }
        if (kiOS8Later) {
            dic[(id)kCTRubyAnnotationAttributeName] = CoreText;
        }
        
        dic[CSTextBackedStringAttributeName] = CSText;
        dic[CSTextBindingAttributeName] = CSText;
        dic[CSTextShadowAttributeName] = CSText;
        dic[CSTextInnerShadowAttributeName] = CSText;
        dic[CSTextUnderlineAttributeName] = CSText;
        dic[CSTextStrikethroughAttributeName] = CSText;
        dic[CSTextBorderAttributeName] = CSText;
        dic[CSTextBackgroundBorderAttributeName] = CSText;
        dic[CSTextBlockBorderAttributeName] = CSText;
        dic[CSTextAttachmentAttributeName_text] = CSText;
        dic[CSTextHighlightAttributeName] = CSText;
        dic[CSTextGlyphTransformAttributeName] = CSText;
    });
    NSNumber *num = dic[name];
    if (num) return num.integerValue;
    return CSTextAttributeTypeNone;
}




NSString *const CSTextAttachmentAttributeName        =@"CSTextAttachmentKey";
NSString *const CSTextLinkAttributedName             =@"CSTextLinkAttributedName";
NSString *const CSTextLongPressAttributedName        =@"CSTextLongPressAttributedName";
NSString *const CSTextBackgroundColorAttributedName  =@"CSTextBackgroundColorAttributedName";
NSString *const CSTextStrokeAttributedName           =@"CSTextStrokeAttributedName";
NSString *const CSTextBoundingStrokeAttributedName   =@"CSTextBoundingStrokeAttributedName";






//MARK:=============================CSTextAttachment===========================
NSString *const kCSTextAttachmentContent           = @"content";
NSString *const kCSTextAttachmentRange             = @"range";
NSString *const kCSTextAttachmentFrame             = @"frame";
NSString *const kCSTextAttachmentURL               = @"URL";
NSString *const kCSTextAttachmentContentMode       = @"contentMode";
NSString *const kCSTextAttachmentContentEdgeInsets = @"contentEdgeInsets";
NSString *const kCSTextAttachmentUserInfo          = @"userInfo";

@implementation CSTextAttachment

+ (instancetype)textAttachmentWithContent:(id)content {
    CSTextAttachment* attachment = [[CSTextAttachment alloc] init];
    attachment.content = content;
    attachment.contentMode = UIViewContentModeScaleAspectFill;
    attachment.contentEdgeInsets = UIEdgeInsetsZero;
    return attachment;
}

+ (instancetype)attachmentWithContent:(id)content {
    CSTextAttachment *one = [self new];
    one.content = content;
    return one;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.contentEdgeInsets = UIEdgeInsetsZero;
    }
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:kCSTextAttachmentContent];
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:kCSTextAttachmentRange];
    [aCoder encodeCGRect:self.frame forKey:kCSTextAttachmentFrame];
    [aCoder encodeObject:self.URL forKey:kCSTextAttachmentURL];
    [aCoder encodeInteger:self.contentMode forKey:kCSTextAttachmentContentMode];
    [aCoder encodeUIEdgeInsets:self.contentEdgeInsets forKey:kCSTextAttachmentContentEdgeInsets];
    [aCoder encodeObject:self.userInfo forKey:kCSTextAttachmentUserInfo];
    
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:self.contentInsets] forKey:@"contentInsets"];
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:kCSTextAttachmentContent];
        self.range = [[aDecoder decodeObjectForKey:kCSTextAttachmentRange] rangeValue];
        self.frame = [aDecoder decodeCGRectForKey:kCSTextAttachmentFrame];
        self.URL = [aDecoder decodeObjectForKey:kCSTextAttachmentURL];
        self.contentMode = [aDecoder decodeIntegerForKey:kCSTextAttachmentContentMode];
        self.contentEdgeInsets = [aDecoder decodeUIEdgeInsetsForKey:kCSTextAttachmentContentEdgeInsets];
        self.userInfo = [aDecoder decodeObjectForKey:kCSTextAttachmentUserInfo];
        
        _contentInsets = ((NSValue *)[aDecoder decodeObjectForKey:@"contentInsets"]).UIEdgeInsetsValue;
    }
    return self;
}

#pragma mark - NSCopying
- (instancetype)copyWithZone:(NSZone *)zone {
    typeof(self) copy = [self.class new];
    if ([self.content conformsToProtocol:@protocol(NSCopying)]) {
        copy.content = [self.content copy];
    } else {
        copy.content = self.content;
    }
    copy.range = self.range;
    copy.frame = self.frame;
    copy.URL = [self.URL copy];
    copy.contentMode = self.contentMode;
    copy.contentEdgeInsets = self.contentEdgeInsets;
    copy.userInfo = [self.userInfo copy];
    copy.contentInsets = self.contentInsets;
    
    return copy;
}
- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

@end
//MARK:=============================CSTextAttachment===========================









//MARK:=============================CSTextBackgroundColor======================
NSString *const kCSTextBackgroundColorBackgroundColor = @"backgroundColor";
NSString *const kCSTextBackgroundColorRange           = @"range";
NSString *const kCSTextBackgroundColorUserInfo        = @"userInfo";
NSString *const kCSTextBackgroundColorPositions       = @"positions";

@implementation CSTextBackgroundColor

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.range = NSMakeRange(0, 0);
        self.userInfo = @{};
        self.positions = @[];
    }
    return self;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.backgroundColor forKey:kCSTextBackgroundColorBackgroundColor];
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:kCSTextBackgroundColorRange];
    [aCoder encodeObject:self.userInfo forKey:kCSTextBackgroundColorUserInfo];
    [aCoder encodeObject:self.positions forKey:kCSTextBackgroundColorPositions];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.backgroundColor = [aDecoder decodeObjectForKey:kCSTextBackgroundColorBackgroundColor];
        self.range = [[aDecoder decodeObjectForKey:kCSTextBackgroundColorRange] rangeValue];
        self.userInfo = [aDecoder decodeObjectForKey:kCSTextBackgroundColorUserInfo];
        self.positions = [aDecoder decodeObjectForKey:kCSTextBackgroundColorPositions];
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    CSTextBackgroundColor* bgColor = [[CSTextBackgroundColor alloc] init];
    bgColor.backgroundColor = [self.backgroundColor copy];
    bgColor.range = self.range;
    bgColor.userInfo = [self.userInfo copy];
    bgColor.positions = [self.positions copy];
    return bgColor;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

@end
//MARK:=============================CSTextBackgroundColor======================








//MARK:=============================CSTextStroke Text描边=======================
NSString *const kCSTextStrokeRange        = @"range";
NSString *const kCSTextStrokeStrokeColor  = @"strokeColor";
NSString *const kCSTextStrokeUserInfo     = @"userInfo";
NSString *const kCSTextStrokeStrokeWidth  = @"strokeWidth";

@implementation CSTextStroke

- (instancetype)init {
    self = [super init];
    if (self) {
        self.range = NSMakeRange(0, 0);
        self.strokeColor = [UIColor blackColor];
        self.strokeWidth = 1.0f;
        self.userInfo = @{};
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    CSTextStroke* stroke = [[CSTextStroke alloc] init];
    stroke.strokeColor = [self.strokeColor copy];
    stroke.range = self.range;
    stroke.userInfo = [self.userInfo copy];
    stroke.strokeWidth = self.strokeWidth;
    return stroke;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:kCSTextStrokeRange];
    [aCoder encodeObject:self.strokeColor forKey:kCSTextStrokeStrokeColor];
    [aCoder encodeObject:self.userInfo forKey:kCSTextStrokeUserInfo];
    [aCoder encodeFloat:self.strokeWidth forKey:kCSTextStrokeStrokeWidth];
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.range = [[aDecoder decodeObjectForKey:kCSTextStrokeRange] rangeValue];
        self.strokeColor = [aDecoder decodeObjectForKey:kCSTextStrokeStrokeColor];
        self.userInfo = [aDecoder decodeObjectForKey:kCSTextStrokeUserInfo];
        self.strokeWidth = [aDecoder decodeFloatForKey:kCSTextStrokeStrokeWidth];
    }
    return self;
}

@end
//MARK:=============================CSTextStroke Text描边=======================





//MARK:=============================CSTextBoundingStroke文本边框=================
NSString *const kCSTextBoundingStrokeRange       = @"range";
NSString *const kCSTextBoundingStrokeStrokeColor = @"strokeColor";
NSString *const kCSTextBoundingStrokeUserInfo    = @"userInfo";
NSString *const kCSTextBoundingStrokePositions   = @"positions";

NSString *const kCSTextBoundingStrokeLineStyle   = @"lineStyle";
NSString *const kCSTextBoundingStrokeStrokeWidth = @"strokeWidth";
NSString *const kCSTextBoundingStrokeLineJoin    = @"lineJoin";
NSString *const kCSTextBoundingStrokeInsets      = @"insets";
NSString *const kCSTextBoundingStrokeCornerRadius= @"cornerRadius";
NSString *const kCSTextBoundingStrokeShadow      = @"shadow";
NSString *const kCSTextBoundingStrokeFillColor   = @"fillColor";


@implementation CSTextBorder

- (instancetype)init {
    self = [super init];
    if (self) {
        self.range = NSMakeRange(0, 0);
        self.strokeColor = [UIColor clearColor];
        self.userInfo = @{};
        self.positions = @[];
        self.lineStyle = CSTextLineStyleSingle;
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    //CSTextBoundingStroke* stroke = [[CSTextBoundingStroke alloc] init];
    //one.strokeColor = [self.strokeColor copy];
    one.range = self.range;
    one.userInfo = [self.userInfo copy];
    one.positions = [self.positions copy];
    
    one.lineStyle = self.lineStyle;
    one.strokeWidth = self.strokeWidth;
    one.strokeColor = self.strokeColor;
    one.lineJoin = self.lineJoin;
    one.insets = self.insets;
    one.cornerRadius = self.cornerRadius;
    one.shadow = self.shadow.copy;
    one.fillColor = self.fillColor;
    return one;
}
- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:kCSTextBoundingStrokeRange];
    [aCoder encodeObject:self.strokeColor forKey:kCSTextBoundingStrokeStrokeColor];
    [aCoder encodeObject:self.userInfo forKey:kCSTextBoundingStrokeUserInfo];
    [aCoder encodeObject:self.positions forKey:kCSTextBoundingStrokePositions];
    
    [aCoder encodeObject:@(self.lineStyle) forKey:kCSTextBoundingStrokeLineStyle];
    [aCoder encodeObject:@(self.strokeWidth) forKey:kCSTextBoundingStrokeStrokeWidth];
    [aCoder encodeObject:@(self.lineJoin) forKey:kCSTextBoundingStrokeLineJoin];
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:self.insets] forKey:kCSTextBoundingStrokeInsets];
    [aCoder encodeObject:@(self.cornerRadius) forKey:kCSTextBoundingStrokeCornerRadius];
    [aCoder encodeObject:self.shadow forKey:kCSTextBoundingStrokeShadow];
    [aCoder encodeObject:self.fillColor forKey:kCSTextBoundingStrokeFillColor];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.range = [[aDecoder decodeObjectForKey:kCSTextBoundingStrokeRange] rangeValue];
        self.strokeColor = [aDecoder decodeObjectForKey:kCSTextBoundingStrokeStrokeColor];
        self.userInfo = [aDecoder decodeObjectForKey:kCSTextBoundingStrokeUserInfo];
        self.positions = [aDecoder decodeObjectForKey:kCSTextBoundingStrokePositions];
        
        _lineStyle = ((NSNumber *)[aDecoder decodeObjectForKey:kCSTextBoundingStrokeLineStyle]).unsignedIntegerValue;
        _strokeWidth = ((NSNumber *)[aDecoder decodeObjectForKey:kCSTextBoundingStrokeStrokeWidth]).doubleValue;
        _lineJoin = (CGLineJoin)((NSNumber *)[aDecoder decodeObjectForKey:kCSTextBoundingStrokeLineJoin]).unsignedIntegerValue;
        _insets = ((NSValue *)[aDecoder decodeObjectForKey:kCSTextBoundingStrokeInsets]).UIEdgeInsetsValue;
        _cornerRadius = ((NSNumber *)[aDecoder decodeObjectForKey:kCSTextBoundingStrokeCornerRadius]).doubleValue;
        _shadow = [aDecoder decodeObjectForKey:kCSTextBoundingStrokeShadow];
        _fillColor = [aDecoder decodeObjectForKey:kCSTextBoundingStrokeFillColor];
    }
    return self;
}









+ (instancetype)borderWithLineStyle:(CSTextLineStyle)lineStyle lineWidth:(CGFloat)width strokeColor:(UIColor *)color {
    CSTextBorder *one = [self new];
    one.lineStyle = lineStyle;
    one.strokeWidth = width;
    one.strokeColor = color;
    return one;
}

+ (instancetype)borderWithFillColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    CSTextBorder *one = [self new];
    one.fillColor = color;
    one.cornerRadius = cornerRadius;
    one.insets = UIEdgeInsetsMake(-2, 0, 0, -2);
    return one;
}







@end
//MARK:=============================CSTextBoundingStroke文本边框=================








@implementation CSTextBackedString

+ (instancetype)stringWithString:(NSString *)string {
    CSTextBackedString *one = [self new];
    one.string = string;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.string forKey:@"string"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _string = [aDecoder decodeObjectForKey:@"string"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.string = self.string;
    return one;
}

@end







@implementation CSTextBinding

+ (instancetype)bindingWithDeleteConfirm:(BOOL)deleteConfirm {
    CSTextBinding *one = [self new];
    one.deleteConfirm = deleteConfirm;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.deleteConfirm) forKey:@"deleteConfirm"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _deleteConfirm = ((NSNumber *)[aDecoder decodeObjectForKey:@"deleteConfirm"]).boolValue;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.deleteConfirm = self.deleteConfirm;
    return one;
}

@end






@implementation CSTextShadow

+ (instancetype)shadowWithColor:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius {
    CSTextShadow *one = [self new];
    one.color = color;
    one.offset = offset;
    one.radius = radius;
    return one;
}

+ (instancetype)shadowWithNSShadow:(NSShadow *)nsShadow {
    if (!nsShadow) return nil;
    CSTextShadow *shadow = [self new];
    shadow.offset = nsShadow.shadowOffset;
    shadow.radius = nsShadow.shadowBlurRadius;
    id color = nsShadow.shadowColor;
    if (color) {
        if (CGColorGetTypeID() == CFGetTypeID((__bridge CFTypeRef)(color))) {
            color = [UIColor colorWithCGColor:(__bridge CGColorRef)(color)];
        }
        if ([color isKindOfClass:[UIColor class]]) {
            shadow.color = color;
        }
    }
    return shadow;
}

- (NSShadow *)nsShadow {
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = self.offset;
    shadow.shadowBlurRadius = self.radius;
    shadow.shadowColor = self.color;
    return shadow;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeObject:@(self.radius) forKey:@"radius"];
    [aCoder encodeObject:[NSValue valueWithCGSize:self.offset] forKey:@"offset"];
    [aCoder encodeObject:self.subShadow forKey:@"subShadow"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _color = [aDecoder decodeObjectForKey:@"color"];
    _radius = ((NSNumber *)[aDecoder decodeObjectForKey:@"radius"]).floatValue;
    _offset = ((NSValue *)[aDecoder decodeObjectForKey:@"offset"]).CGSizeValue;
    _subShadow = [aDecoder decodeObjectForKey:@"subShadow"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.color = self.color;
    one.radius = self.radius;
    one.offset = self.offset;
    one.subShadow = self.subShadow.copy;
    return one;
}

@end










@implementation CSTextDecoration

- (instancetype)init {
    self = [super init];
    _style = CSTextLineStyleSingle;
    return self;
}

+ (instancetype)decorationWithStyle:(CSTextLineStyle)style {
    CSTextDecoration *one = [self new];
    one.style = style;
    return one;
}
+ (instancetype)decorationWithStyle:(CSTextLineStyle)style width:(NSNumber *)width color:(UIColor *)color {
    CSTextDecoration *one = [self new];
    one.style = style;
    one.width = width;
    one.color = color;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.style) forKey:@"style"];
    [aCoder encodeObject:self.width forKey:@"width"];
    [aCoder encodeObject:self.color forKey:@"color"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.style = ((NSNumber *)[aDecoder decodeObjectForKey:@"style"]).unsignedIntegerValue;
    self.width = [aDecoder decodeObjectForKey:@"width"];
    self.color = [aDecoder decodeObjectForKey:@"color"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.style = self.style;
    one.width = self.width;
    one.color = self.color;
    return one;
}










@end






//MARK:=============================CSTextHighlight============================
NSString *const kCSTextHighlightContent         = @"content";
NSString *const kCSTextHighlightRange           = @"range";
NSString *const kCSTextHighlightLinkColor       = @"linkColor";
NSString *const kCSTextHighlightHightlightColor = @"hightlightColor";
NSString *const kCSTextHighlightPositions       = @"positions";
NSString *const kCSTextHighlightUserInfo        = @"userInfo";
NSString *const kCSTextHighlightType            = @"type";

@implementation CSTextHighlight

- (instancetype)init {
    self = [super init];
    if (self) {
        self.content = nil;
        self.range = NSMakeRange(0, 0);
        self.linkColor = [UIColor clearColor];
        self.hightlightColor = [UIColor clearColor];
        self.positions = @[];
        self.userInfo = @{};
        self.type = CSTextHighlightTypeNormal;
    }
    return self;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:kCSTextHighlightContent];
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:kCSTextHighlightRange];
    [aCoder encodeObject:self.linkColor forKey:kCSTextHighlightLinkColor];
    [aCoder encodeObject:self.hightlightColor forKey:kCSTextHighlightHightlightColor];
    [aCoder encodeObject:self.positions forKey:kCSTextHighlightPositions];
    [aCoder encodeObject:self.userInfo forKey:kCSTextHighlightUserInfo];
    [aCoder encodeInteger:self.type forKey:kCSTextHighlightType];
    
    
    NSData *data = nil;
    @try {
        data = [CSTextArchiver archivedDataWithRootObject:self.attributes];
    }
    @catch (NSException *exception) {
        CSNSLog(@"%@",exception);
    }
    [aCoder encodeObject:data forKey:@"attributes"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:kCSTextHighlightContent];
        self.range = [[aDecoder decodeObjectForKey:kCSTextHighlightRange] rangeValue];
        self.linkColor = [aDecoder decodeObjectForKey:kCSTextHighlightLinkColor];
        self.hightlightColor = [aDecoder decodeObjectForKey:kCSTextHighlightHightlightColor];
        self.positions = [aDecoder decodeObjectForKey:kCSTextHighlightPositions];
        self.userInfo = [aDecoder decodeObjectForKey:kCSTextHighlightUserInfo];
        self.type = [aDecoder decodeIntegerForKey:kCSTextHighlightType];
        
        
        NSData *data = [aDecoder decodeObjectForKey:@"attributes"];
        @try {
            _attributes = [CSTextUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
            CSNSLog(@"%@",exception);
        }
    }
    return self;
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    //CSTextHighlight* highlight = [[CSTextHighlight alloc] init];
    typeof(self) highlight = [self.class new];
    if ([self.content conformsToProtocol:@protocol(NSCopying)]) {
        highlight.content = [self.content copy];
    }
    else {
        highlight.content = self.content;
    }
    highlight.range = self.range;
    highlight.linkColor = [self.linkColor copy];
    highlight.hightlightColor = [self.hightlightColor copy];
    highlight.positions = [self.positions copy];
    highlight.userInfo = [self.userInfo copy];
    highlight.type = self.type;
    
    highlight.attributes = self.attributes.mutableCopy;
    return highlight;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}


#pragma mark -
- (NSUInteger)hash {
    long v1 = (long)((__bridge void *)self.content);
    long v2 = (long)[NSValue valueWithRange:self.range];
    return v1 ^ v2;
}

- (BOOL)isEqual:(id)object{
    if (self == object) {
        return YES;
    }
    if (![object isMemberOfClass:self.class]){
        return NO;
    }
    CSTextHighlight* other = object;
    return other.content == _content && [NSValue valueWithRange:other.range] == [NSValue valueWithRange:self.range];
}



+ (instancetype)highlightWithAttributes:(NSDictionary *)attributes {
    CSTextHighlight *one = [self new];
    one.attributes = attributes;
    return one;
}

+ (instancetype)highlightWithBackgroundColor:(UIColor *)color {
    CSTextBorder *highlightBorder = [CSTextBorder new];
    highlightBorder.insets = UIEdgeInsetsMake(-2, -1, -2, -1);
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = color;
    
    CSTextHighlight *one = [self new];
    [one setBackgroundBorder:highlightBorder];
    return one;
}

- (void)setAttributes:(NSDictionary *)attributes {
    _attributes = attributes.mutableCopy;
}


- (void)_makeMutableAttributes {
    if (!_attributes) {
        _attributes = [NSMutableDictionary new];
    } else if (![_attributes isKindOfClass:[NSMutableDictionary class]]) {
        _attributes = _attributes.mutableCopy;
    }
}

- (void)setFont:(UIFont *)font {
    [self _makeMutableAttributes];
    if (font == (id)[NSNull null] || font == nil) {
        ((NSMutableDictionary *)_attributes)[(id)kCTFontAttributeName] = [NSNull null];
    } else {
        CTFontRef ctFont = [font CTFontRef];
        if (ctFont) {
            ((NSMutableDictionary *)_attributes)[(id)kCTFontAttributeName] = (__bridge id)(ctFont);
            CFRelease(ctFont);
        }
    }
}

- (void)setColor:(UIColor *)color {
    [self _makeMutableAttributes];
    if (color == (id)[NSNull null] || color == nil) {
        ((NSMutableDictionary *)_attributes)[(id)kCTForegroundColorAttributeName] = [NSNull null];
        ((NSMutableDictionary *)_attributes)[NSForegroundColorAttributeName] = [NSNull null];
    } else {
        ((NSMutableDictionary *)_attributes)[(id)kCTForegroundColorAttributeName] = (__bridge id)(color.CGColor);
        ((NSMutableDictionary *)_attributes)[NSForegroundColorAttributeName] = color;
    }
}

- (void)setStrokeWidth:(NSNumber *)width {
    [self _makeMutableAttributes];
    if (width == (id)[NSNull null] || width == nil) {
        ((NSMutableDictionary *)_attributes)[(id)kCTStrokeWidthAttributeName] = [NSNull null];
    } else {
        ((NSMutableDictionary *)_attributes)[(id)kCTStrokeWidthAttributeName] = width;
    }
}

- (void)setStrokeColor:(UIColor *)color {
    [self _makeMutableAttributes];
    if (color == (id)[NSNull null] || color == nil) {
        ((NSMutableDictionary *)_attributes)[(id)kCTStrokeColorAttributeName] = [NSNull null];
        ((NSMutableDictionary *)_attributes)[NSStrokeColorAttributeName] = [NSNull null];
    } else {
        ((NSMutableDictionary *)_attributes)[(id)kCTStrokeColorAttributeName] = (__bridge id)(color.CGColor);
        ((NSMutableDictionary *)_attributes)[NSStrokeColorAttributeName] = color;
    }
}

- (void)setTextAttribute:(NSString *)attribute value:(id)value {
    [self _makeMutableAttributes];
    if (value == nil) value = [NSNull null];
    ((NSMutableDictionary *)_attributes)[attribute] = value;
}

- (void)setShadow:(CSTextShadow *)shadow {
    [self setTextAttribute:CSTextShadowAttributeName value:shadow];
}

- (void)setInnerShadow:(CSTextShadow *)shadow {
    [self setTextAttribute:CSTextInnerShadowAttributeName value:shadow];
}

- (void)setUnderline:(CSTextDecoration *)underline {
    [self setTextAttribute:CSTextUnderlineAttributeName value:underline];
}

- (void)setStrikethrough:(CSTextDecoration *)strikethrough {
    [self setTextAttribute:CSTextStrikethroughAttributeName value:strikethrough];
}

- (void)setBackgroundBorder:(CSTextBorder *)border {
    [self setTextAttribute:CSTextBackgroundBorderAttributeName value:border];
}

- (void)setBorder:(CSTextBorder *)border {
    [self setTextAttribute:CSTextBorderAttributeName value:border];
}

- (void)setAttachment:(CSTextAttachment *)attachment {
    [self setTextAttribute:CSTextAttachmentAttributeName_text value:attachment];
}




@end
//MARK:=============================CSTextHighlight============================







//NSString *const kCSTextGlyphAscent = @"ascent";
//NSString *const kCSTextGlyphDescent = @"descent";
//NSString *const kCSTextGlyphGlyph = @"glyph";
//NSString *const kCSTextGlyphHeight = @"height";
//NSString *const kCSTextGlyphLeading = @"leading";
//NSString *const kCSTextGlyphPosition = @"position";
//NSString *const kCSTextGlyphWidth = @"width";
//
//@implementation CSTextGlyph
//
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        self.position = CGPointZero;
//        self.ascent = 0.0f;
//        self.descent = 0.0f;
//        self.leading = 0.0f;
//        self.width = 0.0f;
//        self.height = 0.0f;
//    }
//    return self;
//}
//
//
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeInteger:self.glyph forKey:kCSTextGlyphGlyph];
//    [aCoder encodeCGPoint:self.position forKey:kCSTextGlyphPosition];
//    [aCoder encodeObject:@(self.ascent) forKey:kCSTextGlyphAscent];
//    [aCoder encodeObject:@(self.descent) forKey:kCSTextGlyphDescent];
//    [aCoder encodeObject:@(self.leading) forKey:kCSTextGlyphLeading];
//    [aCoder encodeObject:@(self.width) forKey:kCSTextGlyphWidth];
//    [aCoder encodeObject:@(self.height) forKey:kCSTextGlyphHeight];
//}
//
//
//- (instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if (self) {
//        self.glyph = [aDecoder decodeIntegerForKey:kCSTextGlyphGlyph];
//        self.position = [aDecoder decodeCGPointForKey:kCSTextGlyphPosition];
//        self.ascent = [[aDecoder decodeObjectForKey:kCSTextGlyphAscent] floatValue];
//        self.descent = [[aDecoder decodeObjectForKey:kCSTextGlyphDescent] floatValue];
//        self.leading = [[aDecoder decodeObjectForKey:kCSTextGlyphLeading] floatValue];
//        self.width = [[aDecoder decodeObjectForKey:kCSTextGlyphWidth] floatValue];
//        self.height = [[aDecoder decodeObjectForKey:kCSTextGlyphHeight] floatValue];
//    }
//    
//    return self;
//}
//
//
//- (instancetype)copyWithZone:(NSZone *)zone
//{
//    CSTextGlyph *copy = [CSTextGlyph new];
//    
//    copy.glyph = self.glyph;
//    copy.position = self.position;
//    copy.ascent = self.ascent;
//    copy.descent = self.descent;
//    copy.leading = self.leading;
//    copy.width = self.width;
//    copy.height = self.height;
//    
//    return copy;
//}
//
//- (instancetype)mutableCopyWithZone:(NSZone *)zone {
//    return [self copyWithZone:zone];
//}
//
//@end











