//
//  NSObject+CSModel.m
//  CSCategory
//
//  Created by mac on 2017/6/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSObject+CSModel.h"
#import "CSClassInfo.h"
#import <objc/message.h>

#define force_inline __inline__ __attribute__((always_inline))


///MARK: Foundation Class Type
typedef NS_ENUM (NSUInteger, CSEncodingNSType) {
    CSEncodingTypeNSUnknown = 0,
    CSEncodingTypeNSString,
    CSEncodingTypeNSMutableString,
    CSEncodingTypeNSValue,
    CSEncodingTypeNSNumber,
    CSEncodingTypeNSDecimalNumber,
    CSEncodingTypeNSData,
    CSEncodingTypeNSMutableData,
    CSEncodingTypeNSDate,
    CSEncodingTypeNSURL,
    CSEncodingTypeNSArray,
    CSEncodingTypeNSMutableArray,
    CSEncodingTypeNSDictionary,
    CSEncodingTypeNSMutableDictionary,
    CSEncodingTypeNSSet,
    CSEncodingTypeNSMutableSet,
};

///MARK: 从属性信息获取基础类类型.
static force_inline CSEncodingNSType CSClassGetNSType(Class cls) {
    if (!cls) return CSEncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return CSEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return CSEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return CSEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return CSEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return CSEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return CSEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return CSEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return CSEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return CSEncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return CSEncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return CSEncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return CSEncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return CSEncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return CSEncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return CSEncodingTypeNSSet;
    return CSEncodingTypeNSUnknown;
}

///MARK: 类型是否为 C Number.
static force_inline BOOL CSEncodingTypeIsCNumber(CSEncodingType type) {
    switch (type & CSEncodingTypeMask) {
        case CSEncodingTypeBool:
        case CSEncodingTypeInt8:
        case CSEncodingTypeUInt8:
        case CSEncodingTypeInt16:
        case CSEncodingTypeUInt16:
        case CSEncodingTypeInt32:
        case CSEncodingTypeUInt32:
        case CSEncodingTypeInt64:
        case CSEncodingTypeUInt64:
        case CSEncodingTypeFloat:
        case CSEncodingTypeDouble:
        case CSEncodingTypeLongDouble: return YES;
        default: return NO;
    }
}

///MARK: 从'id'解析一个数值.
static force_inline NSNumber *CSNSNumberCreateFromID(__unsafe_unretained id value) {
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    
    if (!value || value == (id)kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[value];
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}

///MARK: 解析字符串到日期
static force_inline NSDate *CSNSDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate* (^CSNSDateParseBlock)(NSString *string);
#define kParserNum 34
    static CSNSDateParseBlock blocks[kParserNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            /*
             2014-01-20  // Google
             */
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"YYYY-MM-dd";
            blocks[10] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            /*
             2014-01-20 12:24:48
             2014-01-20T12:24:48   // Google
             2014-01-20 12:24:48.000
             2014-01-20T12:24:48.000
             */
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter3.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter3.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
            
            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };
            
            blocks[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                } else {
                    return [formatter4 dateFromString:string];
                }
            };
        }
        
        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             2014-01-20T12:24:48.000Z
             2014-01-20T12:24:48.000+0800
             2014-01-20T12:24:48.000+12:00
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            
            blocks[20] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[24] = ^(NSString *string) { return [formatter dateFromString:string]?: [formatter2 dateFromString:string]; };
            blocks[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[28] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
            blocks[29] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
        
        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             Fri Sep 04 00:12:21.000 +0800 2015
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";
            
            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[34] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
    });
    if (!string) return nil;
    if (string.length > kParserNum) return nil;
    CSNSDateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
#undef kParserNum
}


///MARK: 获取'NSBlock'类.
static force_inline Class CSNSBlockClass() {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^{};
        cls = ((NSObject *)block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls; // 当前是 "NSBlock"
}



///MARK: curreGet的ISO日期格式.
/**
 
 ISO8601 format example:
 2010-07-09T16:13:30+12:00
 2011-01-11T11:11:11+0000
 2011-01-26T19:06:43Z
 
 length: 20/24/25
 */
static force_inline NSDateFormatter *CSISODateFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return formatter;
}

///MARK: 从字典获取关键路径的值
/// dic是一个字典 NSDictionary, 所以 keyPath 不能为 nil.
static force_inline id CSValueForKeyPath(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *keyPaths) {
    id value = nil;
    for (NSUInteger i = 0, max = keyPaths.count; i < max; i++) {
        value = dic[keyPaths[i]];
        if (i + 1 < max) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                dic = value;
            } else {
                return nil;
            }
        }
    }
    return value;
}

///MARK: 从字典获取所有键(或键路径)的值
/// dic应该是NSDictionary
static force_inline id CSValueForMultiKeys(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *multiKeys) {
    id value = nil;
    for (NSString *key in multiKeys) {
        if ([key isKindOfClass:[NSString class]]) {
            value = dic[key];
            if (value) break;
        } else {
            value = CSValueForKeyPath(dic, (NSArray *)key);
            if (value) break;
        }
    }
    return value;
}









///MARK: 对象模型中的属性信息.
@interface _CSModelPropertyMeta : NSObject {
    @package
    NSString *_name;             ///< 属性名
    CSEncodingType _type;        ///< 属性的类型
    CSEncodingNSType _nsType;    ///< 属性的基本类型
    BOOL _isCNumber;             ///< 是否 C 数值
    Class _cls;                  ///< 属性类, or nil
    Class _genericCls;           ///< 容器的泛型类,如果没有通用类,则为nil
    SEL _getter;                 ///< getter,如果实例无法响应,则为nil
    SEL _setter;                 ///< setter,如果实例无法响应,则为nil
    BOOL _isKVCCompatible;       ///< YES如果它能够与键 - 值编码访问
    BOOL _isStructAvailableForKeyedArchiver; ///< 如果结构可以编码,则为YES keyed archiver/unarchiver
    BOOL _hasCustomClassFromDictionary; ///< class/generic class implements +modelCustomClassForDictionary:
    
    /*
     property->key:       _mappedToKey:key     _mappedToKeyPath:nil            _mappedToKeyArray:nil
     property->keyPath:   _mappedToKey:keyPath _mappedToKeyPath:keyPath(array) _mappedToKeyArray:nil
     property->keys:      _mappedToKey:keys[0] _mappedToKeyPath:nil/keyPath    _mappedToKeyArray:keys(array)
     */
    NSString *_mappedToKey;      ///< 映射到 key
    NSArray *_mappedToKeyPath;   ///< 映射到KeyPath (如果名称不是KeyPath 则为 nil)
    NSArray *_mappedToKeyArray;  ///< 键(NSString) 或 keyPath(NSArray)数组 (如果没有映射到多个键,则为 nil)
    CSClassPropertyInfo *_info;  ///< 属性信息
    _CSModelPropertyMeta *_next; ///< 下一个meta如果有多个属性映射到同一个键.
}
@end

@implementation _CSModelPropertyMeta

+ (instancetype)metaWithClassInfo:(CSClassInfo *)classInfo propertyInfo:(CSClassPropertyInfo *)propertyInfo generic:(Class)generic {
    
    // 支持具有协议名称的伪通用类
    if (!generic && propertyInfo.protocols) {
        for (NSString *protocol in propertyInfo.protocols) {
            Class cls = objc_getClass(protocol.UTF8String);
            if (cls) {
                generic = cls;
                break;
            }
        }
    }
    
    _CSModelPropertyMeta *meta = [self new];
    meta->_name = propertyInfo.name;
    meta->_type = propertyInfo.type;
    meta->_info = propertyInfo;
    meta->_genericCls = generic;
    
    if ((meta->_type & CSEncodingTypeMask) == CSEncodingTypeObject) {
        meta->_nsType = CSClassGetNSType(propertyInfo.cls);
    } else {
        meta->_isCNumber = CSEncodingTypeIsCNumber(meta->_type);
    }
    if ((meta->_type & CSEncodingTypeMask) == CSEncodingTypeStruct) {
        /*
         NSKeyedUnarchiver 似乎无法解码除了这些结构之外的NSValue:
         */
        static NSSet *types = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *set = [NSMutableSet new];
            // 32 bit
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];
            // 64 bit
            [set addObject:@"{CGSize=dd}"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGPoint=dd}{CGSize=dd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];
            types = set;
        });
        if ([types containsObject:propertyInfo.typeEncoding]) {
            meta->_isStructAvailableForKeyedArchiver = YES;
        }
    }
    meta->_cls = propertyInfo.cls;
    
    if (generic) {
        meta->_hasCustomClassFromDictionary = [generic respondsToSelector:@selector(modelCustomClassForDictionary:)];
    } else if (meta->_cls && meta->_nsType == CSEncodingTypeNSUnknown) {
        meta->_hasCustomClassFromDictionary = [meta->_cls respondsToSelector:@selector(modelCustomClassForDictionary:)];
    }
    
    if (propertyInfo.getter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.getter]) {
            meta->_getter = propertyInfo.getter;
        }
    }
    if (propertyInfo.setter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.setter]) {
            meta->_setter = propertyInfo.setter;
        }
    }
    
    if (meta->_getter && meta->_setter) {
        /*
         KVC 无效的 type:
         long double
         pointer (比如 SEL/CoreFoundation 对象)
         */
        switch (meta->_type & CSEncodingTypeMask) {
            case CSEncodingTypeBool:
            case CSEncodingTypeInt8:
            case CSEncodingTypeUInt8:
            case CSEncodingTypeInt16:
            case CSEncodingTypeUInt16:
            case CSEncodingTypeInt32:
            case CSEncodingTypeUInt32:
            case CSEncodingTypeInt64:
            case CSEncodingTypeUInt64:
            case CSEncodingTypeFloat:
            case CSEncodingTypeDouble:
            case CSEncodingTypeObject:
            case CSEncodingTypeClass:
            case CSEncodingTypeBlock:
            case CSEncodingTypeStruct:
            case CSEncodingTypeUnion: {
                meta->_isKVCCompatible = YES;
            } break;
            default: break;
        }
    }
    
    return meta;
}
@end


/*
 元类的定义：元类是类对象的类。
 简单说就是：
 
 当你给对象发送消息时，消息是在寻找这个对象的类的方法列表。
 当你给类发消息时，消息是在寻找这个类的元类的方法列表。
 元类是必不可少的，因为它存储了类的类方法。每个类都必须有独一无二的元类，因为每个类都有独一无二的类方法。
 */
/// 对象模型中的类信息.
@interface _CSModelMeta : NSObject {
    @package
    
    CSClassInfo *_classInfo;
    /// key: 映射键和键路径, Value:_CSModelPropertyMeta(受黑白名单影响的).
    NSDictionary *_mapper;
    /// Array<_CSModelPropertyMeta>, 这个模型的所有属性元(这个 Model 对象的属性).
    NSArray *_allPropertyMetas;
    /// Array<_CSModelPropertyMeta>, 属性元类映射到关键路径.
    NSArray *_keyPathPropertyMetas;
    /// Array<_CSModelPropertyMeta>, 属性元映射到多个键.
    NSArray *_multiKeysPropertyMetas;
    /// 映射 key (和 keyPath) 的数量, 与 _mapper.count 相同(要转换的属性个数).
    NSUInteger _keyMappedCount;
    /// 模型类类型.
    CSEncodingNSType _nsType;
    
    /** 以下bool值,是根据我们是否在 model 类中实现了对应的自定义转换方法来判断的,
     比如如果我们实现了'- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic',
     那么'_hasCustomTransformFromDictionary'的值就是YES了。
     */
    
    BOOL _hasCustomWillTransformFromDictionary;
    BOOL _hasCustomTransformFromDictionary;
    BOOL _hasCustomTransformToDictionary;
    BOOL _hasCustomClassFromDictionary;
}
@end

@implementation _CSModelMeta

- (instancetype)initWithClass:(Class)cls {
    CSClassInfo *classInfo = [CSClassInfo classInfoWithClass:cls];
    if (!classInfo) return nil;
    self = [super init];
    
    // 获取黑名单
    NSSet *blacklist = nil;
    if ([cls respondsToSelector:@selector(modelPropertyBlacklist)]) {
        NSArray *properties = [(id<CSModel>)cls modelPropertyBlacklist];
        if (properties) {
            blacklist = [NSSet setWithArray:properties];
        }
    }
    
    // 获取白名单
    NSSet *whitelist = nil;
    if ([cls respondsToSelector:@selector(modelPropertyWhitelist)]) {
        NSArray *properties = [(id<CSModel>)cls modelPropertyWhitelist];
        if (properties) {
            whitelist = [NSSet setWithArray:properties];
        }
    }
    
    // 获取容器属性的泛型类(获取容器类属性以及对应Class 的字典)
    NSDictionary *genericMapper = nil;
    if ([cls respondsToSelector:@selector(modelContainerPropertyGenericClass)]) {
        genericMapper = [(id<CSModel>)cls modelContainerPropertyGenericClass];
        if (genericMapper) {
            NSMutableDictionary *tmp = [NSMutableDictionary new];
            [genericMapper enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (![key isKindOfClass:[NSString class]]) return;
                Class meta = object_getClass(obj);
                if (!meta) return;
                if (class_isMetaClass(meta)) {
                    tmp[key] = obj;
                } else if ([obj isKindOfClass:[NSString class]]) {
                    Class cls = NSClassFromString(obj);
                    if (cls) {
                        tmp[key] = cls;
                    }
                }
            }];
            genericMapper = tmp;
        }
    }
    
    // 创建所有属性元.(获取要解析的属性,包括排除黑名单、验证白名单、验证是否有 getter 和 setter 等.)
    NSMutableDictionary *allPropertyMetas = [NSMutableDictionary new];
    CSClassInfo *curClassInfo = classInfo;
    while (curClassInfo && curClassInfo.superCls != nil) { // recursive parse super class, but ignore root class (NSObject/NSProxy)
        for (CSClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            if (!propertyInfo.name) continue;
            if (blacklist && [blacklist containsObject:propertyInfo.name]) continue;
            if (whitelist && ![whitelist containsObject:propertyInfo.name]) continue;
            _CSModelPropertyMeta *meta = [_CSModelPropertyMeta metaWithClassInfo:classInfo
                                                                    propertyInfo:propertyInfo
                                                                         generic:genericMapper[propertyInfo.name]];
            if (!meta || !meta->_name) continue;
            if (!meta->_getter || !meta->_setter) continue;
            if (allPropertyMetas[meta->_name]) continue;
            allPropertyMetas[meta->_name] = meta;
        }
        curClassInfo = curClassInfo.superClassInfo;
    }
    if (allPropertyMetas.count) _allPropertyMetas = allPropertyMetas.allValues.copy;
    
    // 创建映射器(如果有属性名和json中的键不一样的,为属性设置json中的key,也有可能是keyPath)
    NSMutableDictionary *mapper = [NSMutableDictionary new];
    NSMutableArray *keyPathPropertyMetas = [NSMutableArray new];
    NSMutableArray *multiKeysPropertyMetas = [NSMutableArray new];
    
    if ([cls respondsToSelector:@selector(modelCustomPropertyMapper)]) {
        NSDictionary *customMapper = [(id <CSModel>)cls modelCustomPropertyMapper];
        [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *mappedToKey, BOOL *stop) {
            _CSModelPropertyMeta *propertyMeta = allPropertyMetas[propertyName];
            if (!propertyMeta) return;
            [allPropertyMetas removeObjectForKey:propertyName];
            
            if ([mappedToKey isKindOfClass:[NSString class]]) {
                if (mappedToKey.length == 0) return;
                
                propertyMeta->_mappedToKey = mappedToKey;
                NSArray *keyPath = [mappedToKey componentsSeparatedByString:@"."];
                for (NSString *onePath in keyPath) {
                    if (onePath.length == 0) {
                        NSMutableArray *tmp = keyPath.mutableCopy;
                        [tmp removeObject:@""];
                        keyPath = tmp;
                        break;
                    }
                }
                if (keyPath.count > 1) {
                    propertyMeta->_mappedToKeyPath = keyPath;
                    [keyPathPropertyMetas addObject:propertyMeta];
                }
                propertyMeta->_next = mapper[mappedToKey] ?: nil;
                mapper[mappedToKey] = propertyMeta;
                
            } else if ([mappedToKey isKindOfClass:[NSArray class]]) {
                
                NSMutableArray *mappedToKeyArray = [NSMutableArray new];
                for (NSString *oneKey in ((NSArray *)mappedToKey)) {
                    if (![oneKey isKindOfClass:[NSString class]]) continue;
                    if (oneKey.length == 0) continue;
                    
                    NSArray *keyPath = [oneKey componentsSeparatedByString:@"."];
                    if (keyPath.count > 1) {
                        [mappedToKeyArray addObject:keyPath];
                    } else {
                        [mappedToKeyArray addObject:oneKey];
                    }
                    
                    if (!propertyMeta->_mappedToKey) {
                        propertyMeta->_mappedToKey = oneKey;
                        propertyMeta->_mappedToKeyPath = keyPath.count > 1 ? keyPath : nil;
                    }
                }
                if (!propertyMeta->_mappedToKey) return;
                
                propertyMeta->_mappedToKeyArray = mappedToKeyArray;
                [multiKeysPropertyMetas addObject:propertyMeta];
                
                propertyMeta->_next = mapper[mappedToKey] ?: nil;
                mapper[mappedToKey] = propertyMeta;
            }
        }];
    }
    
    [allPropertyMetas enumerateKeysAndObjectsUsingBlock:^(NSString *name, _CSModelPropertyMeta *propertyMeta, BOOL *stop) {
        propertyMeta->_mappedToKey = name;
        propertyMeta->_next = mapper[name] ?: nil;
        mapper[name] = propertyMeta;
    }];
    
    // 将allPropertyMetas中剩下的值添加到mapper中.(因为可能只有部分属性名和json中的键不一致,设置之后会从allPropertyMetas删除)
    if (mapper.count) _mapper = mapper;
    if (keyPathPropertyMetas) _keyPathPropertyMetas = keyPathPropertyMetas;
    if (multiKeysPropertyMetas) _multiKeysPropertyMetas = multiKeysPropertyMetas;
    
    
    // 其他属性赋值
    _classInfo = classInfo;
    _keyMappedCount = _allPropertyMetas.count;
    _nsType = CSClassGetNSType(cls);
    _hasCustomWillTransformFromDictionary = ([cls instancesRespondToSelector:@selector(modelCustomWillTransformFromDictionary:)]);
    _hasCustomTransformFromDictionary = ([cls instancesRespondToSelector:@selector(modelCustomTransformFromDictionary:)]);
    _hasCustomTransformToDictionary = ([cls instancesRespondToSelector:@selector(modelCustomTransformToDictionary:)]);
    _hasCustomClassFromDictionary = ([cls respondsToSelector:@selector(modelCustomClassForDictionary:)]);
    
    return self;
}

/// 返回缓存的模型类元
+ (instancetype)metaWithClass:(Class)cls {
    if (!cls) return nil;
    // 1、声明一个字典,用来存Model 类和类的信息,键是Model 名.
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    // 2、声明一个信号量
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        // 不要被这个方法唬住，它其实就是一个创建可变字典的方法，只不过是底层CF方法罢了
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        // 为信号量设置资源并发数
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    // 3、先从之前的字典中取要解析的Model 的类信息
    _CSModelMeta *meta = CFDictionaryGetValue(cache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(lock);
    // 4、如果从缓存中没取到，则说明以前没有缓存过
    if (!meta || meta->_classInfo.needUpdate) {
        // 5、没缓存过,就需要解析一下(很重要)
        meta = [[_CSModelMeta alloc] initWithClass:cls];
        if (meta) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            // 6、解析完，当然是要放进缓存中
            CFDictionarySetValue(cache, (__bridge const void *)(cls), (__bridge const void *)(meta));
            dispatch_semaphore_signal(lock);
        }
    }
    return meta;
}


/**
 上面代码的常规写法
 
 @param cls 赋值的类
 @return 类信息元
 */
+ (instancetype)metaWithClass2:(Class)cls
{
    if (!cls) return nil;
    static NSMutableDictionary *cache;
    static dispatch_once_t onceToken;
    static NSLock *lock;
    dispatch_once(&onceToken, ^{
        cache = [[NSMutableDictionary alloc] init];
        lock = [[NSLock alloc] init];
    });
    
    [lock lock];
    _CSModelMeta *meta = [cache valueForKey:NSStringFromClass(cls)];
    [lock unlock];
    // 这里的meta._classInfo.needUpdate可能有点问题，因为_classInfo是示例变量，并不能用点语法取到，要注意。
    if (!meta || meta->_classInfo.needUpdate) {
        meta = [[_CSModelMeta alloc] initWithClass:cls];
        if (meta) {
            [lock lock];
            [cache setValue:meta forKey:NSStringFromClass(cls)];
            [lock unlock];
        }
    }
    
    return meta;
}


@end



///MARK: 从属性获取号码
/**
 从属性获取号码
 在此函数返回前,消息发送者强引用参数
 
 @param model 不能为 nil
 @param meta  不能为 nil
 @return 数字对象,如果失败,则为nil
 */
static force_inline NSNumber *ModelCreateNumberFromProperty(__unsafe_unretained id model,
                                                            __unsafe_unretained _CSModelPropertyMeta *meta) {
    switch (meta->_type & CSEncodingTypeMask) {
        case CSEncodingTypeBool: {
            return @(((bool (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case CSEncodingTypeInt8: {
            return @(((int8_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case CSEncodingTypeUInt8: {
            return @(((uint8_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case CSEncodingTypeInt16: {
            return @(((int16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case CSEncodingTypeUInt16: {
            return @(((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case CSEncodingTypeInt32: {
            return @(((int32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case CSEncodingTypeUInt32: {
            return @(((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case CSEncodingTypeInt64: {
            return @(((int64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case CSEncodingTypeUInt64: {
            return @(((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case CSEncodingTypeFloat: {
            float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case CSEncodingTypeDouble: {
            double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case CSEncodingTypeLongDouble: {
            double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        default: return nil;
    }
}

///MARK: 设置号码为属性.
/**
 设置号码为属性.
 @discussion 在此函数返回之前,消息发送者强引用参数.
 @param model 不能为 nil.
 @param num   可以为 nil.
 @param meta  不能为 nil, meta.isCNumber 应该是 YES, meta.setter 不能为 nil.
 */
static force_inline void ModelSetNumberToProperty(__unsafe_unretained id model,
                                                  __unsafe_unretained NSNumber *num,
                                                  __unsafe_unretained _CSModelPropertyMeta *meta) {
    switch (meta->_type & CSEncodingTypeMask) {
        case CSEncodingTypeBool: {
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)model, meta->_setter, num.boolValue);
        } break;
        case CSEncodingTypeInt8: {
            ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)model, meta->_setter, (int8_t)num.charValue);
        } break;
        case CSEncodingTypeUInt8: {
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint8_t)num.unsignedCharValue);
        } break;
        case CSEncodingTypeInt16: {
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)model, meta->_setter, (int16_t)num.shortValue);
        } break;
        case CSEncodingTypeUInt16: {
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint16_t)num.unsignedShortValue);
        } break;
        case CSEncodingTypeInt32: {
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)model, meta->_setter, (int32_t)num.intValue);
        }
        case CSEncodingTypeUInt32: {
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint32_t)num.unsignedIntValue);
        } break;
        case CSEncodingTypeInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint64_t)num.longLongValue);
            }
        } break;
        case CSEncodingTypeUInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint64_t)num.unsignedLongLongValue);
            }
        } break;
        case CSEncodingTypeFloat: {
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model, meta->_setter, f);
        } break;
        case CSEncodingTypeDouble: {
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model, meta->_setter, d);
        } break;
        case CSEncodingTypeLongDouble: {
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model, meta->_setter, (long double)d);
        } // break; commented for code coverage in next line
        default: break;
    }
}

///MARK: 设定值与属性元模型.
/**
 设定值与属性元模型.
 
 @discussion 在此函数返回之前,消息发送者强引用参数.
 
 @param model 不能为 nil.
 @param value 不能为 nil, 但可以为NSNull.
 @param meta  不能为 nil, 而 meta->_setter 不能为 nil.
 */
static void ModelSetValueForProperty(__unsafe_unretained id model,
                                     __unsafe_unretained id value,
                                     __unsafe_unretained _CSModelPropertyMeta *meta) {
    if (meta->_isCNumber) {
        NSNumber *num = CSNSNumberCreateFromID(value);
        ModelSetNumberToProperty(model, num, meta);
        if (num) [num class]; // hold the number
    } else if (meta->_nsType) {
        if (value == (id)kCFNull) {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
        } else {
            switch (meta->_nsType) {
                case CSEncodingTypeNSString:
                case CSEncodingTypeNSMutableString: {
                    if ([value isKindOfClass:[NSString class]]) {
                        if (meta->_nsType == CSEncodingTypeNSString) {
                            
                            //这就是给model赋值
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        } else {
                            
                            
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, ((NSString *)value).mutableCopy);
                        }
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       (meta->_nsType == CSEncodingTypeNSString) ?
                                                                       ((NSNumber *)value).stringValue :
                                                                       ((NSNumber *)value).stringValue.mutableCopy);
                    } else if ([value isKindOfClass:[NSData class]]) {
                        NSMutableString *string = [[NSMutableString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, string);
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       (meta->_nsType == CSEncodingTypeNSString) ?
                                                                       ((NSURL *)value).absoluteString :
                                                                       ((NSURL *)value).absoluteString.mutableCopy);
                    } else if ([value isKindOfClass:[NSAttributedString class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       (meta->_nsType == CSEncodingTypeNSString) ?
                                                                       ((NSAttributedString *)value).string :
                                                                       ((NSAttributedString *)value).string.mutableCopy);
                    }
                } break;
                    
                case CSEncodingTypeNSValue:
                case CSEncodingTypeNSNumber:
                case CSEncodingTypeNSDecimalNumber: {
                    if (meta->_nsType == CSEncodingTypeNSNumber) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, CSNSNumberCreateFromID(value));
                    } else if (meta->_nsType == CSEncodingTypeNSDecimalNumber) {
                        if ([value isKindOfClass:[NSDecimalNumber class]]) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        } else if ([value isKindOfClass:[NSNumber class]]) {
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, decNum);
                        } else if ([value isKindOfClass:[NSString class]]) {
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:value];
                            NSDecimal dec = decNum.decimalValue;
                            if (dec._length == 0 && dec._isNegative) {
                                decNum = nil; // NaN
                            }
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, decNum);
                        }
                    } else { // CSEncodingTypeNSValue
                        if ([value isKindOfClass:[NSValue class]]) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        }
                    }
                } break;
                    
                case CSEncodingTypeNSData:
                case CSEncodingTypeNSMutableData: {
                    if ([value isKindOfClass:[NSData class]]) {
                        if (meta->_nsType == CSEncodingTypeNSData) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        } else {
                            NSMutableData *data = ((NSData *)value).mutableCopy;
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, data);
                        }
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                        if (meta->_nsType == CSEncodingTypeNSMutableData) {
                            data = ((NSData *)data).mutableCopy;
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, data);
                    }
                } break;
                    
                case CSEncodingTypeNSDate: {
                    if ([value isKindOfClass:[NSDate class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, CSNSDateFromString(value));
                    }
                } break;
                    
                case CSEncodingTypeNSURL: {
                    if ([value isKindOfClass:[NSURL class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                        NSString *str = [value stringByTrimmingCharactersInSet:set];
                        if (str.length == 0) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, nil);
                        } else {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, [[NSURL alloc] initWithString:str]);
                        }
                    }
                } break;
                    
                case CSEncodingTypeNSArray:
                case CSEncodingTypeNSMutableArray: {
                    if (meta->_genericCls) {
                        NSArray *valueArr = nil;
                        if ([value isKindOfClass:[NSArray class]]) valueArr = value;
                        else if ([value isKindOfClass:[NSSet class]]) valueArr = ((NSSet *)value).allObjects;
                        if (valueArr) {
                            NSMutableArray *objectArr = [NSMutableArray new];
                            for (id one in valueArr) {
                                if ([one isKindOfClass:meta->_genericCls]) {
                                    [objectArr addObject:one];
                                } else if ([one isKindOfClass:[NSDictionary class]]) {
                                    Class cls = meta->_genericCls;
                                    if (meta->_hasCustomClassFromDictionary) {
                                        cls = [cls modelCustomClassForDictionary:one];
                                        if (!cls) cls = meta->_genericCls; // for xcode code coverage
                                    }
                                    NSObject *newOne = [cls new];
                                    [newOne modelSetWithDictionary:one];
                                    if (newOne) [objectArr addObject:newOne];
                                }
                            }
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, objectArr);
                        }
                    } else {
                        if ([value isKindOfClass:[NSArray class]]) {
                            if (meta->_nsType == CSEncodingTypeNSArray) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                            } else {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                               meta->_setter,
                                                                               ((NSArray *)value).mutableCopy);
                            }
                        } else if ([value isKindOfClass:[NSSet class]]) {
                            if (meta->_nsType == CSEncodingTypeNSArray) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, ((NSSet *)value).allObjects);
                            } else {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                               meta->_setter,
                                                                               ((NSSet *)value).allObjects.mutableCopy);
                            }
                        }
                    }
                } break;
                    
                case CSEncodingTypeNSDictionary:
                case CSEncodingTypeNSMutableDictionary: {
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        if (meta->_genericCls) {
                            NSMutableDictionary *dic = [NSMutableDictionary new];
                            [((NSDictionary *)value) enumerateKeysAndObjectsUsingBlock:^(NSString *oneKey, id oneValue, BOOL *stop) {
                                if ([oneValue isKindOfClass:[NSDictionary class]]) {
                                    Class cls = meta->_genericCls;
                                    if (meta->_hasCustomClassFromDictionary) {
                                        cls = [cls modelCustomClassForDictionary:oneValue];
                                        if (!cls) cls = meta->_genericCls; // for xcode code coverage
                                    }
                                    NSObject *newOne = [cls new];
                                    [newOne modelSetWithDictionary:(id)oneValue];
                                    if (newOne) dic[oneKey] = newOne;
                                }
                            }];
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, dic);
                        } else {
                            if (meta->_nsType == CSEncodingTypeNSDictionary) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                            } else {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                               meta->_setter,
                                                                               ((NSDictionary *)value).mutableCopy);
                            }
                        }
                    }
                } break;
                    
                case CSEncodingTypeNSSet:
                case CSEncodingTypeNSMutableSet: {
                    NSSet *valueSet = nil;
                    if ([value isKindOfClass:[NSArray class]]) valueSet = [NSMutableSet setWithArray:value];
                    else if ([value isKindOfClass:[NSSet class]]) valueSet = ((NSSet *)value);
                    
                    if (meta->_genericCls) {
                        NSMutableSet *set = [NSMutableSet new];
                        for (id one in valueSet) {
                            if ([one isKindOfClass:meta->_genericCls]) {
                                [set addObject:one];
                            } else if ([one isKindOfClass:[NSDictionary class]]) {
                                Class cls = meta->_genericCls;
                                if (meta->_hasCustomClassFromDictionary) {
                                    cls = [cls modelCustomClassForDictionary:one];
                                    if (!cls) cls = meta->_genericCls; // for xcode code coverage
                                }
                                NSObject *newOne = [cls new];
                                [newOne modelSetWithDictionary:one];
                                if (newOne) [set addObject:newOne];
                            }
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, set);
                    } else {
                        if (meta->_nsType == CSEncodingTypeNSSet) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, valueSet);
                        } else {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           ((NSSet *)valueSet).mutableCopy);
                        }
                    }
                } // break; commented for code coverage in next line
                    
                default: break;
            }
        }
    } else {
        BOOL isNull = (value == (id)kCFNull);
        switch (meta->_type & CSEncodingTypeMask) {
            case CSEncodingTypeObject: {
                if (isNull) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
                } else if ([value isKindOfClass:meta->_cls] || !meta->_cls) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)value);
                } else if ([value isKindOfClass:[NSDictionary class]]) {
                    NSObject *one = nil;
                    if (meta->_getter) {
                        one = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
                    }
                    if (one) {
                        [one modelSetWithDictionary:value];
                    } else {
                        Class cls = meta->_cls;
                        if (meta->_hasCustomClassFromDictionary) {
                            cls = [cls modelCustomClassForDictionary:value];
                            if (!cls) cls = meta->_genericCls; // for xcode code coverage
                        }
                        one = [cls new];
                        [one modelSetWithDictionary:value];
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)one);
                    }
                }
            } break;
                
            case CSEncodingTypeClass: {
                if (isNull) {
                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)NULL);
                } else {
                    Class cls = nil;
                    if ([value isKindOfClass:[NSString class]]) {
                        cls = NSClassFromString(value);
                        if (cls) {
                            ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)cls);
                        }
                    } else {
                        cls = object_getClass(value);
                        if (cls) {
                            if (class_isMetaClass(cls)) {
                                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)value);
                            }
                        }
                    }
                }
            } break;
                
            case  CSEncodingTypeSEL: {
                if (isNull) {
                    ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, meta->_setter, (SEL)NULL);
                } else if ([value isKindOfClass:[NSString class]]) {
                    SEL sel = NSSelectorFromString(value);
                    if (sel) ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, meta->_setter, (SEL)sel);
                }
            } break;
                
            case CSEncodingTypeBlock: {
                if (isNull) {
                    ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)())NULL);
                } else if ([value isKindOfClass:CSNSBlockClass()]) {
                    ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)())value);
                }
            } break;
                
            case CSEncodingTypeStruct:
            case CSEncodingTypeUnion:
            case CSEncodingTypeCArray: {
                if ([value isKindOfClass:[NSValue class]]) {
                    const char *valueType = ((NSValue *)value).objCType;
                    const char *metaType = meta->_info.typeEncoding.UTF8String;
                    if (valueType && metaType && strcmp(valueType, metaType) == 0) {
                        [model setValue:value forKey:meta->_name];
                    }
                }
            } break;
                
            case CSEncodingTypePointer:
            case CSEncodingTypeCString: {
                if (isNull) {
                    ((void (*)(id, SEL, void *))(void *) objc_msgSend)((id)model, meta->_setter, (void *)NULL);
                } else if ([value isKindOfClass:[NSValue class]]) {
                    NSValue *nsValue = value;
                    if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
                        ((void (*)(id, SEL, void *))(void *) objc_msgSend)((id)model, meta->_setter, nsValue.pointerValue);
                    }
                }
            } // break; commented for code coverage in next line
                
            default: break;
        }
    }
}


typedef struct {
    void *modelMeta;  ///< _CSModelMeta
    void *model;      ///< id (self)
    void *dictionary; ///< NSDictionary (json)
} ModelSetContext;

///MARK: 应用字典功能,将键值对设置为模型.
/**
 应用字典功能,将键值对设置为模型.
 
 @param _key     不能为 nil, NSString.
 @param _value   不能为 nil.
 @param _context _context.modelMeta 和 _context.model 不能为 nil.
 */
static void ModelSetWithDictionaryFunction(const void *_key, const void *_value, void *_context) {
    ModelSetContext *context = _context;
    // 1.从上下文中取到model 的信息
    __unsafe_unretained _CSModelMeta *meta = (__bridge _CSModelMeta *)(context->modelMeta);
    // 2.从转换字典中取到属性对象
    __unsafe_unretained _CSModelPropertyMeta *propertyMeta = [meta->_mapper objectForKey:(__bridge id)(_key)];
    __unsafe_unretained id model = (__bridge id)(context->model);
    // 3.以防有多个相同key 的不同值
    while (propertyMeta) {
        if (propertyMeta->_setter) {
            // 为model 的该属性赋值
            ModelSetValueForProperty(model, (__bridge __unsafe_unretained id)_value, propertyMeta);
        }
        propertyMeta = propertyMeta->_next;
    };
}

///MARK: 应用模型属性元的功能,将字典设置为模型.
/**
 应用模型属性元的功能,将字典设置为模型.
 
 @param _propertyMeta 不能为 nil, _CSModelPropertyMeta.
 @param _context      _context.model 和 _context.dictionary  不能为 nil.
 */
static void ModelSetWithPropertyMetaArrayFunction(const void *_propertyMeta, void *_context) {
    ModelSetContext *context = _context;
    // 获取字典参数
    __unsafe_unretained NSDictionary *dictionary = (__bridge NSDictionary *)(context->dictionary);
    // 这里只是强转一下类型而已
    __unsafe_unretained _CSModelPropertyMeta *propertyMeta = (__bridge _CSModelPropertyMeta *)(_propertyMeta);
    if (!propertyMeta->_setter) return;
    id value = nil;
    
    // 这里因为value 的值，对象的可能有keyPath，也有直接的key。所以用不同的方式来取value
    if (propertyMeta->_mappedToKeyArray) {
        value = CSValueForMultiKeys(dictionary, propertyMeta->_mappedToKeyArray);
    } else if (propertyMeta->_mappedToKeyPath) {
        value = CSValueForKeyPath(dictionary, propertyMeta->_mappedToKeyPath);
    } else {
        value = [dictionary objectForKey:propertyMeta->_mappedToKey];
    }
    
    if (value) {
        // 获取model 的指针
        __unsafe_unretained id model = (__bridge id)(context->model);
        // 这里就是为model 赋值啦
        ModelSetValueForProperty(model, value, propertyMeta);
    }
}

///MARK: 返回一个有效的JSON对象
/**
 返回一个有效的JSON对象 (NSArray/NSDictionary/NSString/NSNumber/NSNull)
 
 @param model Model, 可以为 nil.
 @return JSON object, 如果发生错误则为nil.
 */
static id ModelToJSONObjectRecursive(NSObject *model) {
    if (!model || model == (id)kCFNull) return model;
    if ([model isKindOfClass:[NSString class]]) return model;
    if ([model isKindOfClass:[NSNumber class]]) return model;
    if ([model isKindOfClass:[NSDictionary class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableDictionary *newDic = [NSMutableDictionary new];
        [((NSDictionary *)model) enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            NSString *stringKey = [key isKindOfClass:[NSString class]] ? key : key.description;
            if (!stringKey) return;
            id jsonObj = ModelToJSONObjectRecursive(obj);
            if (!jsonObj) jsonObj = (id)kCFNull;
            newDic[stringKey] = jsonObj;
        }];
        return newDic;
    }
    if ([model isKindOfClass:[NSSet class]]) {
        NSArray *array = ((NSSet *)model).allObjects;
        if ([NSJSONSerialization isValidJSONObject:array]) return array;
        NSMutableArray *newArray = [NSMutableArray new];
        for (id obj in array) {
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [newArray addObject:obj];
            } else {
                id jsonObj = ModelToJSONObjectRecursive(obj);
                if (jsonObj && jsonObj != (id)kCFNull) [newArray addObject:jsonObj];
            }
        }
        return newArray;
    }
    if ([model isKindOfClass:[NSArray class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableArray *newArray = [NSMutableArray new];
        for (id obj in (NSArray *)model) {
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [newArray addObject:obj];
            } else {
                id jsonObj = ModelToJSONObjectRecursive(obj);
                if (jsonObj && jsonObj != (id)kCFNull) [newArray addObject:jsonObj];
            }
        }
        return newArray;
    }
    if ([model isKindOfClass:[NSURL class]]) return ((NSURL *)model).absoluteString;
    if ([model isKindOfClass:[NSAttributedString class]]) return ((NSAttributedString *)model).string;
    if ([model isKindOfClass:[NSDate class]]) return [CSISODateFormatter() stringFromDate:(id)model];
    if ([model isKindOfClass:[NSData class]]) return nil;
    
    
    _CSModelMeta *modelMeta = [_CSModelMeta metaWithClass:[model class]];
    if (!modelMeta || modelMeta->_keyMappedCount == 0) return nil;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:64];
    __unsafe_unretained NSMutableDictionary *dic = result; // avoid retain and release in block
    [modelMeta->_mapper enumerateKeysAndObjectsUsingBlock:^(NSString *propertyMappedKey, _CSModelPropertyMeta *propertyMeta, BOOL *stop) {
        if (!propertyMeta->_getter) return;
        
        id value = nil;
        if (propertyMeta->_isCNumber) {
            value = ModelCreateNumberFromProperty(model, propertyMeta);
        } else if (propertyMeta->_nsType) {
            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
            value = ModelToJSONObjectRecursive(v);
        } else {
            switch (propertyMeta->_type & CSEncodingTypeMask) {
                case CSEncodingTypeObject: {
                    id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    value = ModelToJSONObjectRecursive(v);
                    if (value == (id)kCFNull) value = nil;
                } break;
                case CSEncodingTypeClass: {
                    Class v = ((Class (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    value = v ? NSStringFromClass(v) : nil;
                } break;
                case CSEncodingTypeSEL: {
                    SEL v = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    value = v ? NSStringFromSelector(v) : nil;
                } break;
                default: break;
            }
        }
        if (!value) return;
        
        if (propertyMeta->_mappedToKeyPath) {
            NSMutableDictionary *superDic = dic;
            NSMutableDictionary *subDic = nil;
            for (NSUInteger i = 0, max = propertyMeta->_mappedToKeyPath.count; i < max; i++) {
                NSString *key = propertyMeta->_mappedToKeyPath[i];
                if (i + 1 == max) { // end
                    if (!superDic[key]) superDic[key] = value;
                    break;
                }
                
                subDic = superDic[key];
                if (subDic) {
                    if ([subDic isKindOfClass:[NSDictionary class]]) {
                        subDic = subDic.mutableCopy;
                        superDic[key] = subDic;
                    } else {
                        break;
                    }
                } else {
                    subDic = [NSMutableDictionary new];
                    superDic[key] = subDic;
                }
                superDic = subDic;
                subDic = nil;
            }
        } else {
            if (!dic[propertyMeta->_mappedToKey]) {
                dic[propertyMeta->_mappedToKey] = value;
            }
        }
    }];
    
    if (modelMeta->_hasCustomTransformToDictionary) {
        BOOL suc = [((id<CSModel>)model) modelCustomTransformToDictionary:dic];
        if (!suc) return nil;
    }
    return result;
}

///MARK: 向字符串添加缩进（排除第一行）
static NSMutableString *ModelDescriptionAddIndent(NSMutableString *desc, NSUInteger indent) {
    for (NSUInteger i = 0, max = desc.length; i < max; i++) {
        unichar c = [desc characterAtIndex:i];
        if (c == '\n') {
            for (NSUInteger j = 0; j < indent; j++) {
                [desc insertString:@"    " atIndex:i + 1];
            }
            i += indent * 4;
            max += indent * 4;
        }
    }
    return desc;
}

/// 生成描述字符串
static NSString *ModelDescription(NSObject *model) {
    static const int kDescMaxLength = 100;
    if (!model) return @"<nil>";
    if (model == (id)kCFNull) return @"<null>";
    if (![model isKindOfClass:[NSObject class]]) return [NSString stringWithFormat:@"%@",model];
    
    
    _CSModelMeta *modelMeta = [_CSModelMeta metaWithClass:model.class];
    switch (modelMeta->_nsType) {
        case CSEncodingTypeNSString: case CSEncodingTypeNSMutableString: {
            return [NSString stringWithFormat:@"\"%@\"",model];
        }
            
        case CSEncodingTypeNSValue:
        case CSEncodingTypeNSData: case CSEncodingTypeNSMutableData: {
            NSString *tmp = model.description;
            if (tmp.length > kDescMaxLength) {
                tmp = [tmp substringToIndex:kDescMaxLength];
                tmp = [tmp stringByAppendingString:@"..."];
            }
            return tmp;
        }
            
        case CSEncodingTypeNSNumber:
        case CSEncodingTypeNSDecimalNumber:
        case CSEncodingTypeNSDate:
        case CSEncodingTypeNSURL: {
            return [NSString stringWithFormat:@"%@",model];
        }
            
        case CSEncodingTypeNSSet: case CSEncodingTypeNSMutableSet: {
            model = ((NSSet *)model).allObjects;
        } // no break
            
        case CSEncodingTypeNSArray: case CSEncodingTypeNSMutableArray: {
            NSArray *array = (id)model;
            NSMutableString *desc = [NSMutableString new];
            if (array.count == 0) {
                return [desc stringByAppendingString:@"[]"];
            } else {
                [desc appendFormat:@"[\n"];
                for (NSUInteger i = 0, max = array.count; i < max; i++) {
                    NSObject *obj = array[i];
                    [desc appendString:@"    "];
                    [desc appendString:ModelDescriptionAddIndent(ModelDescription(obj).mutableCopy, 1)];
                    [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
                }
                [desc appendString:@"]"];
                return desc;
            }
        }
        case CSEncodingTypeNSDictionary: case CSEncodingTypeNSMutableDictionary: {
            NSDictionary *dic = (id)model;
            NSMutableString *desc = [NSMutableString new];
            if (dic.count == 0) {
                return [desc stringByAppendingString:@"{}"];
            } else {
                NSArray *keys = dic.allKeys;
                
                [desc appendFormat:@"{\n"];
                for (NSUInteger i = 0, max = keys.count; i < max; i++) {
                    NSString *key = keys[i];
                    NSObject *value = dic[key];
                    [desc appendString:@"    "];
                    [desc appendFormat:@"%@ = %@",key, ModelDescriptionAddIndent(ModelDescription(value).mutableCopy, 1)];
                    [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
                }
                [desc appendString:@"}"];
            }
            return desc;
        }
            
        default: {
            NSMutableString *desc = [NSMutableString new];
            [desc appendFormat:@"<%@: %p>", model.class, model];
            if (modelMeta->_allPropertyMetas.count == 0) return desc;
            
            // 排序属性名称
            NSArray *properties = [modelMeta->_allPropertyMetas
                                   sortedArrayUsingComparator:^NSComparisonResult(_CSModelPropertyMeta *p1, _CSModelPropertyMeta *p2) {
                                       return [p1->_name compare:p2->_name];
                                   }];
            
            [desc appendFormat:@" {\n"];
            for (NSUInteger i = 0, max = properties.count; i < max; i++) {
                _CSModelPropertyMeta *property = properties[i];
                NSString *propertyDesc;
                if (property->_isCNumber) {
                    NSNumber *num = ModelCreateNumberFromProperty(model, property);
                    propertyDesc = num.stringValue;
                } else {
                    switch (property->_type & CSEncodingTypeMask) {
                        case CSEncodingTypeObject: {
                            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = ModelDescription(v);
                            if (!propertyDesc) propertyDesc = @"<nil>";
                        } break;
                        case CSEncodingTypeClass: {
                            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = ((NSObject *)v).description;
                            if (!propertyDesc) propertyDesc = @"<nil>";
                        } break;
                        case CSEncodingTypeSEL: {
                            SEL sel = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            if (sel) propertyDesc = NSStringFromSelector(sel);
                            else propertyDesc = @"<NULL>";
                        } break;
                        case CSEncodingTypeBlock: {
                            id block = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = block ? ((NSObject *)block).description : @"<nil>";
                        } break;
                        case CSEncodingTypeCArray: case CSEncodingTypeCString: case CSEncodingTypePointer: {
                            void *pointer = ((void* (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = [NSString stringWithFormat:@"%p",pointer];
                        } break;
                        case CSEncodingTypeStruct: case CSEncodingTypeUnion: {
                            NSValue *value = [model valueForKey:property->_name];
                            propertyDesc = value ? value.description : @"{unknown}";
                        } break;
                        default: propertyDesc = @"<unknown>";
                    }
                }
                
                propertyDesc = ModelDescriptionAddIndent(propertyDesc.mutableCopy, 1);
                [desc appendFormat:@"    %@ = %@",property->_name, propertyDesc];
                [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
            }
            [desc appendFormat:@"}"];
            return desc;
        }
    }
}




@implementation NSObject (CSModel)


+ (NSDictionary *)_cs_dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}

/**
 从json创建并返回接收器的新实例(线程安全).
 
 @param json 'NSDictionary','NSString' 或 'NSData' 中的 json.
 @return 从json创建的新实例,如果发生错误,则为nil.
 */
+ (instancetype)modelWithJSON:(id)json {
    NSDictionary *dic = [self _cs_dictionaryWithJSON:json];
    return [self modelWithDictionary:dic];
}

/**
 从键值字典创建并返回接收器的新实例(线程安全).
 
 tip:
 dictionary中的键将映射到接受者的属性名称,并将该值设置为该属性.
 如果只的类型不匹配属性,此方法将根据以下规则转换值:
 
 'NSString' 或 'NSNumber' -> c 数值, 例如 BOOL, int, long, float, NSUInteger...
 'NSString' -> NSDate, 解析为格式 "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss" 或 "yyyy-MM-dd".
 'NSString' -> NSURL.
 'NSValue' -> 结构或者联合值 如: CGRect, CGSize, ...
 'NSString' -> SEL, Class.
 
 
 @param dictionary 一个键值字典映射到实例的属性(字典中的任何无效键值对都将被忽略)
 @return 从字典创建的新实例,如果发生错误,则为nil.
 */
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    // 首先校验参数
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    // 这里的cls 就是我们的实际model 类型
    Class cls = [self class];
    // 这一步,是重中之重,通过 class 获取到各种信息,然后封装到_CSModelMeta中
    _CSModelMeta *modelMeta = [_CSModelMeta metaWithClass:cls];
    if (modelMeta->_hasCustomClassFromDictionary) {
        cls = [cls modelCustomClassForDictionary:dictionary] ?: cls;
    }
    
    NSObject *one = [cls new];
    // 这里也是极为关键的一步,转换 model 并赋值
    if ([one modelSetWithDictionary:dictionary]) return one;
    return nil;
}

/**
 使用json对象设置接收者的属性(json中的任何无效数据都将被忽略)
 
 @param json 将"NSDictionary”,"NSString”或"NSData”的json对象映射到接收者的属性
 @return 是否成功
 */
- (BOOL)modelSetWithJSON:(id)json {
    NSDictionary *dic = [NSObject _cs_dictionaryWithJSON:json];
    return [self modelSetWithDictionary:dic];
}

/**
 使用键值字典设置接收者的属性
 
 tip:
 如果只的类型不匹配属性,此方法将根据以下规则转换值:
 
 'NSString' 或 'NSNumber' -> c 数值, 例如 BOOL, int, long, float, NSUInteger...
 'NSString' -> NSDate, 解析为格式 "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss" 或 "yyyy-MM-dd".
 'NSString' -> NSURL.
 'NSValue' -> 结构或者联合值 如: CGRect, CGSize, ...
 'NSString' -> SEL, Class.
 
 @param dic 映射到接收者属性的键值字典(字典中的任何无效键值对都将被忽略).
 @return 是否成功
 */
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    // 1.校验dic
    if (!dic || dic == (id)kCFNull) return NO;
    if (![dic isKindOfClass:[NSDictionary class]]) return NO;
    
    /**
     获取类信息，这里如果使用的是原来的类，则其实是从缓存中取出来的，因为在前面已经调用过metaWithClass方法了。
     如果是设置了转换的类，则可能会再重新完整执行一次metaWithClass。
     */
    _CSModelMeta *modelMeta = [_CSModelMeta metaWithClass:object_getClass(self)];
    if (modelMeta->_keyMappedCount == 0) return NO;
    
    if (modelMeta->_hasCustomWillTransformFromDictionary) {
        dic = [((id<CSModel>)self) modelCustomWillTransformFromDictionary:dic];
        if (![dic isKindOfClass:[NSDictionary class]]) return NO;
    }
    
    // 2.自定义的一个context 结构体，把model 的信息、model 对象指针、以及参数字典赋值上
    ModelSetContext context = {0};
    context.modelMeta = (__bridge void *)(modelMeta);
    context.model = (__bridge void *)(self);
    context.dictionary = (__bridge void *)(dic);
    
    if (modelMeta->_keyMappedCount >= CFDictionaryGetCount((CFDictionaryRef)dic)) {
        // 对于字典里的每一个键值对,都会调用一次applier 方法
        // void CFDictionaryApplyFunction(CFDictionaryRef theDict, CFDictionaryApplierFunction CF_NOESCAPE applier, void *context);
        CFDictionaryApplyFunction((CFDictionaryRef)dic, ModelSetWithDictionaryFunction, &context);
        if (modelMeta->_keyPathPropertyMetas) {
            
            // 对于数组中指定range返回的每一个元素调用一次applier
            // void CFArrayApplyFunction(CFArrayRef theArray, CFRange range, CFArrayApplierFunction CF_NOESCAPE applier, void *context);
            CFArrayApplyFunction((CFArrayRef)modelMeta->_keyPathPropertyMetas,
                                 CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_keyPathPropertyMetas)),
                                 ModelSetWithPropertyMetaArrayFunction,
                                 &context);
        }
        if (modelMeta->_multiKeysPropertyMetas) {
            CFArrayApplyFunction((CFArrayRef)modelMeta->_multiKeysPropertyMetas,
                                 CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_multiKeysPropertyMetas)),
                                 ModelSetWithPropertyMetaArrayFunction,
                                 &context);
        }
    } else {
        // 如果转换属性个数小于字典里个键值对个数
        CFArrayApplyFunction((CFArrayRef)modelMeta->_allPropertyMetas,
                             CFRangeMake(0, modelMeta->_keyMappedCount),
                             ModelSetWithPropertyMetaArrayFunction,
                             &context);
    }
    
    // 最后，如果有一些特殊的属性，需要自己转换赋值的话，再处理一下
    if (modelMeta->_hasCustomTransformFromDictionary) {
        return [((id<CSModel>)self) modelCustomTransformFromDictionary:dic];
    }
    return YES;
}

/**
 模型转换成 json 字符串.
 
 有关详细信息,请参阅[NSJSONSerialization isValidJSONObject].
  
 @discussion 任何无效的属性都被忽略. 如果reciver是'NSArray','NSDictionary'或'NSSet',它只是转换内部对象为json对象.
 
 @return 'NSDictionary'或'NSArray'中的一个json对象,如果发生错误,则为nil.
 */
- (id)modelToJSONObject {
    /*
     官方解析:
       顶级对象是NSArray或NSDictionary。
       所有对象都是NSString,NSNumber,NSArray,NSDictionary或NSNull的实例.
       所有字典键都是NSString的实例.
       数字不是NaN或无穷大.
     */
    id jsonObject = ModelToJSONObjectRecursive(self);
    if ([jsonObject isKindOfClass:[NSArray class]]) return jsonObject;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) return jsonObject;
    return nil;
}

/**
 从接收者的属性生成一个json字符串的数据.
 
 @return 一个json字符串的数据,如果发生错误,则为nil.
 
 @discussion 任何无效的属性都被忽略.如果reciver是'NSArray','NSDictionary'或'NSSet',它也会转换内部对象到json字符串.
 */
- (NSData *)modelToJSONData {
    id jsonObject = [self modelToJSONObject];
    if (!jsonObject) return nil;
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
}

/**
 从接收者的属性生成一个json字符串.
 
 @return 一个json字符串的数据,如果发生错误,则为nil.
 
 @discussion 任何无效的属性都被忽略.如果reciver是'NSArray','NSDictionary'或'NSSet',它也会转换内部对象到json字符串.
 */
- (NSString *)modelToJSONString {
    NSData *jsonData = [self modelToJSONData];
    if (jsonData.length == 0) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/**
 复制具有接收者属性的实例.
 
 @return 复制的实例,如果发生错误,则为nil.
 */
- (id)modelCopy{
    if (self == (id)kCFNull) return self;
    _CSModelMeta *modelMeta = [_CSModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return [self copy];
    
    NSObject *one = [self.class new];
    for (_CSModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_getter || !propertyMeta->_setter) continue;
        
        if (propertyMeta->_isCNumber) {
            switch (propertyMeta->_type & CSEncodingTypeMask) {
                case CSEncodingTypeBool: {
                    bool num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case CSEncodingTypeInt8:
                case CSEncodingTypeUInt8: {
                    uint8_t num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case CSEncodingTypeInt16:
                case CSEncodingTypeUInt16: {
                    uint16_t num = ((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case CSEncodingTypeInt32:
                case CSEncodingTypeUInt32: {
                    uint32_t num = ((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case CSEncodingTypeInt64:
                case CSEncodingTypeUInt64: {
                    uint64_t num = ((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case CSEncodingTypeFloat: {
                    float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case CSEncodingTypeDouble: {
                    double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case CSEncodingTypeLongDouble: {
                    long double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } // break; commented for code coverage in next line
                default: break;
            }
        } else {
            switch (propertyMeta->_type & CSEncodingTypeMask) {
                case CSEncodingTypeObject:
                case CSEncodingTypeClass:
                case CSEncodingTypeBlock: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case CSEncodingTypeSEL:
                case CSEncodingTypePointer:
                case CSEncodingTypeCString: {
                    size_t value = ((size_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, size_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case CSEncodingTypeStruct:
                case CSEncodingTypeUnion: {
                    @try {
                        NSValue *value = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                        if (value) {
                            [one setValue:value forKey:propertyMeta->_name];
                        }
                    } @catch (NSException *exception) {}
                } // break; commented for code coverage in next line
                default: break;
            }
        }
    }
    return one;
}

/**
 将接收器的属性编码为编码器.
 
 @param aCoder 一个归档对象.
 */
- (void)modelEncodeWithCoder:(NSCoder *)aCoder {
    if (!aCoder) return;
    if (self == (id)kCFNull) {
        [((id<NSCoding>)self)encodeWithCoder:aCoder];
        return;
    }
    
    _CSModelMeta *modelMeta = [_CSModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) {
        [((id<NSCoding>)self)encodeWithCoder:aCoder];
        return;
    }
    
    for (_CSModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_getter) return;
        
        if (propertyMeta->_isCNumber) {
            NSNumber *value = ModelCreateNumberFromProperty(self, propertyMeta);
            if (value) [aCoder encodeObject:value forKey:propertyMeta->_name];
        } else {
            switch (propertyMeta->_type & CSEncodingTypeMask) {
                case CSEncodingTypeObject: {
                    id value = ((id (*)(id, SEL))(void *)objc_msgSend)((id)self, propertyMeta->_getter);
                    if (value && (propertyMeta->_nsType || [value respondsToSelector:@selector(encodeWithCoder:)])) {
                        if ([value isKindOfClass:[NSValue class]]) {
                            if ([value isKindOfClass:[NSNumber class]]) {
                                [aCoder encodeObject:value forKey:propertyMeta->_name];
                            }
                        } else {
                            [aCoder encodeObject:value forKey:propertyMeta->_name];
                        }
                    }
                } break;
                case CSEncodingTypeSEL: {
                    SEL value = ((SEL (*)(id, SEL))(void *)objc_msgSend)((id)self, propertyMeta->_getter);
                    if (value) {
                        NSString *str = NSStringFromSelector(value);
                        [aCoder encodeObject:str forKey:propertyMeta->_name];
                    }
                } break;
                case CSEncodingTypeStruct:
                case CSEncodingTypeUnion: {
                    if (propertyMeta->_isKVCCompatible && propertyMeta->_isStructAvailableForKeyedArchiver) {
                        @try {
                            NSValue *value = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                            [aCoder encodeObject:value forKey:propertyMeta->_name];
                        } @catch (NSException *exception) {}
                    }
                } break;
                    
                default:
                    break;
            }
        }
    }
}

/**
 从解码器解码接收机的属性.
 
 @param aDecoder  一个归档对象.
 
 @return self
 */
- (id)modelInitWithCoder:(NSCoder *)aDecoder {
    if (!aDecoder) return self;
    if (self == (id)kCFNull) return self;
    _CSModelMeta *modelMeta = [_CSModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return self;
    
    for (_CSModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_setter) continue;
        
        if (propertyMeta->_isCNumber) {
            NSNumber *value = [aDecoder decodeObjectForKey:propertyMeta->_name];
            if ([value isKindOfClass:[NSNumber class]]) {
                ModelSetNumberToProperty(self, value, propertyMeta);
                [value class];
            }
        } else {
            CSEncodingType type = propertyMeta->_type & CSEncodingTypeMask;
            switch (type) {
                case CSEncodingTypeObject: {
                    id value = [aDecoder decodeObjectForKey:propertyMeta->_name];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)self, propertyMeta->_setter, value);
                } break;
                case CSEncodingTypeSEL: {
                    NSString *str = [aDecoder decodeObjectForKey:propertyMeta->_name];
                    if ([str isKindOfClass:[NSString class]]) {
                        SEL sel = NSSelectorFromString(str);
                        ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_setter, sel);
                    }
                } break;
                case CSEncodingTypeStruct:
                case CSEncodingTypeUnion: {
                    if (propertyMeta->_isKVCCompatible) {
                        @try {
                            NSValue *value = [aDecoder decodeObjectForKey:propertyMeta->_name];
                            if (value) [self setValue:value forKey:propertyMeta->_name];
                        } @catch (NSException *exception) {}
                    }
                } break;
                    
                default:
                    break;
            }
        }
    }
    return self;
}

/**
 获取接收者属性的哈希值.
 
 @return Hash 哈希值码.
 */
- (NSUInteger)modelHash {
    if (self == (id)kCFNull) return [self hash];
    _CSModelMeta *modelMeta = [_CSModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return [self hash];
    
    NSUInteger value = 0;
    NSUInteger count = 0;
    for (_CSModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_isKVCCompatible) continue;
        value ^= [[self valueForKey:NSStringFromSelector(propertyMeta->_getter)] hash];
        count++;
    }
    if (count == 0) value = (long)((__bridge void *)self);
    return value;
}

/**
 基于属性,将接收器与另一个对象进行比较以实现相等.
 
 @param model  另一个对象.
 
 @return 'YES' 如果接收者等于对象,否则 'NO'.
 */
- (BOOL)modelIsEqual:(id)model {
    if (self == model) return YES;
    if (![model isMemberOfClass:self.class]) return NO;
    _CSModelMeta *modelMeta = [_CSModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return [self isEqual:model];
    if ([self hash] != [model hash]) return NO;
    
    for (_CSModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_isKVCCompatible) continue;
        id this = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        id that = [model valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        if (this == that) continue;
        if (this == nil || that == nil) return NO;
        if (![this isEqual:that]) return NO;
    }
    return YES;
}

/**
 基于属性进行调试的描述方法.
 
 @return 描述接收器内容的字符串.
 */
- (NSString *)modelDescription {
    return ModelDescription(self);
}



/**
 解密
 
 @param response 网络数据
 @return 解密结果
 */
+ (NSString *)decreptResponse:(NSString *)response{
    return response;
}




@end




@implementation NSArray (CSModel)

/**
 从json数组创建并返回一个数组(线程安全).
 
 Example: [{"name","Mary"},{name:"Joe"}]
 
 @param cls 数组中存储的转化实例类
 @param json 标准的 NSArray JSON
 @return 模型数组,如果发生错误则返回 nil
 */
+ (NSArray *)modelArrayWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSArray *arr = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSArray class]]) {
        arr = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![arr isKindOfClass:[NSArray class]]) arr = nil;
    }
    return [self modelArrayWithClass:cls array:arr];
}

+ (NSArray *)modelArrayWithClass:(Class)cls array:(NSArray *)arr {
    if (!cls || !arr) return nil;
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *dic in arr) {
        if (![dic isKindOfClass:[NSDictionary class]]) continue;
        NSObject *obj = [cls modelWithDictionary:dic];
        if (obj) [result addObject:obj];
    }
    return result;
}

@end


@implementation NSDictionary (CSModel)

/**
 从json创建并返回一个字典(线程安全).
 
 Example: {"user1":{"name","Mary"}, "user2": {name:"Joe"}}
 
 @param cls 实例字典中的类
 @param json 标准字典 JSON
 @return 字典,如果发生错误则返回 nil
 */
+ (NSDictionary *)modelDictionaryWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return [self modelDictionaryWithClass:cls dictionary:dic];
}

+ (NSDictionary *)modelDictionaryWithClass:(Class)cls dictionary:(NSDictionary *)dic {
    if (!cls || !dic) return nil;
    NSMutableDictionary *result = [NSMutableDictionary new];
    for (NSString *key in dic.allKeys) {
        if (![key isKindOfClass:[NSString class]]) continue;
        NSObject *obj = [cls modelWithDictionary:dic[key]];
        if (obj) result[key] = obj;
    }
    return result;
}

@end




