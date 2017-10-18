//
//  NSObject+CSRuntime.m
//  CSKit
//
//  Created by mac on 2017/10/11.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "NSObject+CSRuntime.h"
#import <objc/runtime.h>




BOOL method_swizzle(Class klass, SEL origSel, SEL altSel)
{
    if (!klass)
        return NO;
    
    Method __block origMethod, __block altMethod;
    
    void (^find_methods)(void) = ^
    {
        unsigned methodCount = 0;
        Method *methodList = class_copyMethodList(klass, &methodCount);
        
        origMethod = altMethod = NULL;
        
        if (methodList)
            for (unsigned i = 0; i < methodCount; ++i)
            {
                if (method_getName(methodList[i]) == origSel)
                    origMethod = methodList[i];
                
                if (method_getName(methodList[i]) == altSel)
                    altMethod = methodList[i];
            }
        
        free(methodList);
    };
    
    find_methods();
    
    if (!origMethod)
    {
        origMethod = class_getInstanceMethod(klass, origSel);
        
        if (!origMethod)
            return NO;
        
        if (!class_addMethod(klass, method_getName(origMethod), method_getImplementation(origMethod), method_getTypeEncoding(origMethod)))
            return NO;
    }
    
    if (!altMethod)
    {
        altMethod = class_getInstanceMethod(klass, altSel);
        
        if (!altMethod)
            return NO;
        
        if (!class_addMethod(klass, method_getName(altMethod), method_getImplementation(altMethod), method_getTypeEncoding(altMethod)))
            return NO;
    }
    
    find_methods();
    
    if (!origMethod || !altMethod)
        return NO;
    
    method_exchangeImplementations(origMethod, altMethod);
    
    return YES;
}



void method_replace(Class toClass, Class fromClass, SEL selector)
{
    if (!toClass || !fromClass || ! selector)
        return;
    
    Method method = class_getInstanceMethod(fromClass, selector);
    
    if (!method)
        return;
    
    class_replaceMethod(toClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
}



void method_append(Class toClass, Class fromClass, SEL selector)
{
    if (!toClass || !fromClass || !selector)
        return;
    
    Method method = class_getInstanceMethod(fromClass, selector);
    
    if (!method)
        return;
    
    class_addMethod(toClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
}







@implementation NSObject (CSRuntime)

+ (void)swizzlingInstanceMethodWithOldMethod:(SEL)oldMethod newMethod:(SEL)newMethod {
    
    Class class = [self class];
    
    SEL originalSelector = oldMethod;
    SEL swizzledSelector = newMethod;
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


+(void)swizzlingClassMethodWithOldMethod:(SEL)oldMethod newMethod:(SEL)newMethod {
    
    Class class = object_getClass((id)self);
    SEL originalSelector = oldMethod;
    SEL swizzledSelector = newMethod;
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

+ (void)addMethodWithSEL:(SEL)methodSEL methodIMP:(SEL)methodIMP {
    Method method = class_getInstanceMethod(self, methodIMP);
    IMP getMethodIMP = method_getImplementation(method);
    const char *types = method_getTypeEncoding(method);
    class_addMethod(self, methodSEL, getMethodIMP, types);
}




- (NSArray *)propertiesInfo
{
    return [[self class] propertiesInfo];
}


+ (NSArray *)propertiesInfo
{
    NSMutableArray *propertieArray = [NSMutableArray array];
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (int i = 0; i < propertyCount; i++)
    {
        [propertieArray addObject:({
            
            NSDictionary *dictionary = [self dictionaryWithProperty:properties[i]];
            
            dictionary;
        })];
    }
    
    free(properties);
    
    return propertieArray;
}



+ (NSArray *)propertiesWithCodeFormat
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSArray *properties = [[self class] propertiesInfo];
    
    for (NSDictionary *item in properties)
    {
        NSMutableString *format = ({
            
            NSMutableString *formatString = [NSMutableString stringWithFormat:@"@property "];
            //attribute
            NSArray *attribute = [item objectForKey:@"attribute"];
            attribute = [attribute sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2 options:NSNumericSearch];
            }];
            if (attribute && attribute.count > 0)
            {
                NSString *attributeStr = [NSString stringWithFormat:@"(%@)",[attribute componentsJoinedByString:@", "]];
                
                [formatString appendString:attributeStr];
            }
            
            //type
            NSString *type = [item objectForKey:@"type"];
            if (type) {
                [formatString appendString:@" "];
                [formatString appendString:type];
            }
            
            //name
            NSString *name = [item objectForKey:@"name"];
            if (name) {
                [formatString appendString:@" "];
                [formatString appendString:name];
                [formatString appendString:@";"];
            }
            
            formatString;
        });
        
        [array addObject:format];
    }
    
    return array;
}



-(NSArray *)ivarInfo {
    return [[self class] ivarInfo];
}

+ (NSArray *)ivarInfo
{
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < outCount; i++) {
        NSString *type = [[self class] decodeType:ivar_getTypeEncoding(ivars[i])];
        NSString *name = [NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSUTF8StringEncoding];
        NSString *ivarDescription = [NSString stringWithFormat:@"%@ %@", type, name];
        [result addObject:ivarDescription];
    }
    free(ivars);
    return result.count ? [result copy] : nil;
}


-(NSArray*)instanceMethodList
{
    u_int count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method *methods= class_copyMethodList([self class], &count);
    for (int i = 0; i < count ; i++)
    {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString  stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        [methodList addObject:strName];
    }
    free(methods);
    return methodList;
}

+(NSArray*)instanceMethodList
{
    u_int count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method * methods= class_copyMethodList([self class], &count);
    for (int i = 0; i < count ; i++)
    {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString  stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        [methodList addObject:strName];
    }
    free(methods);
    
    return methodList;
}


+ (NSArray *)classMethodList
{
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(object_getClass(self), &count);
    
    NSMutableArray *mutableList = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++)
    {
        Method method = methodList[i];
        SEL methodName = method_getName(method);
        [mutableList addObject:NSStringFromSelector(methodName)];
    }
    free(methodList);
    return [NSArray arrayWithArray:mutableList];
}


-(NSDictionary *)protocolList
{
    return [[self class]protocolList];
}

+ (NSDictionary *)protocolList
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    unsigned int count;
    Protocol * __unsafe_unretained * protocols = class_copyProtocolList([self class], &count);
    for (int i = 0; i < count; i++)
    {
        Protocol *protocol = protocols[i];
        
        NSString *protocolName = [NSString stringWithCString:protocol_getName(protocol) encoding:NSUTF8StringEncoding];
        
        NSMutableArray *superProtocolArray = ({
            
            NSMutableArray *array = [NSMutableArray array];
            
            unsigned int superProtocolCount;
            Protocol * __unsafe_unretained * superProtocols = protocol_copyProtocolList(protocol, &superProtocolCount);
            for (int ii = 0; ii < superProtocolCount; ii++)
            {
                Protocol *superProtocol = superProtocols[ii];
                
                NSString *superProtocolName = [NSString stringWithCString:protocol_getName(superProtocol) encoding:NSUTF8StringEncoding];
                
                [array addObject:superProtocolName];
            }
            free(superProtocols);
            
            array;
        });
        
        [dictionary setObject:superProtocolArray forKey:protocolName];
    }
    free(protocols);
    
    return dictionary;
}









- (NSString *)className
{
    //[NSString stringWithUTF8String:class_getName([self class])];
    return NSStringFromClass([self class]);
}

- (NSString *)superClassName
{
    return NSStringFromClass([self superclass]);
}

+ (NSString *)className
{
    return NSStringFromClass([self class]);
}

+ (NSString *)superClassName
{
    return NSStringFromClass([self superclass]);
}

-(NSDictionary *)propertyDictionary
{
    //创建可变字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);
    for(int i=0;i<outCount;i++){
        objc_property_t prop = props[i];
        NSString *propName = [[NSString alloc]initWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
        id propValue = [self valueForKey:propName];
        [dict setObject:propValue?:[NSNull null] forKey:propName];
    }
    free(props);
    return dict;
}

- (NSArray*)propertyKeys
{
    return [[self class] propertyKeys];
}

+ (NSArray *)propertyKeys {
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList(self, &propertyCount);
    NSMutableArray * propertyNames = [NSMutableArray array];
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    return propertyNames;
}

-(NSArray*)methodList
{
    u_int               count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method *methods= class_copyMethodList([self class], &count);
    for (int i = 0; i < count ; i++)
    {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString  stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        [methodList addObject:strName];
    }
    free(methods);
    return methodList;
}

-(NSArray*)methodListInfo
{
    u_int               count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method *methods= class_copyMethodList([self class], &count);
    for (int i = 0; i < count ; i++)
    {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        
        Method method = methods[i];
        //        IMP imp = method_getImplementation(method);
        SEL name = method_getName(method);
        // 返回方法的参数的个数
        int argumentsCount = method_getNumberOfArguments(method);
        //获取描述方法参数和返回值类型的字符串
        const char *encoding =method_getTypeEncoding(method);
        //取方法的返回值类型的字符串
        const char *returnType =method_copyReturnType(method);
        
        NSMutableArray *arguments = [NSMutableArray array];
        for (int index=0; index<argumentsCount; index++) {
            // 获取方法的指定位置参数的类型字符串
            char *arg =   method_copyArgumentType(method,index);
            //            NSString *argString = [NSString stringWithCString:arg encoding:NSUTF8StringEncoding];
            [arguments addObject:[[self class] decodeType:arg]];
        }
        
        NSString *returnTypeString =[[self class] decodeType:returnType];
        NSString *encodeString = [[self class] decodeType:encoding];
        NSString *nameString = [NSString  stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        
        [info setObject:arguments forKey:@"arguments"];
        [info setObject:[NSString stringWithFormat:@"%d",argumentsCount] forKey:@"argumentsCount"];
        [info setObject:returnTypeString forKey:@"returnType"];
        [info setObject:encodeString forKey:@"encode"];
        [info setObject:nameString forKey:@"name"];
        //        [info setObject:imp_f forKey:@"imp"];
        [methodList addObject:info];
    }
    free(methods);
    return methodList;
}

+(NSArray*)methodList
{
    u_int               count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method * methods= class_copyMethodList([self class], &count);
    for (int i = 0; i < count ; i++)
    {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString  stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        [methodList addObject:strName];
    }
    free(methods);
    
    return methodList;
}

+ (NSArray *)registedClassList
{
    NSMutableArray *result = [NSMutableArray array];
    
    unsigned int count;
    Class *classes = objc_copyClassList(&count);
    for (int i = 0; i < count; i++)
    {
        [result addObject:NSStringFromClass(classes[i])];
    }
    free(classes);
    [result sortedArrayUsingSelector:@selector(compare:)];
    
    return result;
}

+ (NSArray *)instanceVariable
{
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < outCount; i++) {
        NSString *type = [[self class] decodeType:ivar_getTypeEncoding(ivars[i])];
        NSString *name = [NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSUTF8StringEncoding];
        NSString *ivarDescription = [NSString stringWithFormat:@"%@ %@", type, name];
        [result addObject:ivarDescription];
    }
    free(ivars);
    return result.count ? [result copy] : nil;
}

- (BOOL)hasPropertyForKey:(NSString*)key
{
    objc_property_t property = class_getProperty([self class], [key UTF8String]);
    return (BOOL)property;
}
- (BOOL)hasIvarForKey:(NSString*)key
{
    Ivar ivar = class_getInstanceVariable([self class], [key UTF8String]);
    return (BOOL)ivar;
}














/**
 在一个类中交换两个实例方法的实现.要谨慎使用,很容易崩.
 
 @param originalSel   Selector 1.
 @param newSel        Selector 2.
 @return              交换成功返回YES; 否则,NO.
 */
+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel {
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    class_addMethod(self,
                    originalSel,
                    class_getMethodImplementation(self, originalSel),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(self,
                    newSel,
                    class_getMethodImplementation(self, newSel),
                    method_getTypeEncoding(newMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
                                   class_getInstanceMethod(self, newSel));
    return YES;
}

/**
 在一个类中交换两个类方法实现.要谨慎使用,很容易崩.
 
 @param originalSel   Selector 1.
 @param newSel        Selector 2.
 @return              交换成功返回YES; 否则,NO.
 */
+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel {
    Class class = object_getClass(self);
    Method originalMethod = class_getInstanceMethod(class, originalSel);
    Method newMethod = class_getInstanceMethod(class, newSel);
    if (!originalMethod || !newMethod) return NO;
    method_exchangeImplementations(originalMethod, newMethod);
    return YES;
}

/**
 在一个对象替换方法.
 
 @param newMethod Method to exchange.
 @param aClass 主类.
 */
+ (void)appendMethod:(SEL)newMethod fromClass:(Class)aClass{
    method_append(self.class, aClass, newMethod);
}

/**
 检查父类是否实现了指定代理.
 
 @param selector 标识方法的选择.
 @param stopClass 最后一个继承类(不包含这个类).
 @return 如果层次结构中任意一个父类实现了该方法,则返回YES.
 */
- (BOOL)respondsToSelector:(SEL)selector untilClass:(Class)stopClass
{
    return [self.class instancesRespondToSelector:selector untilClass:stopClass];
}

/**
 检查父类是否实现了指定类方法.
 
 @param selector 一个标识方法的选择器.
 @return 如果层次结构中任意一个父类实现了该方法,则返回YES.
 */
- (BOOL)superRespondsToSelector:(SEL)selector
{
    return [self.superclass instancesRespondToSelector:selector];
}

/**
 检查父类是否实现了指定类方法.
 
 @param selector 一个标识方法的选择器.
 @param stopClass 最后一个继承类(不包含这个类).
 @return 如果层次结构中任意一个父类实现了该方法,则返回YES.
 */
- (BOOL)superRespondsToSelector:(SEL)selector untilClass:(Class)stopClass
{
    return [self.superclass instancesRespondToSelector:selector untilClass:stopClass];
}




/**
 检查父类是否实现了指定实例方法.
 
 @param selector 标识方法的选择器.
 @param stopClass 最后一个继承类(不包含这个类).
 @return 如果层次结构中任意一个父类实现了该方法,则返回YES.
 */
+ (BOOL)instancesRespondToSelector:(SEL)selector untilClass:(Class)stopClass
{
    BOOL __block (^ __weak block_self)(Class klass, SEL selector, Class stopClass);
    BOOL (^block)(Class klass, SEL selector, Class stopClass) = [^
                                                                 (Class klass, SEL selector, Class stopClass)
                                                                 {
                                                                     if (!klass || klass == stopClass)
                                                                         return NO;
                                                                     
                                                                     unsigned methodCount = 0;
                                                                     Method *methodList = class_copyMethodList(klass, &methodCount);
                                                                     
                                                                     if (methodList)
                                                                         for (unsigned i = 0; i < methodCount; ++i)
                                                                             if (method_getName(methodList[i]) == selector)
                                                                                 return YES;
                                                                     
                                                                     return block_self(klass.superclass, selector, stopClass);
                                                                 } copy];
    
    block_self = block;
    
    return block(self.class, selector, stopClass);
}



/**
 将一个对象与self关联 并且强引用strong (strong, nonatomic).
 
 @param value   要关联的对象.
 @param key     从中获取值的指针'self'.
 */
- (void)setAssociateValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 将一个对象与self关联 并且弱引用 weak property (week, nonatomic).
 
 @param value   要关联的对象.
 @param key     从中获取值的指针'self'.
 */
- (void)setAssociateWeakValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

/**
 删除所有关联的值.
 */
- (void)removeAssociatedValues {
    objc_removeAssociatedObjects(self);
}

/**
 从'self'获取关联的值.
 
 @param key 指针从'self'获取值.
 */
- (id)getAssociatedValueForKey:(void *)key {
    return objc_getAssociatedObject(self, key);
}




















///MARK:编码类型
+ (NSString *)decodeType:(const char *)cString
{
    if (!strcmp(cString, @encode(char)))
        return @"char";
    if (!strcmp(cString, @encode(int)))
        return @"int";
    if (!strcmp(cString, @encode(short)))
        return @"short";
    if (!strcmp(cString, @encode(long)))
        return @"long";
    if (!strcmp(cString, @encode(long long)))
        return @"long long";
    if (!strcmp(cString, @encode(unsigned char)))
        return @"unsigned char";
    if (!strcmp(cString, @encode(unsigned int)))
        return @"unsigned int";
    if (!strcmp(cString, @encode(unsigned short)))
        return @"unsigned short";
    if (!strcmp(cString, @encode(unsigned long)))
        return @"unsigned long";
    if (!strcmp(cString, @encode(unsigned long long)))
        return @"unsigned long long";
    if (!strcmp(cString, @encode(float)))
        return @"float";
    if (!strcmp(cString, @encode(double)))
        return @"double";
    if (!strcmp(cString, @encode(bool)))
        return @"bool";
    if (!strcmp(cString, @encode(_Bool)))
        return @"_Bool";
    if (!strcmp(cString, @encode(void)))
        return @"void";
    if (!strcmp(cString, @encode(char *)))
        return @"char *";
    if (!strcmp(cString, @encode(id)))
        return @"id";
    if (!strcmp(cString, @encode(Class)))
        return @"class";
    if (!strcmp(cString, @encode(SEL)))
        return @"SEL";
    if (!strcmp(cString, @encode(BOOL)))
        return @"BOOL";
    
    NSString *result = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
    
    if ([[result substringToIndex:1] isEqualToString:@"@"] && [result rangeOfString:@"?"].location == NSNotFound) {
        result = [[result substringWithRange:NSMakeRange(2, result.length - 3)] stringByAppendingString:@"*"];
    } else
    {
        if ([[result substringToIndex:1] isEqualToString:@"^"]) {
            result = [NSString stringWithFormat:@"%@ *",
                      [NSString decodeType:[[result substringFromIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]]];
        }
    }
    return result;
}




///MARK:成员属性转字典
+ (NSDictionary *)dictionaryWithProperty:(objc_property_t)property
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    //name
    
    NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
    [result setObject:propertyName forKey:@"name"];
    
    //attribute
    
    NSMutableDictionary *attributeDictionary = ({
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        unsigned int attributeCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attributeCount);
        
        for (int i = 0; i < attributeCount; i++)
        {
            NSString *name = [NSString stringWithCString:attrs[i].name encoding:NSUTF8StringEncoding];
            NSString *value = [NSString stringWithCString:attrs[i].value encoding:NSUTF8StringEncoding];
            [dictionary setObject:value forKey:name];
        }
        
        free(attrs);
        
        dictionary;
    });
    
    NSMutableArray *attributeArray = [NSMutableArray array];
    
    //R
    if ([attributeDictionary objectForKey:@"R"])
    {
        [attributeArray addObject:@"readonly"];
    }
    //C
    if ([attributeDictionary objectForKey:@"C"])
    {
        [attributeArray addObject:@"copy"];
    }
    //&
    if ([attributeDictionary objectForKey:@"&"])
    {
        [attributeArray addObject:@"strong"];
    }
    //N
    if ([attributeDictionary objectForKey:@"N"])
    {
        [attributeArray addObject:@"nonatomic"];
    }
    else
    {
        [attributeArray addObject:@"atomic"];
    }
    //G<name>
    if ([attributeDictionary objectForKey:@"G"])
    {
        [attributeArray addObject:[NSString stringWithFormat:@"getter=%@", [attributeDictionary objectForKey:@"G"]]];
    }
    //S<name>
    if ([attributeDictionary objectForKey:@"S"])
    {
        [attributeArray addObject:[NSString stringWithFormat:@"setter=%@", [attributeDictionary objectForKey:@"G"]]];
    }
    //D
    if ([attributeDictionary objectForKey:@"D"])
    {
        [result setObject:[NSNumber numberWithBool:YES] forKey:@"isDynamic"];
    }
    else
    {
        [result setObject:[NSNumber numberWithBool:NO] forKey:@"isDynamic"];
    }
    //W
    if ([attributeDictionary objectForKey:@"W"])
    {
        [attributeArray addObject:@"weak"];
    }
    //P
    if ([attributeDictionary objectForKey:@"P"])
    {
        
    }
    //T
    if ([attributeDictionary objectForKey:@"T"])
    {
        
        NSDictionary *typeDic = @{@"c":@"char",
                                  @"i":@"int",
                                  @"s":@"short",
                                  @"l":@"long",
                                  @"q":@"long long",
                                  @"C":@"unsigned char",
                                  @"I":@"unsigned int",
                                  @"S":@"unsigned short",
                                  @"L":@"unsigned long",
                                  @"Q":@"unsigned long long",
                                  @"f":@"float",
                                  @"d":@"double",
                                  @"B":@"BOOL",
                                  @"v":@"void",
                                  @"*":@"char *",
                                  @"@":@"id",
                                  @"#":@"Class",
                                  @":":@"SEL",
                                  };
        //TODO:An array
        NSString *key = [attributeDictionary objectForKey:@"T"];
        
        id type_str = [typeDic objectForKey:key];
        
        if (type_str == nil)
        {
            if ([[key substringToIndex:1] isEqualToString:@"@"] && [key rangeOfString:@"?"].location == NSNotFound)
            {
                type_str = [[key substringWithRange:NSMakeRange(2, key.length - 3)] stringByAppendingString:@"*"];
            }
            else if ([[key substringToIndex:1] isEqualToString:@"^"])
            {
                id str = [typeDic objectForKey:[key substringFromIndex:1]];
                
                if (str)
                {
                    type_str = [NSString stringWithFormat:@"%@ *",str];
                }
            }
            else
            {
                type_str = @"unknow";
            }
        }
        
        [result setObject:type_str forKey:@"type"];
    }
    
    [result setObject:attributeArray forKey:@"attribute"];
    
    return result;
}



@end







