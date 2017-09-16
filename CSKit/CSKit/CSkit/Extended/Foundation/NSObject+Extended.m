//
//  NSObject+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSObject+Extended.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSMacrosHeader.h>
#import <CSkit/NSString+Extended.h>
#else
#import "CSMacrosHeader.h"
#import "NSString+Extended.h"
#endif


/** 默认下载文件存储位置 */
#define DefaultKeyedArchiverPath @"%@/Library/Caches/DefaultKeyedArchiverPath"

CSSYNTH_DUMMY_CLASS(NSObject_Extended)

BOOL method_swizzle(Class klass, SEL origSel, SEL altSel)
{
    if (!klass)
    return NO;
    
    Method __block origMethod, __block altMethod;
    
    void (^find_methods)() = ^
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

void method_append(Class toClass, Class fromClass, SEL selector)
{
    if (!toClass || !fromClass || !selector)
    return;
    
    Method method = class_getInstanceMethod(fromClass, selector);
    
    if (!method)
    return;
    
    class_addMethod(toClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
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



@implementation NSObject (Extended)

/*
 NSInvocation is much slower than objc_msgSend()...
 Do not use it if you have performance issues.
 */

#define INIT_INV(_last_arg_, _return_) \
NSMethodSignature * sig = [self methodSignatureForSelector:sel]; \
if (!sig) { [self doesNotRecognizeSelector:sel]; return _return_; } \
NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig]; \
if (!inv) { [self doesNotRecognizeSelector:sel]; return _return_; } \
[inv setTarget:self]; \
[inv setSelector:sel]; \
va_list args; \
va_start(args, _last_arg_); \
[NSObject setInv:inv withSig:sig andArgs:args]; \
va_end(args);


/**
 向接收方发送指定的消息,并返回消息的结果(使用示例1-1)
 
 @param sel 标识要发送的消息的选择器.如果选择器为NULL或无法识别,则会引发NSInvalidArgumentException异常
 @return 作为消息结果的对象
 */
- (id)performSelectorWithArgs:(SEL)sel, ...{
    INIT_INV(sel, nil);
    [inv invoke];
    return [NSObject getReturnFromInv:inv withSig:sig];
}

/**
 在延迟之后使用默认模式调用当前线程上的接收方法,之前的请求不能取消(使用示例1-2)
 
 @param sel 标识要发送的消息的选择器.如果选择器为NULL或无法识别,则会引发NSInvalidArgumentException异常
 @param delay 发送消息的最短时间.指定延迟0不一定导致选择器立即执行.选择器仍然在线程的运行循环中排队,并尽快执行
 
 ... 变量参数列表.参数类型必须对应于选择器的方法声明,否则可能会发生意外的结果.不支持大于256字节的union或struct.
 
 */
- (void)performSelectorWithArgs:(SEL)sel afterDelay:(NSTimeInterval)delay, ...{
    INIT_INV(delay, );
    [inv retainArguments];
    [inv performSelector:@selector(invoke) withObject:nil afterDelay:delay];
}

/**
 使用默认模式调用主线程上的接收器方法(使用示例1-3)
 
 @param sel 标识要发送的消息的选择器.如果选择器为NULL或无法识别,则会引发NSInvalidArgumentException异常
 @param wait 一个布尔值,指定当前线程是否在指定的线程上的接收器上执行指定的选择器之后阻塞.指定YES阻止此线程;否则,请指定NO以立即返回此方法.
 @return 而@a等待是YES,它返回作为消息结果的对象.否则返回nil
 */
- (id)performSelectorWithArgsOnMainThread:(SEL)sel waitUntilDone:(BOOL)wait, ...{
    INIT_INV(wait, nil);
    if (!wait) [inv retainArguments];
    [inv performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:wait];
    return wait ? [NSObject getReturnFromInv:inv withSig:sig] : nil;
}

/** 使用默认模式调用指定线程上的接收方法(使用示例1-4) */
- (id)performSelectorWithArgs:(SEL)sel onThread:(NSThread *)thr waitUntilDone:(BOOL)wait, ...{
    INIT_INV(wait, nil);
    if (!wait) [inv retainArguments];
    [inv performSelector:@selector(invoke) onThread:thr withObject:nil waitUntilDone:wait];
    return wait ? [NSObject getReturnFromInv:inv withSig:sig] : nil;
}

/**
 在新的后台线程上调用接收器的方法(使用示例1-5)
 
 @discussion   该方法在应用程序中创建一个新线程,如果尚未将应用程序置于多线程模式.
 由sel表示的方法必须像在程序中的任何其他新线程一样设置线程环境
 */
- (void)performSelectorWithArgsInBackground:(SEL)sel, ...{
    INIT_INV(sel, );
    [inv retainArguments];
    [inv performSelectorInBackground:@selector(invoke) withObject:nil];
}

#undef INIT_INV

+ (id)getReturnFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig {
    NSUInteger length = [sig methodReturnLength];
    if (length == 0) return nil;
    
    char *type = (char *)[sig methodReturnType];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type++; // cutoff useless prefix
    }
    
#define return_with_number(_type_) \
do { \
_type_ ret; \
[inv getReturnValue:&ret]; \
return @(ret); \
} while (0)
    
    switch (*type) {
        case 'v': return nil; // void
        case 'B': return_with_number(bool);
        case 'c': return_with_number(char);
        case 'C': return_with_number(unsigned char);
        case 's': return_with_number(short);
        case 'S': return_with_number(unsigned short);
        case 'i': return_with_number(int);
        case 'I': return_with_number(unsigned int);
        case 'l': return_with_number(int);
        case 'L': return_with_number(unsigned int);
        case 'q': return_with_number(long long);
        case 'Q': return_with_number(unsigned long long);
        case 'f': return_with_number(float);
        case 'd': return_with_number(double);
        case 'D': { // long double
            long double ret;
            [inv getReturnValue:&ret];
            return [NSNumber numberWithDouble:ret];
        };
        
        case '@': { // id
            id ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
        
        case '#': { // Class
            Class ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
        
        default: { // struct / union / SEL / void* / unknown
            const char *objCType = [sig methodReturnType];
            char *buf = calloc(1, length);
            if (!buf) return nil;
            [inv getReturnValue:buf];
            NSValue *value = [NSValue valueWithBytes:buf objCType:objCType];
            free(buf);
            return value;
        };
    }
#undef return_with_number
}

+ (void)setInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig andArgs:(va_list)args {
    NSUInteger count = [sig numberOfArguments];
    for (int index = 2; index < count; index++) {
        char *type = (char *)[sig getArgumentTypeAtIndex:index];
        while (*type == 'r' || // const
               *type == 'n' || // in
               *type == 'N' || // inout
               *type == 'o' || // out
               *type == 'O' || // bycopy
               *type == 'R' || // byref
               *type == 'V') { // oneway
            type++; // cutoff useless prefix
        }
        
        BOOL unsupportedType = NO;
        switch (*type) {
            case 'v': // 1: void
            case 'B': // 1: bool
            case 'c': // 1: char / BOOL
            case 'C': // 1: unsigned char
            case 's': // 2: short
            case 'S': // 2: unsigned short
            case 'i': // 4: int / NSInteger(32bit)
            case 'I': // 4: unsigned int / NSUInteger(32bit)
            case 'l': // 4: long(32bit)
            case 'L': // 4: unsigned long(32bit)
            { // 'char' and 'short' will be promoted to 'int'.
                int arg = va_arg(args, int);
                [inv setArgument:&arg atIndex:index];
            } break;
            
            case 'q': // 8: long long / long(64bit) / NSInteger(64bit)
            case 'Q': // 8: unsigned long long / unsigned long(64bit) / NSUInteger(64bit)
            {
                long long arg = va_arg(args, long long);
                [inv setArgument:&arg atIndex:index];
            } break;
            
            case 'f': // 4: float / CGFloat(32bit)
            { // 'float' will be promoted to 'double'.
                double arg = va_arg(args, double);
                float argf = arg;
                [inv setArgument:&argf atIndex:index];
            } break;
            
            case 'd': // 8: double / CGFloat(64bit)
            {
                double arg = va_arg(args, double);
                [inv setArgument:&arg atIndex:index];
            } break;
            
            case 'D': // 16: long double
            {
                long double arg = va_arg(args, long double);
                [inv setArgument:&arg atIndex:index];
            } break;
            
            case '*': // char *
            case '^': // pointer
            {
                void *arg = va_arg(args, void *);
                [inv setArgument:&arg atIndex:index];
            } break;
            
            case ':': // SEL
            {
                SEL arg = va_arg(args, SEL);
                [inv setArgument:&arg atIndex:index];
            } break;
            
            case '#': // Class
            {
                Class arg = va_arg(args, Class);
                [inv setArgument:&arg atIndex:index];
            } break;
            
            case '@': // id
            {
                id arg = va_arg(args, id);
                [inv setArgument:&arg atIndex:index];
            } break;
            
            case '{': // struct
            {
                if (strcmp(type, @encode(CGPoint)) == 0) {
                    CGPoint arg = va_arg(args, CGPoint);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGSize)) == 0) {
                    CGSize arg = va_arg(args, CGSize);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGRect)) == 0) {
                    CGRect arg = va_arg(args, CGRect);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGVector)) == 0) {
                    CGVector arg = va_arg(args, CGVector);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                    CGAffineTransform arg = va_arg(args, CGAffineTransform);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                    CATransform3D arg = va_arg(args, CATransform3D);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(NSRange)) == 0) {
                    NSRange arg = va_arg(args, NSRange);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIOffset)) == 0) {
                    UIOffset arg = va_arg(args, UIOffset);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                    UIEdgeInsets arg = va_arg(args, UIEdgeInsets);
                    [inv setArgument:&arg atIndex:index];
                } else {
                    unsupportedType = YES;
                }
            } break;
            
            case '(': // union
            {
                unsupportedType = YES;
            } break;
            
            case '[': // array
            {
                unsupportedType = YES;
            } break;
            
            default: // what?!
            {
                unsupportedType = YES;
            } break;
        }
        
        if (unsupportedType) {
            // Try with some dummy type...
            
            NSUInteger size = 0;
            NSGetSizeAndAlignment(type, &size, NULL);
            
#define case_size(_size_) \
else if (size <= 4 * _size_ ) { \
struct dummy { char tmp[4 * _size_]; }; \
struct dummy arg = va_arg(args, struct dummy); \
[inv setArgument:&arg atIndex:index]; \
}
            if (size == 0) { }
            case_size( 1) case_size( 2) case_size( 3) case_size( 4)
            case_size( 5) case_size( 6) case_size( 7) case_size( 8)
            case_size( 9) case_size(10) case_size(11) case_size(12)
            case_size(13) case_size(14) case_size(15) case_size(16)
            case_size(17) case_size(18) case_size(19) case_size(20)
            case_size(21) case_size(22) case_size(23) case_size(24)
            case_size(25) case_size(26) case_size(27) case_size(28)
            case_size(29) case_size(30) case_size(31) case_size(32)
            case_size(33) case_size(34) case_size(35) case_size(36)
            case_size(37) case_size(38) case_size(39) case_size(40)
            case_size(41) case_size(42) case_size(43) case_size(44)
            case_size(45) case_size(46) case_size(47) case_size(48)
            case_size(49) case_size(50) case_size(51) case_size(52)
            case_size(53) case_size(54) case_size(55) case_size(56)
            case_size(57) case_size(58) case_size(59) case_size(60)
            case_size(61) case_size(62) case_size(63) case_size(64)
            else {
                /*
                 Larger than 256 byte?! I don't want to deal with this stuff up...
                 Ignore this argument.
                 */
                struct dummy {char tmp;};
                for (int i = 0; i < size; i++) va_arg(args, struct dummy);
                CSNSLog(@"CSKit performSelectorWithArgs unsupported type:%s (%lu bytes)",
                      [sig getArgumentTypeAtIndex:index],(unsigned long)size);
            }
#undef case_size
            
        }
    }
}


/**
 在延迟后调用当前线程上的接收方法.
 
 @warning     ARC环境执行这个选择器会导致内存泄露
 
 @param sel   标识要调用的方法的选择器.该方法不应该有一个重要的返回值,不应该没有参数.
 如果选择器为NULL或无法识别,延迟后会引发NSInvalidArgumentException异常.
 
 @param delay 发送消息的最短时间.指定延迟0不一定导致选择器立即执行.选择器仍然在线程的运行循环中排队,并尽快执行.
 
 @discussion  此方法设置一个计时器上当前线程的run loop执行aSelector消息.
 定时器配置为以默认模式运行(NSDefaultRunLoopMode).当定时器触发时,线程尝试从运行循环中出现消息,并执行选择器.
 如果运行环路正在运行并处于默认模式,则它会成功运行;否则,定时器等待直到运行循环处于默认模式.
 */
- (void)performSelector:(SEL)sel afterDelay:(NSTimeInterval)delay {
    [self performSelector:sel withObject:nil afterDelay:delay];
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




/**
 异步执行代码块
 
 @param block 代码块
 */
- (void)performAsynchronous:(void(^)(void))block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

/**
 GCD主线程执行代码块
 
 @param block 代码块
 @param shouldWait 是否同步请求
 */
- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)shouldWait {
    if (shouldWait) {
        // Synchronous
        dispatch_sync(dispatch_get_main_queue(), block);
    }
    else {
        // Asynchronous
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
/**
 延迟执行代码块
 
 @param seconds 延迟时间 秒
 @param block 代码块
 */
- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    //    dispatch_after(popTime, dispatch_get_current_queue(), block);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
    
}




/**
 返回类名.
 */
+ (NSString *)className {
    return NSStringFromClass(self);
}

/**
 返回类名.
 
 @discussion 苹果已经在NSObject(NSLayoutConstraintCallsThis)中实现了这种方法,但没有公开.
 */
- (NSString *)className {
    return [NSString stringWithUTF8String:class_getName([self class])];
}

/**
 用'NSKeyedArchiver'和'NSKeyedUnarchiver'返回实例的副本.如果发生错误,返回nil
 */
- (id)deepCopy {
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        CSNSLog(@"%@", exception);
    }
    return obj;
}

/**
 使用archiver和unarchiver返回实例的副本.如果发生错误,返回nil.
 
 @param archiver   NSKeyedArchiver 类或继承类.
 @param unarchiver NSKeyedUnarchiver 类或继承类.
 */
- (id)deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver {
    id obj = nil;
    @try {
        obj = [unarchiver unarchiveObjectWithData:[archiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        CSNSLog(@"%@", exception);
    }
    return obj;
}







/**
 归档
 
 @param obj 需要归档的对象
 @param key 归档时赋值的key
 @return 归档成功返回YES,否则NO
 */
+ (BOOL)keyedArchiver:(id)obj key:(NSString *)key
{
    //构建path
    BOOL creatSavePathSuccess = [self creatSavePath];
    if (creatSavePathSuccess)
    {
        return [self keyedArchiver:obj key:key path:[self getKeyedArchiverPath:key]];
    }
    else
    {
        return NO;
    }
}



/**
 归档(可指定路径)
 
 @param obj 需要归档的对象
 @param key 归档时赋值的key
 @param path 指定归档的路径
 @return 归档成功返回YES,否则NO
 */
+ (BOOL)keyedArchiver:(id)obj key:(NSString *)key path:(NSString *)path
{
    NSMutableData *tpData = [NSMutableData data];
    NSKeyedArchiver *keyedArchiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:tpData];
    [keyedArchiver encodeObject:obj forKey:key];
    [keyedArchiver finishEncoding];
    return [tpData writeToFile:path atomically:YES];
}


/**
 解档
 
 @param key 解档文件的key
 @return 解档对象,如出现错误则返回nil
 */
+ (id)keyedUnarchiver:(NSString *)key
{
    return [self keyedUnarchiver:key path:[self getKeyedArchiverPath:key]];
}


/**
 解档
 
 @param key 解档文件的key
 @param path 解档文件所在路径
 @return 解档对象,如出现错误则返回nil
 */
+ (id)keyedUnarchiver:(NSString *)key path:(NSString *)path
{
    NSMutableData *tpData = [NSMutableData dataWithContentsOfFile:path];
    NSKeyedUnarchiver *keyedUnarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:tpData];
    return [keyedUnarchiver decodeObjectForKey:key];
}

/**
 创建文件夹路径
 
 @return YES表示创建成功,NO表示创建失败
 */
+(BOOL)creatSavePath
{
    BOOL success = NO;
    NSString *pathString = [NSString stringWithFormat:DefaultKeyedArchiverPath, NSHomeDirectory()];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL dataSavePathExist = [fileManager fileExistsAtPath:pathString];
    if (dataSavePathExist == NO)
    {
        //路径不存在，则创建
        BOOL creatResult = [fileManager createDirectoryAtPath:pathString withIntermediateDirectories:YES attributes:nil error:nil];
        if (creatResult == YES)
        {
            CSNSLog(@"创建文件下载路径成功");
            success = YES;
        }
        else
        {
            CSNSLog(@"创建文件下载路径失败");
            success = NO;
        }
    }
    else
    {
        CSNSLog(@"文件下载路径已创建");
        success = YES;
    }
    return success;
}

+(NSString *)getKeyedArchiverPath:(NSString *)keyString
{
    NSString *path = [NSString stringWithFormat:[NSString stringWithFormat:@"%@/%@",DefaultKeyedArchiverPath,keyString.md5String],NSHomeDirectory()];
    return path;
}



- (BOOL)isArray{
    return [self isKindOfClass:[NSArray class]];
}
- (BOOL)isDictionary{
    return [self isKindOfClass:[NSDictionary class]];
}
- (BOOL)isString{
    return [self isKindOfClass:[NSString class]];
}
- (BOOL)isNumber{
    return [self isKindOfClass:[NSNumber class]];
}

- (BOOL)isNull{
    return [self isKindOfClass:[NSNull class]];
}

- (BOOL)isImage{
    return [self isKindOfClass:[UIImage class]];
}

- (BOOL)isData{
    return [self isKindOfClass:[NSData class]];
}


- (BOOL)booleanValueForKey:(NSString *)key default:(BOOL)defaultValue{
    id value = [self valueForKey:key];
    if ([value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return defaultValue;
}

- (BOOL)booleanValueForKey:(NSString *) key{
    return [self booleanValueForKey:key default:NO];
}


- (NSDictionary *)dictionaryRepresentation{
    
    if ([self isDictionary]) {
        return (NSDictionary *)self;
    }
    
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    
    unsigned count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i=0; i<count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        id value = nil;
        @try {
            value = [self valueForKey:propertyName];
        }
        @catch (NSException *exception) {
            value = [NSNull null];
        }
        
        if (!value) {
            value = [NSNull null];
        }else{
            value = [self getValueInternal:value];
        }
        [dict setValue:value forKey:propertyName];
    }
    free(properties);
    return dict;
}

- (id)getValueInternal:(id)object{
    
    if ([object isString] || [object isNumber] || [object isNull]) {
        return object;
    }else if([object isImage]){//图片类型
        return [NSNull null];
    }else if([object isData]){//二进制数据类型
        return [NSNull null];
    }else if([object isArray]){
        NSArray *arrayObjects = (NSArray *)object;
        NSMutableArray *handledObjects = [NSMutableArray arrayWithCapacity:[arrayObjects count]];
        for(int i=0;i<[arrayObjects count];i++){
            [handledObjects setObject:[self getValueInternal:arrayObjects[i]] atIndexedSubscript:i];
        }
        return handledObjects;
    }else if([object isDictionary]){
        NSDictionary *dict = (NSDictionary *)object;
        NSMutableDictionary *handledDict = [NSMutableDictionary dictionary];
        for (NSString *key in dict.allKeys) {
            [handledDict setObject:[self getValueInternal:dict[key]] forKey:key];
        }
        return handledDict;
    }
    
    //对象类型
    return [object dictionaryRepresentation];
}






@end
