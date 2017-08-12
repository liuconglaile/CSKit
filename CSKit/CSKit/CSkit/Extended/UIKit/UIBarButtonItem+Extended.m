//
//  UIBarButtonItem+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIBarButtonItem+Extended.h"
#import <objc/runtime.h>
#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSKitMacro.h>

#else
#import "CSKitMacro.h"

#endif

CSSYNTH_DUMMY_CLASS(UIBarButtonItem_Extended)

static const int block_key;

@interface _CSUIBarButtonItemBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);

- (id)initWithBlock:(void (^)(id sender))block;
- (void)invoke:(id)sender;

@end

@implementation _CSUIBarButtonItemBlockTarget

- (id)initWithBlock:(void (^)(id sender))block{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (self.block) self.block(sender);
}

@end

@implementation UIBarButtonItem (Extended)

- (void)setActionBlock:(BarButtonClickCallback)block {
    _CSUIBarButtonItemBlockTarget *target = [[_CSUIBarButtonItemBlockTarget alloc] initWithBlock:block];
    objc_setAssociatedObject(self, &block_key, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setTarget:target];
    [self setAction:@selector(invoke:)];
}

- (BarButtonClickCallback)actionBlock{
    _CSUIBarButtonItemBlockTarget *target = objc_getAssociatedObject(self, &block_key);
    return target.block;
}


@end
