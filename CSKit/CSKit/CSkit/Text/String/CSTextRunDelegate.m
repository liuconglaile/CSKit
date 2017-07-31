//
//  CSTextRunDelegate.m
//  CSCategory
//
//  Created by mac on 2017/7/26.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSTextRunDelegate.h"

static void DeallocCallback(void *ref) {
    CSTextRunDelegate *self = (__bridge_transfer CSTextRunDelegate *)(ref);
    self = nil; // release
}

static CGFloat GetAscentCallback(void *ref) {
    CSTextRunDelegate *self = (__bridge CSTextRunDelegate *)(ref);
    return self.ascent;
}

static CGFloat GetDecentCallback(void *ref) {
    CSTextRunDelegate *self = (__bridge CSTextRunDelegate *)(ref);
    return self.descent;
}

static CGFloat GetWidthCallback(void *ref) {
    CSTextRunDelegate *self = (__bridge CSTextRunDelegate *)(ref);
    return self.width;
}


@implementation CSTextRunDelegate

- (CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED {
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.dealloc = DeallocCallback;
    callbacks.getAscent = GetAscentCallback;
    callbacks.getDescent = GetDecentCallback;
    callbacks.getWidth = GetWidthCallback;
    return CTRunDelegateCreate(&callbacks, (__bridge_retained void *)(self.copy));
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_ascent) forKey:@"ascent"];
    [aCoder encodeObject:@(_descent) forKey:@"descent"];
    [aCoder encodeObject:@(_width) forKey:@"width"];
    [aCoder encodeObject:_userInfo forKey:@"userInfo"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _ascent = ((NSNumber *)[aDecoder decodeObjectForKey:@"ascent"]).floatValue;
    _descent = ((NSNumber *)[aDecoder decodeObjectForKey:@"descent"]).floatValue;
    _width = ((NSNumber *)[aDecoder decodeObjectForKey:@"width"]).floatValue;
    _userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.ascent = self.ascent;
    one.descent = self.descent;
    one.width = self.width;
    one.userInfo = self.userInfo;
    return one;
}


@end

