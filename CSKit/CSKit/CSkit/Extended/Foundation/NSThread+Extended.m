//
//  NSThread+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSThread+Extended.h"
#import <CoreFoundation/CoreFoundation.h>

@interface NSThread_Extended : NSObject @end
@implementation NSThread_Extended @end

#if __has_feature(objc_arc)
//#error 必须在没有ARC的情况下编译此文件.为此文件指定-fno-objc-arc标志.
#endif

static NSString *const CSNSThreadAutoleasePoolKey = @"CSNSThreadAutoleasePoolKey";
static NSString *const CSNSThreadAutoleasePoolStackKey = @"CSNSThreadAutoleasePoolStackKey";

static const void *PoolStackRetainCallBack(CFAllocatorRef allocator, const void *value) {
    return value;
}

static void PoolStackReleaseCallBack(CFAllocatorRef allocator, const void *value) {
    CFRelease((CFTypeRef)value);
}


static inline void CSAutoreleasePoolPush()NS_AUTOMATED_REFCOUNT_UNAVAILABLE {
    NSMutableDictionary *dic =  [NSThread currentThread].threadDictionary;
    NSMutableArray *poolStack = dic[CSNSThreadAutoleasePoolStackKey];
    
    if (!poolStack) {
        /*
         do not retain pool on push,
         but release on pop to avoid memory analyze warning
         */
        CFArrayCallBacks callbacks = {0};
        callbacks.retain = PoolStackRetainCallBack;
        callbacks.release = PoolStackReleaseCallBack;
        poolStack = (id)CFBridgingRelease(CFArrayCreateMutable(CFAllocatorGetDefault(), 0, &callbacks));
        dic[CSNSThreadAutoleasePoolStackKey] = poolStack;
        CFRelease((__bridge CFTypeRef)(poolStack));
    }
    //NSAutoreleasePool实际上是个对象引用计数自动处理器.在官方文档中被称为是一个类
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; ///< create
    [poolStack addObject:pool]; // push
}

static inline void CSAutoreleasePoolPop() {
    NSMutableDictionary *dic =  [NSThread currentThread].threadDictionary;
    NSMutableArray *poolStack = dic[CSNSThreadAutoleasePoolStackKey];
    [poolStack removeLastObject]; // pop
}

static void CSRunLoopAutoreleasePoolObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)NS_AUTOMATED_REFCOUNT_UNAVAILABLE {
    switch (activity) {
        case kCFRunLoopEntry: {
            CSAutoreleasePoolPush();
        } break;
        case kCFRunLoopBeforeWaiting: {
            CSAutoreleasePoolPop();
            CSAutoreleasePoolPush();
        } break;
        case kCFRunLoopExit: {
            CSAutoreleasePoolPop();
        } break;
        default: break;
    }
}

static void CSRunloopAutoreleasePoolSetup()NS_AUTOMATED_REFCOUNT_UNAVAILABLE {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    
    CFRunLoopObserverRef pushObserver;
    pushObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(), kCFRunLoopEntry,
                                           true,         // repeat
                                           -0x7FFFFFFF,  // before other observers
                                           CSRunLoopAutoreleasePoolObserverCallBack, NULL);
    CFRunLoopAddObserver(runloop, pushObserver, kCFRunLoopCommonModes);
    CFRelease(pushObserver);
    
    CFRunLoopObserverRef popObserver;
    popObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                          true,        // repeat
                                          0x7FFFFFFF,  // after other observers
                                          CSRunLoopAutoreleasePoolObserverCallBack, NULL);
    CFRunLoopAddObserver(runloop, popObserver, kCFRunLoopCommonModes);
    CFRelease(popObserver);
}

@implementation NSThread (Extended)

+ (void)addAutoreleasePoolToCurrentRunloop {
    if ([NSThread isMainThread]) return; // The main thread already has autorelease pool.
    NSThread *thread = [self currentThread];
    if (!thread) return;
    if (thread.threadDictionary[CSNSThreadAutoleasePoolKey]) return; // already added
    CSRunloopAutoreleasePoolSetup();
    thread.threadDictionary[CSNSThreadAutoleasePoolKey] = CSNSThreadAutoleasePoolKey; // mark the state
}

@end


