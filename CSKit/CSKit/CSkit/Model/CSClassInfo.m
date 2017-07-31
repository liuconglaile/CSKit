//
//  CSClassInfo.m
//  CSCategory
//
//  Created by mac on 2017/6/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSClassInfo.h"
#import <objc/runtime.h>

CSEncodingType CSEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return CSEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return CSEncodingTypeUnknown;
    
    CSEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= CSEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= CSEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= CSEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= CSEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= CSEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= CSEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= CSEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return CSEncodingTypeUnknown | qualifier;
    
    switch (*type) {
        case 'v': return CSEncodingTypeVoid | qualifier;
        case 'B': return CSEncodingTypeBool | qualifier;
        case 'c': return CSEncodingTypeInt8 | qualifier;
        case 'C': return CSEncodingTypeUInt8 | qualifier;
        case 's': return CSEncodingTypeInt16 | qualifier;
        case 'S': return CSEncodingTypeUInt16 | qualifier;
        case 'i': return CSEncodingTypeInt32 | qualifier;
        case 'I': return CSEncodingTypeUInt32 | qualifier;
        case 'l': return CSEncodingTypeInt32 | qualifier;
        case 'L': return CSEncodingTypeUInt32 | qualifier;
        case 'q': return CSEncodingTypeInt64 | qualifier;
        case 'Q': return CSEncodingTypeUInt64 | qualifier;
        case 'f': return CSEncodingTypeFloat | qualifier;
        case 'd': return CSEncodingTypeDouble | qualifier;
        case 'D': return CSEncodingTypeLongDouble | qualifier;
        case '#': return CSEncodingTypeClass | qualifier;
        case ':': return CSEncodingTypeSEL | qualifier;
        case '*': return CSEncodingTypeCString | qualifier;
        case '^': return CSEncodingTypePointer | qualifier;
        case '[': return CSEncodingTypeCArray | qualifier;
        case '(': return CSEncodingTypeUnion | qualifier;
        case '{': return CSEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return CSEncodingTypeBlock | qualifier;
            else
                return CSEncodingTypeObject | qualifier;
        }
        default: return CSEncodingTypeUnknown | qualifier;
    }
}

///MARK: 实例变量信息
@implementation CSClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    self = [super init];
    _ivar = ivar;
    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    _offset = ivar_getOffset(ivar);
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = CSEncodingGetType(typeEncoding);
    }
    return self;
}

@end


///MARK: 方法信息
@implementation CSClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
    if (!method) return nil;
    self = [super init];
    _method = method;
    _sel = method_getName(method);
    _imp = method_getImplementation(method);
    const char *name = sel_getName(_sel);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    char *returnType = method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    unsigned int argumentCount = method_getNumberOfArguments(method);
    if (argumentCount > 0) {
        NSMutableArray *argumentTypes = [NSMutableArray new];
        for (unsigned int i = 0; i < argumentCount; i++) {
            char *argumentType = method_copyArgumentType(method, i);
            NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
            [argumentTypes addObject:type ? type : @""];
            if (argumentType) free(argumentType);
        }
        _argumentTypeEncodings = argumentTypes;
    }
    return self;
}

@end

///MARK: 属性信息
@implementation CSClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [super init];
    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    CSEncodingType type = 0;
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        switch (attrs[i].name[0]) {
            case 'T': { // Type encoding
                if (attrs[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = CSEncodingGetType(attrs[i].value);
                    
                    if ((type & CSEncodingTypeMask) == CSEncodingTypeObject && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                        }
                        
                        NSMutableArray *protocols = nil;
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString* protocol = nil;
                            if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                if (protocol.length) {
                                    if (!protocols) protocols = [NSMutableArray new];
                                    [protocols addObject:protocol];
                                }
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols;
                    }
                }
            } break;
            case 'V': { // Instance variable
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'R': {
                type |= CSEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= CSEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= CSEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= CSEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= CSEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= CSEncodingTypePropertyWeak;
            } break;
            case 'G': {
                type |= CSEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } break;
            case 'S': {
                type |= CSEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } // break; commented for code coverage in next line
            default: break;
        }
    }
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    
    _type = type;
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    return self;
}

@end


///MARK: 类信息类
@implementation CSClassInfo {
    BOOL _needUpdate;
}

// 这个方法其实就是利用runtime 为一些属性赋值,可能需要递归调用而已
- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    _cls = cls;
    _superCls = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    _name = NSStringFromClass(cls);
    [self _update];
    
    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

- (void)_update {
    // 1.先将一些实例变量置空
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    unsigned int methodCount = 0;
    // 2.获取方法列表
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methodInfos = methodInfos;
        for (unsigned int i = 0; i < methodCount; i++) {
            // 2.1对Method 做了一层封装，封装成了CSClassMethodInfo
            CSClassMethodInfo *info = [[CSClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) methodInfos[info.name] = info;
        }
        free(methods);
    }
    unsigned int propertyCount = 0;
    // 3.获取属性列表
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            // 对Property做了一层封装，封装成了CSClassPropertyInfo
            CSClassPropertyInfo *info = [[CSClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    unsigned int ivarCount = 0;
    // 4.获取示例变量列表
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            // 对示例变量做了一层封装，封装成了CSClassIvarInfo
            CSClassIvarInfo *info = [[CSClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    
    _needUpdate = NO;
}

- (void)setNeedUpdate {
    _needUpdate = YES;
}

- (BOOL)needUpdate {
    return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    // 1.声明一个类缓存字典
    static CFMutableDictionaryRef classCache;
    /** 
     2.声明一个元类缓存字典，这里为什么要声明一个元组缓存字典呢？
       因为YYClassInfo，有一个属性superClassInfo，也是YYClassInfo类型的，也
       要使用这个方法来实例化，所以多次迭代后，可能cls 就是元类了。
     */
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    // 3.声明一个信号量，线程安全会用到
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        // 4.初始化类缓存字典
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        // 5.初始化元类缓存字典
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    // 6.从缓存中获取类信息
    CSClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    // 7.如果能取到，但是需要更新，则利用runtime更新一下
    if (info && info->_needUpdate) {
        [info _update];
    }
    dispatch_semaphore_signal(lock);
    // 8.如果没获取到，则根据cls 初始化一个类信息对象
    if (!info) {
        info = [[CSClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            // 9.将类信息保存到缓存字典中
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end



