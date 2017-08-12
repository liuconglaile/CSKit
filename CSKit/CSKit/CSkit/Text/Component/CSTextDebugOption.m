//
//  CSTextDebugOption.m
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSTextDebugOption.h"
#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSKitMacro.h>

#else
#import "CSKitMacro.h"

#endif

static pthread_mutex_t _sharedDebugLock;
static CFMutableSetRef _sharedDebugTargets = nil;
static CSTextDebugOption *_sharedDebugOption = nil;


static const void* _sharedDebugSetRetain(CFAllocatorRef allocator, const void *value) {
    return value;
}

static void _sharedDebugSetRelease(CFAllocatorRef allocator, const void *value) {
}

void __sharedDebugSetFunction(const void *value, void *context) {
    id<CSTextDebugTarget> target = (__bridge id<CSTextDebugTarget>)(value);
    [target setDebugOption:_sharedDebugOption];
}

static void _initSharedDebug() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&_sharedDebugLock, NULL);
        CFSetCallBacks callbacks = kCFTypeSetCallBacks;
        callbacks.retain = _sharedDebugSetRetain;
        callbacks.release = _sharedDebugSetRelease;
        _sharedDebugTargets = CFSetCreateMutable(CFAllocatorGetDefault(), 0, &callbacks);
    });
}

static void _setSharedDebugOption(CSTextDebugOption *option) {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    _sharedDebugOption = option.copy;
    CFSetApplyFunction(_sharedDebugTargets, __sharedDebugSetFunction, NULL);
    pthread_mutex_unlock(&_sharedDebugLock);
}

static CSTextDebugOption *_getSharedDebugOption() {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    CSTextDebugOption *op = _sharedDebugOption;
    pthread_mutex_unlock(&_sharedDebugLock);
    return op;
}

static void _addDebugTarget(id<CSTextDebugTarget> target) {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    CFSetAddValue(_sharedDebugTargets, (__bridge const void *)(target));
    pthread_mutex_unlock(&_sharedDebugLock);
}

static void _removeDebugTarget(id<CSTextDebugTarget> target) {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    CFSetRemoveValue(_sharedDebugTargets, (__bridge const void *)(target));
    pthread_mutex_unlock(&_sharedDebugLock);
}



@implementation CSTextDebugOption

- (id)copyWithZone:(NSZone *)zone {
    CSTextDebugOption *op   = [self.class new];
    op.baselineColor        = self.baselineColor;
    op.CTFrameBorderColor   = self.CTFrameBorderColor;
    op.CTFrameFillColor     = self.CTFrameFillColor;
    op.CTLineBorderColor    = self.CTLineBorderColor;
    op.CTLineFillColor      = self.CTLineFillColor;
    op.CTLineNumberColor    = self.CTLineNumberColor;
    op.CTRunBorderColor     = self.CTRunBorderColor;
    op.CTRunFillColor       = self.CTRunFillColor;
    op.CTRunNumberColor     = self.CTRunNumberColor;
    op.CGGlyphBorderColor   = self.CGGlyphBorderColor;
    op.CGGlyphFillColor     = self.CGGlyphFillColor;
    return op;
}

- (BOOL)needDrawDebug {
    if (self.baselineColor      ||
        self.CTFrameBorderColor ||
        self.CTFrameFillColor   ||
        self.CTLineBorderColor  ||
        self.CTLineFillColor    ||
        self.CTLineNumberColor  ||
        self.CTRunBorderColor   ||
        self.CTRunFillColor     ||
        self.CTRunNumberColor   ||
        self.CGGlyphBorderColor ||
        self.CGGlyphFillColor) return YES;
    return NO;
}

- (void)clear {
    self.baselineColor      = nil;
    self.CTFrameBorderColor = nil;
    self.CTFrameFillColor   = nil;
    self.CTLineBorderColor  = nil;
    self.CTLineFillColor    = nil;
    self.CTLineNumberColor  = nil;
    self.CTRunBorderColor   = nil;
    self.CTRunFillColor     = nil;
    self.CTRunNumberColor   = nil;
    self.CGGlyphBorderColor = nil;
    self.CGGlyphFillColor   = nil;
}

+ (void)addDebugTarget:(id<CSTextDebugTarget>)target {
    if (target) _addDebugTarget(target);
}

+ (void)removeDebugTarget:(id<CSTextDebugTarget>)target {
    if (target) _removeDebugTarget(target);
}

+ (CSTextDebugOption *)sharedDebugOption {
    return _getSharedDebugOption();
}

+ (void)setSharedDebugOption:(CSTextDebugOption *)option {
    CSAssertMainThread();
    _setSharedDebugOption(option);
}

@end







