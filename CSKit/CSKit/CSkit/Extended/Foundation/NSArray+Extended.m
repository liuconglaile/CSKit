//
//  NSArray+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/14.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSArray+Extended.h"
#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSKitMacro.h>
#import <CSkit/NSData+Extended.h>
#else
#import "CSKitMacro.h"
#import "NSData+Extended.h"
#endif



@implementation NSArray (Extended)


/**
 从指定的plist创建并返回一个数组.
 
 @param plist   根对象是数组的属性列表数据.
 @return 由二进制plist数据创建的新数组,如果发生错误则为nil.
 */
+ (NSArray *)arrayWithPlistData:(NSData *)plist {
    if (!plist) return nil;
    NSArray *array = [NSPropertyListSerialization propertyListWithData:plist options:NSPropertyListImmutable format:NULL error:NULL];
    if ([array isKindOfClass:[NSArray class]]) return array;
    return nil;
}

/**
 从指定的plist创建并返回一个数组xml字符串.
 
 @param plist   属性列表xml字符串,其根对象是数组.
 @return 从plist字符串创建的新数组,如果发生错误,则为nil.
 */
+ (NSArray *)arrayWithPlistString:(NSString *)plist {
    if (!plist) return nil;
    NSData *data = [plist dataUsingEncoding:NSUTF8StringEncoding];
    return [self arrayWithPlistData:data];
}

/**
 将数组序列化为二进制属性列表数据.
 
 @return 二进制plist数据,如果发生错误则为nil.
 */
- (NSData *)plistData {
    return [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListBinaryFormat_v1_0 options:kNilOptions error:NULL];
}

/**
 将数组序列化为xml属性列表字符串.
 
 @return plist xml字符串,如果发生错误,则为nil.
 */
- (NSString *)plistString {
    NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListXMLFormat_v1_0 options:kNilOptions error:NULL];
    if (xmlData) return xmlData.utf8String;
    return nil;
}

/**
 返回位于随机索引处的对象.
 
 @return 数组中的对象具有随机索引值. 如果数组为空,则返回nil.
 */
- (id)randomObject {
    if (self.count) {
        return self[arc4random_uniform((u_int32_t)self.count)];
    }
    return nil;
}

/**
 返回位于索引处的对象,或者超出范围时返回nil.它类似于`objectAtIndex：`,但它不会抛出异常.
 
 @param index 要获取对象的索引.
 */
- (id)objectOrNilAtIndex:(NSUInteger)index {
    return index < self.count ? self[index] : nil;
}

/**
 将对象转换为json字符串.如果发生错误,返回nil.
 NSString/NSNumber/NSDictionary/NSArray
 */
- (NSString *)jsonStringEncoded {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

/**
 将对象转换为json字符串格式化.如果发生错误,返回nil.
 */
- (NSString *)jsonPrettyStringEncoded {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}




- (void)each:(void (^)(id object))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (void)eachWithIndex:(void (^)(id object, NSUInteger index))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx);
    }];
}

- (NSArray *)map:(id (^)(id object))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id object in self) {
        [array addObject:block(object) ?: [NSNull null]];
    }
    
    return array;
}

- (NSArray *)filter:(BOOL (^)(id object))block {
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return block(evaluatedObject);
    }]];
}

- (NSArray *)reject:(BOOL (^)(id object))block {
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return !block(evaluatedObject);
    }]];
}

- (id)detect:(BOOL (^)(id object))block {
    for (id object in self) {
        if (block(object))
            return object;
    }
    return nil;
}

- (id)reduce:(id (^)(id accumulator, id object))block {
    return [self reduce:nil withBlock:block];
}

- (id)reduce:(nullable id)initial withBlock:(id (^)(id accumulator, id object))block {
    id accumulator = initial;
    
    for(id object in self)
        accumulator = accumulator ? block(accumulator, object) : object;
    
    return accumulator;
}



- (id)objectWithIndex:(NSUInteger)index{
    if (index <self.count) {
        return self[index];
    }else{
        return nil;
    }
}

- (NSString*)stringWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null] || [[value description] isEqualToString:@"<null>"])
    {
        return nil;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString*)value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    
    return nil;
}


- (NSNumber*)numberWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    if ([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber*)value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        return [f numberFromString:(NSString*)value];
    }
    return nil;
}

- (NSDecimalNumber *)decimalNumberWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    if ([value isKindOfClass:[NSDecimalNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber * number = (NSNumber*)value;
        return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString * str = (NSString*)value;
        return [str isEqualToString:@""] ? nil : [NSDecimalNumber decimalNumberWithString:str];
    }
    return nil;
}

- (NSArray*)arrayWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return nil;
    }
    if ([value isKindOfClass:[NSArray class]])
    {
        return value;
    }
    return nil;
}


- (NSDictionary*)dictionaryWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return nil;
    }
    if ([value isKindOfClass:[NSDictionary class]])
    {
        return value;
    }
    return nil;
}

- (NSInteger)integerWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
    {
        return [value integerValue];
    }
    return 0;
}
- (NSUInteger)unsignedIntegerWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
    {
        return [value unsignedIntegerValue];
    }
    return 0;
}
- (BOOL)boolWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return NO;
    }
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value boolValue];
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return [value boolValue];
    }
    return NO;
}
- (int16_t)int16WithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value shortValue];
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return [value intValue];
    }
    return 0;
}
- (int32_t)int32WithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value intValue];
    }
    return 0;
}
- (int64_t)int64WithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value longLongValue];
    }
    return 0;
}

- (char)charWithIndex:(NSUInteger)index{
    
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value charValue];
    }
    return 0;
}

- (short)shortWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value shortValue];
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return [value intValue];
    }
    return 0;
}
- (float)floatWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value floatValue];
    }
    return 0;
}
- (double)doubleWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value doubleValue];
    }
    return 0;
}

- (NSDate *)dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat {
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = dateFormat;
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return nil;
    }
    
    if ([value isKindOfClass:[NSString class]] && ![value isEqualToString:@""] && !dateFormat) {
        return [formater dateFromString:value];
    }
    return nil;
}

//CG
- (CGFloat)CGFloatWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    CGFloat f = [value doubleValue];
    
    return f;
}

- (CGPoint)pointWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    CGPoint point = CGPointFromString(value);
    
    return point;
}
- (CGSize)sizeWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    CGSize size = CGSizeFromString(value);
    
    return size;
}
- (CGRect)rectWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    CGRect rect = CGRectFromString(value);
    
    return rect;
}







@end



@implementation NSMutableArray (Extended)

/**
 从指定的Plist创建并返回一个数组.
 
 @param plist  根对象是数组的属性列表数据.
 @return 由二进制plist数据创建的新数组,如果发生错误则为nil.
 */
+ (NSMutableArray *)arrayWithPlistData:(NSData *)plist {
    if (!plist) return nil;
    NSMutableArray *array = [NSPropertyListSerialization propertyListWithData:plist options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
    if ([array isKindOfClass:[NSMutableArray class]]) return array;
    return nil;
}

/**
 从指定的属性列表创建并返回一个数组xml字符串.
 
 @param plist   属性列表xml字符串,其根对象是数组.
 @return 从plist字符串创建的新数组,如果发生错误,则为nil.
 */
+ (NSMutableArray *)arrayWithPlistString:(NSString *)plist {
    if (!plist) return nil;
    NSData *data = [plist dataUsingEncoding:NSUTF8StringEncoding];
    return [self arrayWithPlistData:data];
}

/**
 删除数组中具有最低值索引的对象.如果数组为空,则此方法无效.
 
 @discussion 苹果已经实现了这种方法,但没有公开.覆盖安全.
 */
- (void)removeFirstObject {
    if (self.count) {
        [self removeObjectAtIndex:0];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
/**
 删除数组中具有最高值索引的对象.如果数组为空,则此方法无效.
 
 @discussion 苹果公司的实现表明,如果这样做,它会引发一个NSRangeException数组是空的,但事实上没有什么会发生.覆盖安全.
 */
- (void)removeLastObject {
    if (self.count) {
        [self removeObjectAtIndex:self.count - 1];
    }
}

#pragma clang diagnostic pop

/**
 删除并返回数组中具有最低值索引的对象.如果数组为空,则返回nil.
 
 @return 第一个对象,或者nil.
 */
- (id)popFirstObject {
    id obj = nil;
    if (self.count) {
        obj = self.firstObject;
        [self removeFirstObject];
    }
    return obj;
}

/**
 删除并返回数组中具有最高值索引的对象.如果数组为空,则返回nil.
 
 @return 最后一个对象或者 nil.
 */
- (id)popLastObject {
    id obj = nil;
    if (self.count) {
        obj = self.lastObject;
        [self removeLastObject];
    }
    return obj;
}

/**
 在数组的末尾插入给定的对象.
 
 @param anObject 将对象添加到数组的内容的末尾.该值不能为nil.如果anObject为nil,则引发NSInvalidArgumentException异常.
 */
- (void)appendObject:(id)anObject {
    [self addObject:anObject];
}

/**
 在数组的开头插入一个给定的对象.
 
 @param anObject 将对象添加到数组的内容的开头.该值不能为 nil.如果anObject为nil,则引发NSInvalidArgumentException异常.
 */
- (void)prependObject:(id)anObject {
    [self insertObject:anObject atIndex:0];
}

/**
 将包含在另一给定数组中的对象添加到接收结束阵列的内容.
 
 @param objects 将数组添加到接收数组的末尾内容.如果对象为空或无,则此方法无效.
 */
- (void)appendObjects:(NSArray *)objects {
    if (!objects) return;
    [self addObjectsFromArray:objects];
}

/**
 将包含在另一给定数组中的对象添加到接收数组内容的开头.
 
 @param objects 一系列对象添加到接收数组的开头内容.如果对象为空或无,则此方法无效.
 */
- (void)prependObjects:(NSArray *)objects {
    if (!objects) return;
    NSUInteger i = 0;
    for (id obj in objects) {
        [self insertObject:obj atIndex:i++];
    }
}

/**
 将包含在另一给定数组中的对象添加到接收的索引处阵列的内容.
 
 @param objects 要添加到接收数组的对象数组内容.如果对象为nil或无,则此方法无效.
 
 @param index 要插入对象的数组中的索引.这个值必须不要大于数组中的元素数.如果指数比数组中元素的数目大,则引发一个NSRangeException.
 */
- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index {
    NSUInteger i = index;
    for (id obj in objects) {
        [self insertObject:obj atIndex:i++];
    }
}

/**
 反转此数组中的对象索引.
 Example: Before @[ @1, @2, @3 ], After @[ @3, @2, @1 ].
 */
- (void)reverse {
    NSUInteger count = self.count;
    int mid = floor(count / 2.0);
    for (NSUInteger i = 0; i < mid; i++) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:(count - (i + 1))];
    }
}

/** 随机排列此数组中的对象. */
- (void)shuffle {
    for (NSUInteger i = self.count; i > 1; i--) {
        [self exchangeObjectAtIndex:(i - 1)
                  withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
}

- (void)addObj:(id)i{
    if (i!=nil) {
        [self addObject:i];
    }
}
- (void)addString:(NSString*)i{
    if (i!=nil) {
        [self addObject:i];
    }
}
- (void)addBool:(BOOL)i{
    [self addObject:@(i)];
}
- (void)addInt:(int)i{
    [self addObject:@(i)];
}
- (void)addInteger:(NSInteger)i{
    [self addObject:@(i)];
}
- (void)addUnsignedInteger:(NSUInteger)i{
    [self addObject:@(i)];
}
- (void)addCGFloat:(CGFloat)f{
    [self addObject:@(f)];
}
- (void)addChar:(char)c{
    [self addObject:@(c)];
}
- (void)addFloat:(float)i{
    [self addObject:@(i)];
}
- (void)addPoint:(CGPoint)o{
    [self addObject:NSStringFromCGPoint(o)];
}
- (void)addSize:(CGSize)o{
    [self addObject:NSStringFromCGSize(o)];
}
- (void)addRect:(CGRect)o{
    [self addObject:NSStringFromCGRect(o)];
}



@end
