//
//  CSSentinel.m
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSSentinel.h"
#import <libkern/OSAtomic.h>

@implementation CSSentinel
{
    int32_t _value;
}

- (int32_t)value {
    return _value;
}

- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}

@end
