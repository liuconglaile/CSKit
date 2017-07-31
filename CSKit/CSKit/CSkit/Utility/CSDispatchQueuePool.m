//
//  CSDispatchQueuePool.m
//  CSCategory
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSDispatchQueuePool.h"
//#import <libkern/OSAtomic.h>
#import <UIKit/UIKit.h>

#define MAX_QUEUE_COUNT 32


/**
 基于 QOS 获取调度服务质量(优先级)
 
 @param qos QOS枚举
 @return 优先级
 */
static inline dispatch_queue_priority_t NSQualityOfServiceToDispatchPriority(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive:
            return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUserInitiated:
            return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUtility:
            return DISPATCH_QUEUE_PRIORITY_LOW;
        case NSQualityOfServiceBackground:
            return DISPATCH_QUEUE_PRIORITY_BACKGROUND;
        case NSQualityOfServiceDefault:
            return DISPATCH_QUEUE_PRIORITY_DEFAULT;
        default:
            return DISPATCH_QUEUE_PRIORITY_DEFAULT;
    }
}


/**
 基于 QOS 获取 QOS 抽象类
 
 @param qos QOS枚举
 @return QOS 抽象类
 */
static inline qos_class_t NSQualityOfServiceToQOSClass(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive:
            return QOS_CLASS_USER_INTERACTIVE;
        case NSQualityOfServiceUserInitiated:
            return QOS_CLASS_USER_INITIATED;
        case NSQualityOfServiceUtility:
            return QOS_CLASS_UTILITY;
        case NSQualityOfServiceBackground:
            return QOS_CLASS_BACKGROUND;
        case NSQualityOfServiceDefault:
            return QOS_CLASS_DEFAULT;
        default:
            return QOS_CLASS_UNSPECIFIED;
    }
}

/** 自定义调度上下文结构体 */
typedef struct {
    const char *name;
    void **queues;
    uint32_t queueCount;
    int32_t counter;
} CSDispatchContext;



/**
 调度上下文创建
 
 @param name 调度池名称
 @param queueCount 队列计数
 @param qos QOS
 @return  调度上下文结构体
 */
static CSDispatchContext *CSDispatchContextCreate(const char *name, uint32_t queueCount, NSQualityOfService qos) {
    
    CSDispatchContext *context = calloc(1, sizeof(CSDispatchContext));
    
    if (!context) return NULL;
    
    context->queues =  calloc(queueCount, sizeof(void *));
    
    if (!context->queues) {
        free(context);
        return NULL;
    }
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        
        dispatch_qos_class_t qosClass = NSQualityOfServiceToQOSClass(qos);
        
        for (NSUInteger i = 0; i < queueCount; i++) {
            dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qosClass, 0);
            dispatch_queue_t queue = dispatch_queue_create(name, attr);
            context->queues[i] = (__bridge_retained void *)(queue);
        }
        
    } else {
        
        long identifier = NSQualityOfServiceToDispatchPriority(qos);
        
        for (NSUInteger i = 0; i < queueCount; i++) {
            dispatch_queue_t queue = dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL);
            dispatch_set_target_queue(queue, dispatch_get_global_queue(identifier, 0));
            context->queues[i] = (__bridge_retained void *)(queue);
        }
        
    }
    context->queueCount = queueCount;
    
    if (name) {
        context->name = strdup(name);
    }
    
    return context;
}





/**
 调度环境释放
 
 @param context 调度结构体
 */
static void CSDispatchContextRelease(CSDispatchContext *context) {
    if (!context) return;
    if (context->queues) {
        for (NSUInteger i = 0; i < context->queueCount; i++) {
            void *queuePointer = context->queues[i];
            dispatch_queue_t queue = (__bridge_transfer dispatch_queue_t)(queuePointer);
            const char *name = dispatch_queue_get_label(queue);
            if (name) strlen(name); // 避免编译器警告
            queue = nil;
        }
        free(context->queues);
        context->queues = NULL;
    }
    if (context->name) free((void *)context->name);
}



/**
 获取调度上下文队列
 
 @param context 调度上下文
 @return 调度队列
 */
static dispatch_queue_t CSDispatchContextGetQueue(CSDispatchContext *context) {
    uint32_t counter = (uint32_t)OSAtomicIncrement32(&context->counter);
    void *queue = context->queues[counter % context->queueCount];
    return (__bridge dispatch_queue_t)(queue);
}


static CSDispatchContext *CSDispatchContextGetForQOS(NSQualityOfService qos) {
    static CSDispatchContext *context[5] = {0};
    switch (qos) {
            
            /// QoS用于直接参与提供交互UI的工作,例如处理事件或绘图到屏幕
        case NSQualityOfServiceUserInteractive: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[0] = CSDispatchContextCreate("com.ibireme.cskit.user-interactive", count, qos);
            });
            return context[0];
        } break;
            
            /// 发起的QoS用于执行已被用户明确请求的工作,并且为了允许进一步的用户交互,必须立即显示结果.
            /// 例如,用户在一个消息列表中选择了一个电子邮件
        case NSQualityOfServiceUserInitiated: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[1] = CSDispatchContextCreate("com.ibireme.cskit.user-initiated", count, qos);
            });
            return context[1];
        } break;
            
            /**
             实用程序QoS用于执行工作,用户不太可能立即等待结果.
             此工作可能已被用户请求或自动启动,不会阻止用户进一步交互,通常在用户可见的时间尺度上运行,并可能通过非模态进度指示向用户显示其进度.
             该工作将以一种高效的方式运行,以满足在资源受限时更高的QoS工作.
             例如,定期的内容更新或批量文件操作,例如媒体导入
             */
        case NSQualityOfServiceUtility: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[2] = CSDispatchContextCreate("com.ibireme.cskit.utility", count, qos);
            });
            return context[2];
        } break;
            /**
             后台QoS用于非用户启动或可见的工作.
             一般来说,用户不知道这个工作正在进行中,并且它将以最有效的方式运行,同时对更高的QoS工作给予最尊重.
             例如,预取内容、搜索索引、备份和与外部系统的数据同步
             */
        case NSQualityOfServiceBackground: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[3] = CSDispatchContextCreate("com.ibireme.cskit.background", count, qos);
            });
            return context[3];
        } break;
            
            /**
             默认的QoS表示缺少QoS信息.
             只要可能的QoS信息将从其他来源推断出来.
             如果这样的推断是不可能的,那么将使用user发起和实用程序之间的QoS.
             */
        case NSQualityOfServiceDefault:
        default: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[4] = CSDispatchContextCreate("com.ibireme.cskit.default", count, qos);
            });
            return context[4];
        } break;
    }
}



@implementation CSDispatchQueuePool{
@public
    CSDispatchContext *_context;
}

- (void)dealloc {
    if (_context) {
        CSDispatchContextRelease(_context);
        _context = NULL;
    }
}

- (instancetype)initWithContext:(CSDispatchContext *)context {
    self = [super init];
    if (!context) return nil;
    self->_context = context;
    _name = context->name ? [NSString stringWithUTF8String:context->name] : nil;
    return self;
}

- (instancetype)initWithName:(NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos {
    if (queueCount == 0 || queueCount > MAX_QUEUE_COUNT) return nil;
    self = [super init];
    _context = CSDispatchContextCreate(name.UTF8String, (uint32_t)queueCount, qos);
    if (!_context) return nil;
    _name = name;
    return self;
}

- (dispatch_queue_t)queue {
    return CSDispatchContextGetQueue(_context);
}

+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: {
            static CSDispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[CSDispatchQueuePool alloc] initWithContext:CSDispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceUserInitiated: {
            static CSDispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[CSDispatchQueuePool alloc] initWithContext:CSDispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceUtility: {
            static CSDispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[CSDispatchQueuePool alloc] initWithContext:CSDispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceBackground: {
            static CSDispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[CSDispatchQueuePool alloc] initWithContext:CSDispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceDefault:
        default: {
            static CSDispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[CSDispatchQueuePool alloc] initWithContext:CSDispatchContextGetForQOS(NSQualityOfServiceDefault)];
            });
            return pool;
        } break;
    }
}


@end


dispatch_queue_t CSDispatchQueueGetForQOS(NSQualityOfService qos) {
    return CSDispatchContextGetQueue(CSDispatchContextGetForQOS(qos));
}







/**
    QOS 枚举详解
 
    下面的优先级(QoS)分类用于向系统表明工作的性质和重要性.
    系统使用它们来管理各种资源.在资源争用中,较高的QoS类接收的资源比较低的类要多
typedef NS_ENUM(NSInteger, NSQualityOfService) {
    
 
    //QoS用于直接参与提供交互UI的工作,例如处理事件或绘图到屏幕//
    NSQualityOfServiceUserInteractive = 0x21,
    
 
 
    发起的QoS用于执行已被用户明确请求的工作,并且为了允许进一步的用户交互,必须立即显示结果.
    例如,用户在一个消息列表中选择了一个电子邮件
    NSQualityOfServiceUserInitiated = 0x19,
    
 
 
    实用程序QoS用于执行工作,用户不太可能立即等待结果.
    此工作可能已被用户请求或自动启动,不会阻止用户进一步交互,通常在用户可见的时间尺度上运行,并可能通过非模态进度指示向用户显示其进度.
    该工作将以一种高效的方式运行,以满足在资源受限时更高的QoS工作.
    例如,定期的内容更新或批量文件操作,例如媒体导入
    NSQualityOfServiceUtility = 0x11,
    
 
 
    后台QoS用于非用户启动或可见的工作.
    一般来说,用户不知道这个工作正在进行中,并且它将以最有效的方式运行,同时对更高的QoS工作给予最尊重.
    例如,预取内容、搜索索引、备份和与外部系统的数据同步
    NSQualityOfServiceBackground = 0x09,
    
 
    默认的QoS表示缺少QoS信息.
    只要可能的QoS信息将从其他来源推断出来.
    如果这样的推断是不可能的,那么将使用user发起和实用程序之间的QoS.
    NSQualityOfServiceDefault = -1
} NS_ENUM_AVAILABLE(10_10, 8_0);
 
 */






