//
//  NSObject+CSRuntime.h
//  CSKit
//
//  Created by mac on 2017/10/11.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CSRuntime)

/** 属性列表 */
- (NSArray *)propertiesInfo;
+ (NSArray *)propertiesInfo;
/** 格式化之后的属性列表 */
+ (NSArray *)propertiesWithCodeFormat;


/** 成员变量列表 */
- (NSArray *)ivarInfo;
+ (NSArray *)ivarInfo;


/** 对象方法列表 */
-(NSArray*)instanceMethodList;
+(NSArray*)instanceMethodList;
/** 类方法列表 */
+(NSArray*)classMethodList;


/** 协议列表 */
-(NSDictionary *)protocolList;
+(NSDictionary *)protocolList;




//类名
- (NSString *)className;
+ (NSString *)className;

//父类名称
- (NSString *)superClassName;
+ (NSString *)superClassName;


//实例属性字典
-(NSDictionary *)propertyDictionary;

//属性名称列表
- (NSArray *)propertyKeys;
+ (NSArray *)propertyKeys;

//方法列表
-(NSArray *)methodList;
+(NSArray *)methodList;

-(NSArray *)methodListInfo;

//创建并返回一个指向所有已注册类的指针列表
+ (NSArray *)registedClassList;
//实例变量
+ (NSArray *)instanceVariable;


- (BOOL)hasPropertyForKey:(NSString*)key;
- (BOOL)hasIvarForKey:(NSString*)key;



/** 交换实例方法 */
+ (void)swizzlingInstanceMethodWithOldMethod:(SEL)oldMethod newMethod:(SEL)newMethod;
/** 交换类方法 */
+ (void)swizzlingClassMethodWithOldMethod:(SEL)oldMethod newMethod:(SEL)newMethod;


/** 添加方法 */
+ (void)addMethodWithSEL:(SEL)methodSEL methodIMP:(SEL)methodIMP;





#pragma mark - 交换方法(Swizzling)
/** 在一个类中交换两个实例方法的实现.要谨慎使用,很容易崩. */
+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;
/** 在一个类中交换两个类方法实现.要谨慎使用,很容易崩. */
+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;

/** 追加的新方法,对象 */
+ (void)appendMethod:(SEL)newMethod fromClass:(Class)aClass;
/** 检查父类是否实现了指定代理 */
- (BOOL)respondsToSelector:(SEL)selector untilClass:(Class)stopClass;
/** 检查父类是否实现了指定类方法 */
- (BOOL)superRespondsToSelector:(SEL)selector;
/** 检查父类是否实现了指定类方法 */
- (BOOL)superRespondsToSelector:(SEL)selector untilClass:(Class)stopClass;
/** 检查父类是否实现了指定实例方法 */
+ (BOOL)instancesRespondToSelector:(SEL)selector untilClass:(Class)stopClass;


#pragma mark - 关联value
///=============================================================================
/// @name 关联value
///=============================================================================

/** 将一个对象与self关联 并且强引用strong (strong, nonatomic). */
- (void)setAssociateValue:(nullable id)value withKey:(void *)key;
/** 将一个对象与self关联 并且弱引用 weak property (week, nonatomic). */
- (void)setAssociateWeakValue:(nullable id)value withKey:(void *)key;
/** 从'self'获取关联的值 */
- (nullable id)getAssociatedValueForKey:(void *)key;
/** 删除所有关联的值 */
- (void)removeAssociatedValues;








@end



NS_ASSUME_NONNULL_END
