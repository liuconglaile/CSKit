//
//  CSKitMacro.h
//  CSCategory
//
//  Created by mac on 2017/6/14.
//  Copyright © 2017年 mac. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <sys/time.h>
#import <pthread.h>
#import "UIApplication+Extended.h"

#ifndef CSKitMacro_h
#define CSKitMacro_h


#ifdef __cplusplus
#define CS_EXTERN_C_BEGIN  extern "C" {
#define CS_EXTERN_C_END  }
#else
#define CS_EXTERN_C_BEGIN
#define CS_EXTERN_C_END
#endif





CS_EXTERN_C_BEGIN

//MARK:Log重构
#ifdef DEBUG
/* 模式下打印日志,当前行 并弹出一个警告 */
#define AleLog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }

/* 重写NSLog,Debug模式下打印日志和当前行数 */
#define CSNSLog(FORMAT, ...) fprintf(stderr,"\n\n\n🍎🍎🍎方法:%s \n🍊🍊🍊行号:%d \n🍌🍌🍌内容:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);


#else // 开发模式
#define AleLog(...)
#define CSNSLog(FORMAT, ...) nil

#endif

/**
 返回间距值
 
 @param _x_ <#_x_ description#>
 @param _low_ 低值
 @param _high_ 高值
 @return <#return value description#>
 */
#ifndef CS_CLAMP ///
#define CS_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif


/**
 交换两个值
 
 @param _a_ a数值
 @param _b_ b数值
 @return 交换后
 */
#ifndef CS_SWAP ///
#define CS_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif



/**
 自定义断言(ObjectC)
 
 @param condition 条件表达式
 @param description 异常描述
 @param ... NSString描述
 @return 自定义的断言
 */
#define CSAssertNil(condition, description, ...) NSAssert(!(condition), (description), ##__VA_ARGS__)

/**
 自定义断言(C)
 
 @param condition 条件表达式
 @param description 异常描述
 @param ... NSString描述
 @return 自定义的断言
 */
#define CSCAssertNil(condition, description, ...) NSCAssert(!(condition), (description), ##__VA_ARGS__)

#define CSAssertNotNil(condition, description, ...) NSAssert((condition), (description), ##__VA_ARGS__)
#define CSCAssertNotNil(condition, description, ...) NSCAssert((condition), (description), ##__VA_ARGS__)


#define CSAssertMainThread()  NSAssert([NSThread isMainThread], @"必须在主线程上调用此方法")
#define CSCAssertMainThread() NSCAssert([NSThread isMainThread], @"必须在主线程上调用此方法")





/**
 在每个类别实现之前添加这个宏,所以我们不必使用  -all_load 或 -force_load 仅从静态库加载对象文件包含类别,没有类.
 更多信息: http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html .
 *******************************************************************************
 
 示例:
 CSSYNTH_DUMMY_CLASS(NSString_CSAdd)
 
 @param _name_ 类别名
 @return 添加的类别
 */
#ifndef CSSYNTH_DUMMY_CLASS
#define CSSYNTH_DUMMY_CLASS(_name_) \
@interface CSSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation CSSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif




/**
 在@implementation范围内合成动态对象属性.它允许我们向类别中的现有类添加自定义属性.
 
 原:
 @param association  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) UIColor *myColor;
 @end
 
 宏使用:
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 CSSYNTH_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor, RETAIN, UIColor *)
 @end
 
 @param _getter_ get方法
 @param _setter_ set方法
 @param _association_ 内存
 @param _type_ 类型
 @return 动态添加的对象属性
 */
#ifndef CSSYNTH_DYNAMIC_PROPERTY_OBJECT
#define CSSYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif





/**
 在@implementation范围内合成动态C类型属性.它允许我们向类别中的现有类添加自定义属性.
 
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) CGPoint myPoint;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 CSSYNTH_DYNAMIC_PROPERTY_CTYPE(myPoint, setMyPoint, CGPoint)
 @end
 
 @param _getter_ get方法
 @param _setter_ set方法
 @param _type_ 类型
 @return 动态C类型属性
 */
#ifndef CSSYNTH_DYNAMIC_PROPERTY_CTYPE
#define CSSYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
_type_ cValue = { 0 }; \
NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
[value getValue:&cValue]; \
return cValue; \
}
#endif

//MARK:动态添加属性(可用与分类)
/**
 添加动态属性->基于对象
 
 @param PROPERTY_TYPE  属性类型
 @param PROPERTY_NAME 属性名
 @param SETTER_NAME set方法名
 @return 返回属性
 */
#define ADD_DYNAMIC_PROPERTY(PROPERTY_TYPE,PROPERTY_NAME,SETTER_NAME) \
\
@dynamic PROPERTY_NAME ; \
\
static char kProperty##PROPERTY_NAME; \
\
- ( PROPERTY_TYPE ) PROPERTY_NAME \
\
{ \
\
return ( PROPERTY_TYPE ) objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
\
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
\
{ \
\
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , PROPERTY_NAME , OBJC_ASSOCIATION_RETAIN); \
}



/**
 添加动态属性->基于 CGFloat
 
 @param PROPERTY_TYPE  属性类型
 @param PROPERTY_NAME 属性名
 @param SETTER_NAME set方法名
 @return 返回属性
 */
#define ADD_DYNAMIC_PROPERTY_CGFloat(PROPERTY_TYPE,PROPERTY_NAME,SETTER_NAME) \
\
static char kProperty##PROPERTY_NAME; \
\
- (PROPERTY_TYPE) PROPERTY_NAME \
\
{ \
\
return [objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME) ) floatValue]; \
\
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
\
{ \
\
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , @(PROPERTY_NAME) , OBJC_ASSOCIATION_RETAIN); \
}






/**
 弱引用

 示例:
 @weakify(self)
 [self doSomething^{
     @strongify(self)
     if (!self) return;
     ...
 }];
 
 @param objc_arc 引用对象
 @return 引用后的对象
 */
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif


/**
 强引用

 @param objc_arc 引用对象
 @return 引用后的对象
 */
#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif





/**
 将CFRange转换为NSRange

 @param range 要转换的CFRange
 @return NSRange
 */
static inline NSRange CSNSRangeFromCFRange(CFRange range) {
    return NSMakeRange(range.location, range.length);
}

/**
 将NSRange转换为CFRange

 @param range NSRange
 @return CFRange
 */
static inline CFRange CSCFRangeFromNSRange(NSRange range) {
    return CFRangeMake(range.location, range.length);
}


/**
 与 CFAutorelease()相同,兼容 iOS6

 @param arg CFObject
 @return 与输入相同
 */
static inline CFTypeRef CSCFAutorelease(CFTypeRef CF_RELEASES_ARGUMENT arg) {
    if (((long)CFAutorelease + 1) != 1) {
        return CFAutorelease(arg);
    } else {
        id __autoreleasing obj = CFBridgingRelease(arg);
        return (__bridge CFTypeRef)obj;
    }
}


/**
 代码运算成本

 @param block 测试代码块
 代码时间成本(毫秒)
 */
static inline void CSBenchmark(void (^block)(void), void (^complete)(double ms)) {
    // <QuartzCore/QuartzCore.h> version
    /*
     extern double CACurrentMediaTime (void);
     double begin, end, ms;
     begin = CACurrentMediaTime();
     block();
     end = CACurrentMediaTime();
     ms = (end - begin) * 1000.0;
     complete(ms);
     */
    
    /**
     用法:
     CSBenchmark(^{
        // code....
     }, ^(double ms) {
        NSLog("time cost: %.2f ms",ms);
     });
     
     */
    
    // <sys/time.h> version
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}

static inline NSDate *_CSCompileTime(const char *data, const char *time) {
    NSString *timeStr = [NSString stringWithFormat:@"%s %s",data,time];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd yyyy HH:mm:ss"];
    [formatter setLocale:locale];
    return [formatter dateFromString:timeStr];
}



#ifndef CSIdentitfier
/** 这个值必须每次新建项目的时候就填写 */
#define CSIdentitfier @"com.ibireme.CSKit"
#endif
/**
 获取程序索引

 @return 程序索引
 */
static inline NSString* _getAppBundleID(){
    return [UIApplication sharedApplication].appBundleID;
}




/**
 获取编译时间戳.
 @return 将一个新的日期对象设置为编译日期和时间.
 */
#ifndef CSCompileTime
// 使用宏避免在使用pch文件时编译警告
#define CSCompileTime() _CSCompileTime(__DATE__, __TIME__)
#endif






/**
 调度_时间_延迟

 @param second 延迟秒数
 @return <#return value description#>
 */
static inline dispatch_time_t dispatch_time_delay(NSTimeInterval second) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/** 从现在返回dispatch_wall_time延迟. */
static inline dispatch_time_t dispatch_walltime_delay(NSTimeInterval second) {
    return dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/** 从NSDate返回dispatch_wall_time */
static inline dispatch_time_t dispatch_walltime_date(NSDate *date) {
    NSTimeInterval interval;
    double second, subsecond;
    struct timespec time;
    dispatch_time_t milestone;
    
    interval = [date timeIntervalSince1970];
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&time, 0);
    return milestone;
}

/** 是否在主队列/线程中 */
static inline bool dispatch_is_main_queue() {
    return pthread_main_np() != 0;
}

/** 在主队列上提交用于异步执行的块,并立即返回 */
static inline void dispatch_async_on_main_queue(void (^block)()) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/** 在主队列上提交执行块,并等待直到块完成 */
static inline void dispatch_sync_on_main_queue(void (^block)()) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

/** 初始化一个pthread互斥体 */
static inline void pthread_mutex_init_recursive(pthread_mutex_t *mutex, bool recursive) {
#define CSMUTEX_ASSERT_ON_ERROR(x_) do { \
__unused volatile int res = (x_); \
assert(res == 0); \
} while (0)
    assert(mutex != NULL);
    if (!recursive) {
        CSMUTEX_ASSERT_ON_ERROR(pthread_mutex_init(mutex, NULL));
    } else {
        pthread_mutexattr_t attr;
        CSMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_init (&attr));
        CSMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE));
        CSMUTEX_ASSERT_ON_ERROR(pthread_mutex_init (mutex, &attr));
        CSMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_destroy (&attr));
    }
#undef CSMUTEX_ASSERT_ON_ERROR
}



CS_EXTERN_C_END

#endif /* CSKitMacro_h */



