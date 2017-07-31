//
//  CSClassInfo.h
//  CSCategory
//
//  Created by mac on 2017/6/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CSEncodingType) {
    CSEncodingTypeMask       = 0xFF, ///< mask of type value
    CSEncodingTypeUnknown    = 0, ///< unknown
    CSEncodingTypeVoid       = 1, ///< void
    CSEncodingTypeBool       = 2, ///< bool
    CSEncodingTypeInt8       = 3, ///< char / BOOL
    CSEncodingTypeUInt8      = 4, ///< unsigned char
    CSEncodingTypeInt16      = 5, ///< short
    CSEncodingTypeUInt16     = 6, ///< unsigned short
    CSEncodingTypeInt32      = 7, ///< int
    CSEncodingTypeUInt32     = 8, ///< unsigned int
    CSEncodingTypeInt64      = 9, ///< long long
    CSEncodingTypeUInt64     = 10, ///< unsigned long long
    CSEncodingTypeFloat      = 11, ///< float
    CSEncodingTypeDouble     = 12, ///< double
    CSEncodingTypeLongDouble = 13, ///< long double
    CSEncodingTypeObject     = 14, ///< id
    CSEncodingTypeClass      = 15, ///< Class
    CSEncodingTypeSEL        = 16, ///< SEL
    CSEncodingTypeBlock      = 17, ///< block
    CSEncodingTypePointer    = 18, ///< void*
    CSEncodingTypeStruct     = 19, ///< struct
    CSEncodingTypeUnion      = 20, ///< union
    CSEncodingTypeCString    = 21, ///< char*
    CSEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    CSEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    CSEncodingTypeQualifierConst  = 1 << 8,  ///< const
    CSEncodingTypeQualifierIn     = 1 << 9,  ///< in
    CSEncodingTypeQualifierInout  = 1 << 10, ///< inout
    CSEncodingTypeQualifierOut    = 1 << 11, ///< out
    CSEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    CSEncodingTypeQualifierByref  = 1 << 13, ///< byref
    CSEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    CSEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    CSEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    CSEncodingTypePropertyCopy         = 1 << 17, ///< copy
    CSEncodingTypePropertyRetain       = 1 << 18, ///< retain
    CSEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    CSEncodingTypePropertyWeak         = 1 << 20, ///< weak
    CSEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    CSEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    CSEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};


/**
 从类型编码字符串获取类型.
 
 @详情参见:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 
 @param typeEncoding  类型编码字符串.
 @return 编码类型.
 */
CSEncodingType CSEncodingGetType(const char *typeEncoding);




///MARK: 实例变量信息
@interface CSClassIvarInfo : NSObject

@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) CSEncodingType type;    ///< Ivar's type

/**
 创建并返回一个ivar信息对象.
 
 @param ivar ivar 内部结构
 @return 一个新对象,如果发生错误则为nil.
 */
- (instancetype)initWithIvar:(Ivar)ivar;

@end


///MARK: 方法信息
@interface CSClassMethodInfo : NSObject

@property (nonatomic, assign, readonly) Method method;                  ///< 方法器
@property (nonatomic, strong, readonly) NSString *name;                 ///< 方法名称
@property (nonatomic, assign, readonly) SEL sel;                        ///< 方法的选择器
@property (nonatomic, assign, readonly) IMP imp;                        ///< 方法的实现
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< 方法的参数和返回类型
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< 返回值类型
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< 参数数组类型

/**
 创建并返回一个方法信息对象.
 
 @param method 方法内部结构
 @return 一个新对象,如果发生错误则为nil.
 */
- (instancetype)initWithMethod:(Method)method;

@end


///MARK: 属性信息
@interface CSClassPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property; ///< 属性的内部结构
@property (nonatomic, strong, readonly) NSString *name;           ///< 属性名称
@property (nonatomic, assign, readonly) CSEncodingType type;      ///< 属性类型
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< 属性的编码值
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< 属性的类名称
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< 类 可能是nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< 代理 可能没有
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 创建并返回属性信息对象.
 
 @param property 属性内部结构
 @return 一个新对象,如果发生错误则为nil.
 */
- (instancetype)initWithProperty:(objc_property_t)property;

@end




///MARK: 类信息类
@interface CSClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls; ///< 类对象
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< 父类
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< 类的元类对象
@property (nonatomic, readonly) BOOL isMeta; ///< 这个类是否是元类
@property (nonatomic, strong, readonly) NSString *name; ///< 类名
@property (nullable, nonatomic, strong, readonly) CSClassInfo *superClassInfo; ///< 父类的类信息
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, CSClassIvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, CSClassMethodInfo *> *methodInfos; ///< methods
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, CSClassPropertyInfo *> *propertyInfos; ///< properties


/**
 主动更新类信息
 tip:
 
 如果类被更改 (例如:你添加一个方法到这个类 'class_addMethod()') 你应该调用这个方法刷新类信息缓存.
 
 调用这个方法后, `needUpdate` 将返回 `YES`, 你应该调用 'classInfoWithClass' 或 'classInfoWithClassName' 类获取更新类的信息.
 
 */
- (void)setNeedUpdate;


/**
 是否需要更新类信息
 tip:
 如果此方法返回'YES',则应停止使用此实例并调用'classInfoWithClass'或'classInfoWithClassName'来获取更新的类信息
 
 @return 此类信息是否需要更新
 */
- (BOOL)needUpdate;


/**
 获取指定类的类信息

 此方法将缓存类信息和父类信息在所述第一访问类.该方法是线程安全的
 
 @param cls 类
 @return 类信息,如果发生错误则返回 nil.
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;


/**
 获取指定类的类信息

 此方法将缓存类信息和父类信息在所述第一访问类.该方法是线程安全的
 
 @param className 类名
 @return 类信息,如果发生错误则返回 nil.
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end


NS_ASSUME_NONNULL_END






