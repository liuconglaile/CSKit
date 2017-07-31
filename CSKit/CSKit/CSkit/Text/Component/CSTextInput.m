//
//  CSTextInput.m
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSTextInput.h"
#import "CSKitMacro.h"

@implementation CSTextPosition

+ (instancetype)positionWithOffset:(NSInteger)offset {
    return [self positionWithOffset:offset affinity:CSTextAffinityForward];
}

+ (instancetype)positionWithOffset:(NSInteger)offset affinity:(CSTextAffinity)affinity {
    CSTextPosition *p = [self new];
    p->_offset = offset;
    p->_affinity = affinity;
    return p;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self.class positionWithOffset:_offset affinity:_affinity];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> (%@%@)", self.class, self, @(_offset), _affinity == CSTextAffinityForward ? @"F":@"B"];
}

- (NSUInteger)hash {
    return _offset * 2 + (_affinity == CSTextAffinityForward ? 1 : 0);
}

- (BOOL)isEqual:(CSTextPosition *)object {
    if (!object) return NO;
    return _offset == object.offset && _affinity == object.affinity;
}

- (NSComparisonResult)compare:(CSTextPosition *)otherPosition {
    if (!otherPosition) return NSOrderedAscending;
    if (_offset < otherPosition.offset) return NSOrderedAscending;
    if (_offset > otherPosition.offset) return NSOrderedDescending;
    if (_affinity == CSTextAffinityBackward && otherPosition.affinity == CSTextAffinityForward) return NSOrderedAscending;
    if (_affinity == CSTextAffinityForward && otherPosition.affinity == CSTextAffinityBackward) return NSOrderedDescending;
    return NSOrderedSame;
}

@end



@implementation CSTextRange {
    CSTextPosition *_start;
    CSTextPosition *_end;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _start = [CSTextPosition positionWithOffset:0];
    _end = [CSTextPosition positionWithOffset:0];
    return self;
}

- (CSTextPosition *)start {
    return _start;
}

- (CSTextPosition *)end {
    return _end;
}

- (BOOL)isEmpty {
    return _start.offset == _end.offset;
}

- (NSRange)asRange {
    return NSMakeRange(_start.offset, _end.offset - _start.offset);
}

+ (instancetype)rangeWithRange:(NSRange)range {
    return [self rangeWithRange:range affinity:CSTextAffinityForward];
}

+ (instancetype)rangeWithRange:(NSRange)range affinity:(CSTextAffinity)affinity {
    CSTextPosition *start = [CSTextPosition positionWithOffset:range.location affinity:affinity];
    CSTextPosition *end = [CSTextPosition positionWithOffset:range.location + range.length affinity:affinity];
    return [self rangeWithStart:start end:end];
}

+ (instancetype)rangeWithStart:(CSTextPosition *)start end:(CSTextPosition *)end {
    if (!start || !end) return nil;
    if ([start compare:end] == NSOrderedDescending) {
        CS_SWAP(start, end);
    }
    CSTextRange *range = [CSTextRange new];
    range->_start = start;
    range->_end = end;
    return range;
}

+ (instancetype)defaultRange {
    return [self new];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self.class rangeWithStart:_start end:_end];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> (%@, %@)%@", self.class, self, @(_start.offset), @(_end.offset - _start.offset), _end.affinity == CSTextAffinityForward ? @"F":@"B"];
}

- (NSUInteger)hash {
    return (sizeof(NSUInteger) == 8 ? OSSwapInt64(_start.hash) : OSSwapInt32(_start.hash)) + _end.hash;
}

- (BOOL)isEqual:(CSTextRange *)object {
    if (!object) return NO;
    return [_start isEqual:object.start] && [_end isEqual:object.end];
}

@end



@implementation CSTextSelectionRect

@synthesize rect = _rect;
@synthesize writingDirection = _writingDirection;
@synthesize containsStart = _containsStart;
@synthesize containsEnd = _containsEnd;
@synthesize isVertical = _isVertical;

- (id)copyWithZone:(NSZone *)zone {
    CSTextSelectionRect *one = [self.class new];
    one.rect = _rect;
    one.writingDirection = _writingDirection;
    one.containsStart = _containsStart;
    one.containsEnd = _containsEnd;
    one.isVertical = _isVertical;
    return one;
}

@end
