//
//  NSKeyedUnarchiver+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSKeyedUnarchiver+Extended.h"

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

CSSYNTH_DUMMY_CLASS(NSKeyedUnarchiver_Extended)

@implementation NSKeyedUnarchiver (Extended)

+ (id)unarchiveObjectWithData:(NSData *)data exception:(__autoreleasing NSException **)exception {
    id object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    @catch (NSException *e){
        if (exception) *exception = e;
    }
    
    @finally{
        
    }
    return object;
}

+ (id)unarchiveObjectWithFile:(NSString *)path exception:(__autoreleasing NSException **)exception {
    id object = nil;
    
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    
    @catch (NSException *e){
        if (exception) *exception = e;
    }
    
    @finally{
        
    }
    return object;
}

@end
