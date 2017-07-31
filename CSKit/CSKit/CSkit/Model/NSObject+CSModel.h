//
//  NSObject+CSModel.h
//  CSCategory
//
//  Created by mac on 2017/6/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 如果需要每个属性或每个方法都去指定nonnull和nullable,是一件非常繁琐的事.
 苹果为了减轻我们的工作量,专门提供了两个宏:NS_ASSUME_NONNULL_BEGIN 和 NS_ASSUME_NONNULL_END.
 */
NS_ASSUME_NONNULL_BEGIN


/**
 
 提供一些数据模型的方法:
 * 将json转换为任何对象,或将任何对象转换为json.
 * 使用键值字典（如KVC）设置对象属性.
 * "NSCoding","NSCopying","-hash"和"-isEqual:"的实现.
  
 有关自定义方法的"CSModel"协议.
 
 示例代码:请查阅底部
 
 */
@interface NSObject (CSModel)

/** 从json创建并返回接收器的新实例(线程安全) */
+ (nullable instancetype)modelWithJSON:(id)json;
/** 从键值字典创建并返回接收器的新实例(线程安全) */
+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dictionary;
/** 使用json对象设置接收者的属性(json中的任何无效数据都将被忽略) */
- (BOOL)modelSetWithJSON:(id)json;
/** 使用键值字典设置接收者的属性 */
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic;
/** 模型转换成 json 字符串 */
- (nullable id)modelToJSONObject;
/** 从接收者的属性生成一个json字符串的数据 */
- (nullable NSData *)modelToJSONData;
/** 从接收者的属性生成一个json字符串 */
- (nullable NSString *)modelToJSONString;
/** 复制具有接收者属性的实例 */
- (nullable id)modelCopy;
/** 将接收器的属性编码为编码器 */
- (void)modelEncodeWithCoder:(NSCoder *)aCoder;
/** 从解码器解码接收机的属性 */
- (id)modelInitWithCoder:(NSCoder *)aDecoder;
/** 获取接收者属性的哈希值 */
- (NSUInteger)modelHash;
/** 基于属性,将接收器与另一个对象进行比较以实现相等 */
- (BOOL)modelIsEqual:(id)model;
/** 基于属性进行调试的描述方法 */
- (NSString *)modelDescription;



@end





///MARK: 为NSArray提供一些数据模型方法
@interface NSArray (CSModel)

/** 从json数组创建并返回一个数组(线程安全) */
+ (nullable NSArray *)modelArrayWithClass:(Class)cls json:(id)json;

@end





///MARK: 为NSDictionary提供一些数据模型方法.
@interface NSDictionary (CSModel)

/** 从json创建并返回一个字典(线程安全) */
+ (nullable NSDictionary *)modelDictionaryWithClass:(Class)cls json:(id)json;

@end




/**
 如果默认模型转换不适合您的模型类,请执行一个或更多的方法在本协议中改变默认的键值转换过程.
 没有必要将'<CSModel>'添加到你的类头.
 */
@protocol CSModel <NSObject>
@optional


/**
 自定义属性映射器(详情请查阅底部示例 2-1).
 
 如果 JSON & Dictionary 中的键与模型的属性名称不匹配,实现此方法并返回附加的映射器
 
 @return 属性的自定义映射器
 */
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;

/**
 容器属性的通用类映射器.(详情请查阅底部示例 2-2)
 
 如果属性是容器对象(如 NSArray & NSSet & NSDictionary),
 实现此方法并返回一个 property -> class mapper,
 告诉哪种类型对象将被添加到 数组 & 集合 & 字典中.

 @return 一个类映射器.
 */
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;

/**
 如果您需要在 json->object 变换期间创建不同类的实例,使用该方法根据字典数据选择自定义类(详情请查阅底部示例 2-3).
 
 如果模型实现此方法,则将调用它来确定结果类中 '+modelWithJSON:','+modelWithDictionary:', 
 转换父对象的属性对象 (单数和容器通过 '+modelContainerPropertyGenericClass').
 

 @param dictionary The json/kv dictionary.
 
 @return 从这个字典创建的类,'nil'使用当前类.
 
 */
+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;

/**
 黑名单中的所有属性将在模型转换过程中被忽略.返回nil以忽略此功能.
 
 @return 属性名称的数组.
 */
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

/**
 如果属性不在白名单中,则在模型转换过程中将被忽略.返回nil以忽略此功能.
 
 @return 属性名称的数组.
 */
+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;

/**
 这个方法的作用类似于 
 '- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;',
 但是在模型转换之前被调用.
 

 如果模型实现了这个方法,它将被调用
 
 '+ modelWithJSON:',
 '+ modelWithDictionary:',
 '- modelSetWithJSON:',
 '- modelSetWithDictionary:'.
 
 如果此方法返回nil,则转换过程将忽略此模型.
 
 @param dic  The json/kv dictionary.
 
 @return 返回修改后的字典,否则忽略此模型.
 */
- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;

/**
 如果默认的json-to-model转换不符合你的模型对象,就实现这种方法做额外的过程.您也可以使用此方法来验证模型的属性.
 
 如果模型实现了这个方法,它将在结尾处被调用
 
 '+modelWithJSON:',
 '+modelWithDictionary:',
 '-modelSetWithJSON:',
 '-modelSetWithDictionary:'.
 
 如果此方法返回NO,则转换过程将忽略此模型.
 
 @param dic  The json/kv dictionary.
 
 @return 如果模型有效,返回YES,否则忽略此模型.
 */
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;

/**
 如果默认的model-to-json变换不适合您的模型类,请执行这种方法做额外的过程.您也可以使用此方法来验证json字典.
 
 如果模型实现了这个方法,它将在结尾处被调用
 
 '-modelToJSONObject',
 '-modelToJSONString'.
 
 如果此方法返回NO,则转换过程将忽略此json字典.
 
 @param dic  The json dictionary.
 
 @return 如果模型有效,返回YES,否则忽略此模型.
 */
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end

NS_ASSUME_NONNULL_END









///MARK: 使用示例代码 1:
/**
 
 提供一些数据模型的方法:
 * 将json转换为任何对象,或将任何对象转换为json.
 * 使用键值字典（如KVC）设置对象属性.
 * "NSCoding","NSCopying","-hash"和"-isEqual:"的实现.
  
 有关自定义方法的"CSModel"协议.
 

 
 ********************** json convertor *********************
 
 
 \@interface CSAuthor : NSObject
 @property (nonatomic, strong) NSString *name;
 @property (nonatomic, assign) NSDate *birthday;
 @end
 
 @implementation CSAuthor
 @end
 
 
 
 \@interface CSBook : NSObject
 @property (nonatomic, copy) NSString *name;
 @property (nonatomic, assign) NSUInteger pages;
 @property (nonatomic, strong) YYAuthor *author;
 @end
 
 @implementation CSBook
 @end
 
 
 
 int main() {
     // 从json创建模型
     CSBook *book = [CSBook modelWithJSON:@"{\"name\": \"Harry Potter\",
                     \"pages\": 256,
                     \"author\": { \"name\": \"J.K.Rowling\",
                     \"birthday\": \"1965-07-31\" } }" ];
 
     // 将模型转换为json
     NSString *json = [book modelToJSONString];
     
     //输出: {"author":{"name":"J.K.Rowling","birthday":"1965-07-31T00:00:00+0000"},"name":"Harry Potter","pages":256}
 }
 
 
 
 
 
 ********************** Coding/Copying/hash/equal *********************
 
 \@interface CSShadow :NSObject <NSCoding, NSCopying>
 
 @property (nonatomic, copy) NSString *name;
 @property (nonatomic, assign) CGSize size;
 
 @end
 
 @implementation CSShadow
 
 - (void)encodeWithCoder:(NSCoder *)aCoder {
     [self modelEncodeWithCoder:aCoder];
 }
 - (id)initWithCoder:(NSCoder *)aDecoder {
     self = [super init];
     return [self modelInitWithCoder:aDecoder];
 }
 - (id)copyWithZone:(NSZone *)zone {
     return [self modelCopy];
 }
 - (NSUInteger)hash {
     return [self modelHash];
 }
 - (BOOL)isEqual:(id)object {
     return [self modelIsEqual:object];
 }
 
 @end
 
 */


///MARK: 使用示例 2-1:
/**
 
 json: { "n"   :"Harry Pottery",
         "p"   : 256,
         "ext" : { "desc" : "A book written by J.K.Rowling." },
         "ID"  : 100010 }
 
 model:
 
 \@interface CSBook : NSObject
 
 @property NSString *name;
 @property NSInteger page;
 @property NSString *desc;
 @property NSString *bookID;
 
 @end
 
 @implementation CSBook
 
 + (NSDictionary *)modelCustomPropertyMapper {
     return @{@"name"  : @"n",
              @"page"  : @"p",
              @"desc"  : @"ext.desc",
              @"bookID": @[@"id", @"ID", @"book_id"]};
 }
 
 @end
 
 */



///MARK: 使用示例 2-2:
/**
 
 \@class CSShadow, CSBorder, CSAttachment;
 
 \@interface CSAttributes
 
 @property NSString *name;
 @property NSArray *shadows;
 @property NSSet *borders;
 @property NSDictionary *attachments;
 
 @end
 
 @implementation CSAttributes
 
 + (NSDictionary *)modelContainerPropertyGenericClass {
     return @{@"shadows" : [CSShadow class],
              @"borders" : CSBorder.class,
              @"attachments" : @"CSAttachment" };
 }
 
 @end
 */


///MARK: 使用示例 2-3:
/**
 
 \@class CSCircle, CSRectangle, CSLine;
 
 @implementation CSShape
 
 + (Class)modelCustomClassForDictionary:(NSDictionary*)dictionary {
 
     if (dictionary[@"radius"] != nil) {
         return [CSCircle class];
     } else if (dictionary[@"width"] != nil) {
         return [CSRectangle class];
     } else if (dictionary[@"y2"] != nil) {
         return [CSLine class];
     } else {
         return [self class];
     }
     
     }
 
 @end
 
 */
