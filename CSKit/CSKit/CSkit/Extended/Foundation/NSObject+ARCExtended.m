//
//  NSObject+ARCExtended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSObject+ARCExtended.h"

@interface NSObject_CSAddForARC : NSObject @end
@implementation NSObject_CSAddForARC @end

#if __has_feature(objc_arc)
//#error 必须在没有ARC的情况下编译此文件.为此文件指定-fno-objc-arc标志.
#endif

@implementation NSObject (ARCExtended)

- (instancetype)arcDebugRetain NS_AUTOMATED_REFCOUNT_UNAVAILABLE {
    
#if __has_feature(objc_arc)
    return self;
#else
    return [self retain];
#endif
    
    
}

- (oneway void)arcDebugRelease {

#if __has_feature(objc_arc)

#else
    [self release];
#endif

}

- (instancetype)arcDebugAutorelease {
#if __has_feature(objc_arc)
    return self;
#else
    return [self autorelease];
#endif
}

- (NSUInteger)arcDebugRetainCount OBJC_ARC_UNAVAILABLE{
#   if __has_feature(objc_arc)
  return 0;
#   else
  return [self retainCount];
#   endif
}

@end
